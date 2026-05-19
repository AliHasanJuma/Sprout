import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_card_data.dart';

/// Firestore-backed order store. Maintains an in-memory cache hydrated by
/// per-chat snapshot listeners so reads stay synchronous from the UI layer.
///
/// Writes go to `orders/{orderId}` and the listener reconciles the cache;
/// optimistic local updates fire immediately on the writing device so the
/// buyer or seller sees instant feedback without waiting for the round-trip.
class OrderRepository extends ChangeNotifier {
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, OrderCardData> _orders = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _subs = {};

  // ── Subscriptions ───────────────────────────────────────────────────

  /// Start listening to `orders` for [chatId]. Idempotent — calling twice
  /// with the same chatId reuses the existing subscription. The chat page
  /// calls this in initState and pairs it with [unsubscribeFromChat] in
  /// dispose.
  void subscribeToChat(String chatId) {
    if (_subs.containsKey(chatId)) return;
    _subs[chatId] = _db
        .collection('orders')
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .listen(
      (snap) {
        final docIds = snap.docs.map((d) => d.id).toSet();
        for (final doc in snap.docs) {
          try {
            _orders[doc.id] = OrderCardData.fromMap(doc.data());
          } catch (e) {
            debugPrint(
                'OrderRepository: failed to parse order ${doc.id}: $e');
          }
        }
        // Evict cached orders for this chat that no longer exist server-side
        // (e.g. an admin deleted one). Leave orders from OTHER chats alone.
        _orders.removeWhere(
          (id, o) => o.chatId == chatId && !docIds.contains(id),
        );
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('OrderRepository: snapshot error for chat $chatId: $e');
      },
    );
  }

  void unsubscribeFromChat(String chatId) {
    _subs[chatId]?.cancel();
    _subs.remove(chatId);
  }

  // ── Chat routing helpers ────────────────────────────────────────────

  /// Returns the chatId of the most recently active thread between this
  /// buyer + store, or generates a fresh timestamped chatId when no
  /// thread exists yet. Used by the cart and the store "Chat" button so
  /// follow-on actions land in the LATEST chat — important after the
  /// buyer cancels an order and taps "Start new chat", because the
  /// pre-existing closed thread should be left alone.
  ///
  /// Filters in memory by storeId so we only need a single-field index
  /// on `buyerId`. Skips terminal chats by checking the latest order's
  /// status would require ordering by lastMessageTime instead — for now
  /// we trust the "newest by lastMessageTime" heuristic.
  Future<String> findOrCreateLatestChatId({
    required String buyerId,
    required String storeId,
    bool requireNoActiveOrder = false,
  }) async {
    try {
      final qs = await _db
          .collection('chats')
          .where('buyerId', isEqualTo: buyerId)
          .get();
      final matching = qs.docs
          .where((d) => (d.data()['storeId'] as String?) == storeId)
          .toList()
        ..sort((a, b) {
          final aTs = a.data()['lastMessageTime'] as Timestamp?;
          final bTs = b.data()['lastMessageTime'] as Timestamp?;
          if (aTs == null && bTs == null) return 0;
          if (aTs == null) return 1;
          if (bTs == null) return -1;
          return bTs.compareTo(aTs);
        });
      if (matching.isNotEmpty) {
        final latest = matching.first;
        // Callers that are about to drop a new order in (cart "Send Order
        // to Chat") opt into [requireNoActiveOrder] so we don't stack a
        // second order on top of one that's still pending/active/ready.
        // The plain "Chat" button keeps the default and reuses the latest
        // chat regardless of order state.
        if (!requireNoActiveOrder ||
            !(await _hasActiveOrderForChat(latest.id))) {
          return latest.id;
        }
      }
    } catch (e) {
      debugPrint('OrderRepository.findOrCreateLatestChatId failed: $e');
    }
    return newChatId(buyerId: buyerId, storeId: storeId);
  }

  /// True if Firestore has at least one order on [chatId] whose status is
  /// not yet terminal. Used to decide whether a chat is "occupied" before
  /// dropping a new order into it.
  Future<bool> _hasActiveOrderForChat(String chatId) async {
    try {
      final qs = await _db
          .collection('orders')
          .where('chatId', isEqualTo: chatId)
          .get();
      for (final doc in qs.docs) {
        final statusName = doc.data()['status'] as String?;
        if (statusName == null) continue;
        final isTerminal = statusName == 'completed' ||
            statusName == 'rejected' ||
            statusName == 'cancelled';
        if (!isTerminal) return true;
      }
    } catch (e) {
      debugPrint('OrderRepository._hasActiveOrderForChat failed: $e');
    }
    return false;
  }

  /// Always returns a fresh timestamped chatId. Used by Quick Order so
  /// every quick order spawns its own dedicated thread, never reusing a
  /// running conversation between this buyer + store.
  String newChatId({required String buyerId, required String storeId}) =>
      '${buyerId}_${storeId}_${DateTime.now().millisecondsSinceEpoch}';

  // ── Sync reads from the in-memory cache ─────────────────────────────

  List<OrderCardData> get orders => List.unmodifiable(_orders.values);

  OrderCardData? getById(String orderId) => _orders[orderId];

  /// All orders for [chatId], newest first.
  List<OrderCardData> ordersForChat(String chatId) {
    final list = _orders.values.where((o) => o.chatId == chatId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Single non-terminal order for this chat thread, if any. One chat
  /// carries at most one live order at a time.
  OrderCardData? activeOrderForChat(String chatId) {
    for (final o in ordersForChat(chatId)) {
      if (!o.status.isTerminal) return o;
    }
    return null;
  }

  /// Most recent order for this chat regardless of status. Used so a
  /// terminal cancelled/rejected/completed card stays visible until the
  /// buyer chooses Start new chat.
  OrderCardData? latestForChat(String chatId) {
    final list = ordersForChat(chatId);
    return list.isEmpty ? null : list.first;
  }

  /// Synchronous pickup-code check against the cached order. The buyer's
  /// device already has the order doc loaded via subscribeToChat.
  /// TODO(backend): in production, route this through a Cloud Function so
  /// the buyer's client never has to read the seller's pickup code.
  bool checkPickupCode(String orderId, String code) {
    final order = _orders[orderId];
    if (order == null) return false;
    return order.pickupCode == code;
  }

  // ── Writes (write-through with optimistic local update) ─────────────

  /// Persist a new order. The local cache is updated immediately so the
  /// writing device's UI responds without waiting for Firestore. The
  /// other device receives the order via its own snapshot listener.
  ///
  /// Also upserts the corresponding `chats/{chatId}` doc so the seller's
  /// chat list (which filters by `storeId` and orders by `lastMessageTime`)
  /// picks up brand-new threads — Quick Order in particular spawns a fresh
  /// chatId that has never had a message sent in it, so without this write
  /// the seller would never see the order land in their inbox.
  Future<void> createOrder(OrderCardData order) async {
    _orders[order.orderId] = order;
    notifyListeners();
    try {
      await Future.wait([
        _db.collection('orders').doc(order.orderId).set(order.toMap()),
        _db.collection('chats').doc(order.chatId).set({
          'buyerId': order.buyerId,
          'buyerName': order.buyerName,
          'storeId': order.storeId,
          'storeName': order.storeName,
          // chats_page.dart reads `storeImage`; OrderCardData carries it
          // as `storeAvatarUrl`. Map the field name here.
          'storeImage': order.storeAvatarUrl ?? '',
          'lastMessage': '🛒 New order',
          'lastMessageTime': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      ]);
    } catch (e) {
      debugPrint('OrderRepository.createOrder failed: $e');
      // TODO(backend): surface failures to the UI and add retry / offline queue.
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    final existing = _orders[orderId];
    if (existing != null) {
      _orders[orderId] = existing.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('OrderRepository.updateStatus failed: $e');
    }
  }

  /// Upsert this buyer's rating under the seller's store and stamp the
  /// order with its rating value. One rating per buyer per store — a new
  /// write REPLACES any previous one (Firestore `.set` on the same doc id).
  ///
  /// TODO(backend): a Cloud Function should watch
  /// stores/{storeId}/ratings/{buyerId} writes and recompute
  /// stores/{storeId}.averageRating server-side. The client cannot update
  /// the store doc directly (and shouldn't be trusted to).
  Future<void> submitRating({
    required String orderId,
    required double rating,
    String? textReview,
  }) async {
    final order = _orders[orderId];
    if (order == null) return;
    _orders[orderId] = order.copyWith(
      rating: rating,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    try {
      await _db
          .collection('stores')
          .doc(order.storeId)
          .collection('ratings')
          .doc(order.buyerId)
          .set({
        'rating': rating,
        'review': textReview,
        'orderId': orderId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      await _db.collection('orders').doc(orderId).update({
        'rating': rating,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('OrderRepository.submitRating failed: $e');
    }
  }
}
