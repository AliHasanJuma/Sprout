import 'package:flutter/foundation.dart';
import '../models/order_card_data.dart';

/// In-memory order store used by the buyer/seller chat order card and its
/// lifecycle screens. Mirrors the singleton pattern already in CartProvider.
///
/// TODO(backend): replace this with a Firestore-backed repository that reads
/// from and writes to `orders/{orderId}` (or `chats/{chatId}/order`) and
/// exposes snapshot listeners so buyer + seller both see real-time updates.
class OrderRepository extends ChangeNotifier {
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  final Map<String, OrderCardData> _orders = {};
  // Per-store rating store: storeId -> (buyerId -> rating value 1..5).
  // TODO(backend): replace with stores/{storeId}/ratings/{buyerId} subcollection
  // and recompute stores/{storeId}.averageRating after each upsert.
  final Map<String, Map<String, double>> _ratings = {};

  List<OrderCardData> get orders => List.unmodifiable(_orders.values);

  OrderCardData? getById(String orderId) => _orders[orderId];

  /// All orders for a given chat thread, newest first.
  List<OrderCardData> ordersForChat(String chatId) {
    final list = _orders.values.where((o) => o.chatId == chatId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// The single non-terminal (pending/active/ready) order for this chat, if any.
  /// One chat thread carries at most one live order at a time.
  OrderCardData? activeOrderForChat(String chatId) {
    for (final o in ordersForChat(chatId)) {
      if (!o.status.isTerminal) return o;
    }
    return null;
  }

  /// Most recent order for the chat regardless of status (e.g. a finished
  /// completed/rejected/cancelled card we still want to show inline).
  OrderCardData? latestForChat(String chatId) {
    final list = ordersForChat(chatId);
    return list.isEmpty ? null : list.first;
  }

  // TODO(backend): write OrderCardData to orders/{orderId} and set chats/{chatId}.locked = true.
  void createOrder(OrderCardData order) {
    _orders[order.orderId] = order;
    notifyListeners();
  }

  // TODO(backend): update orders/{orderId}.status (and updatedAt).
  void updateStatus(String orderId, OrderStatus newStatus) {
    final existing = _orders[orderId];
    if (existing == null) return;
    _orders[orderId] = existing.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Validate a buyer-entered pickup code for an order. Constant-time-ish
  /// compare not needed for a 4-digit code, but keep the surface narrow.
  bool checkPickupCode(String orderId, String code) {
    final order = _orders[orderId];
    if (order == null) return false;
    return order.pickupCode == code;
  }

  // TODO(backend): upsert stores/{storeId}/ratings/{buyerId} and recompute
  // stores/{storeId}.averageRating from all ratings under the subcollection.
  // One rating per buyer per store: a new value REPLACES the previous one.
  void submitRating({
    required String orderId,
    required double rating,
    String? textReview, // stored but not displayed anywhere in the app yet
  }) {
    final order = _orders[orderId];
    if (order == null) return;
    final storeBucket = _ratings.putIfAbsent(order.storeId, () => {});
    storeBucket[order.buyerId] = rating;
    _orders[orderId] = order.copyWith(
      rating: rating,
      updatedAt: DateTime.now(),
    );
    // TODO(backend): persist textReview to stores/{storeId}/ratings/{buyerId}.review.
    notifyListeners();
  }

  /// Average rating for a store across all buyers (0 if none).
  double averageRatingForStore(String storeId) {
    final bucket = _ratings[storeId];
    if (bucket == null || bucket.isEmpty) return 0;
    final sum = bucket.values.fold<double>(0, (a, b) => a + b);
    return sum / bucket.length;
  }
}
