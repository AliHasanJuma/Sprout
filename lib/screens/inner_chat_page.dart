import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../models/order_card_data.dart';
import '../providers/order_repository.dart';
import '../shared/widgets/order_card.dart';
import 'ai_summarise_page.dart';
import 'buyer_pickup_code_page.dart';
import 'seller_order_pickup_page.dart';
import '../shared/widgets/order_status_card.dart';

class InnerChatPage extends StatefulWidget {
  final String chatId;
  final String storeId;
  final String storeName;
  final String storeImage;
  final String? initialMessage;

  const InnerChatPage({
    super.key,
    required this.chatId,
    required this.storeId,
    required this.storeName,
    required this.storeImage,
    this.initialMessage,
  });

  @override
  State<InnerChatPage> createState() => _InnerChatPageState();
}

class _InnerChatPageState extends State<InnerChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Legacy order-status (Firestore orderIntents) state — kept for backwards
  // compat with chats that already created an order under the old schema.
  bool _hasActiveOrder = false;
  Map<String, dynamic>? _activeOrder;
  bool _isLoadingOrder = true;

  // New order-card source. Synchronous in-memory mock until backend lands.
  final OrderRepository _orderRepo = OrderRepository();

  /// Most recent order for this chat (any status, including terminal so
  /// cancelled / rejected / completed cards remain visible until the buyer
  /// starts a new chat thread).
  OrderCardData? get _latestNewOrder =>
      _orderRepo.latestForChat(widget.chatId);

  /// TODO(backend): replace this with a real seller-vs-buyer role lookup
  /// (e.g. compare current uid against stores/{storeId}.ownerId). Today we
  /// just check whether the logged-in user IS the order's buyer.
  bool _isBuyerOf(OrderCardData order) => _user?.uid == order.buyerId;

  // ── NEW: Lock the live chat stream in memory ──
  late Stream<QuerySnapshot> _messagesStream;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _orderRepo.addListener(_onOrderRepoChanged);
    // Live-sync orders for this chat thread across buyer + seller devices.
    _orderRepo.subscribeToChat(widget.chatId);
    _checkForActiveOrder();

    // ── THE FIX: Initialize the stream exactly ONCE when the page opens ──
    // Now, opening the keyboard won't destroy and restart your chat connection!
    _messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(textOverride: widget.initialMessage);
      });
    }
  }

  @override
  void dispose() {
    _orderRepo.removeListener(_onOrderRepoChanged);
    _orderRepo.unsubscribeFromChat(widget.chatId);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onOrderRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkForActiveOrder() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orderIntents')
          .where('chatId', isEqualTo: widget.chatId)
          .where('buyerId', isEqualTo: _user?.uid)
          .where('status', whereIn: ['requested', 'accepted'])
          .limit(1)
          .get();
      
      if (mounted && querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _activeOrder = doc.data();
          _activeOrder!['id'] = doc.id;
          _hasActiveOrder = true;
          _isLoadingOrder = false;
        });
      } else if (mounted) {
        setState(() {
          _hasActiveOrder = false;
          _isLoadingOrder = false;
        });
      }
    } catch (e) {
      print('Error checking orders: $e');
      if (mounted) {
        setState(() {
          _isLoadingOrder = false;
        });
      }
    }
  }

  void _refreshOrders() {
    _checkForActiveOrder();
  }

  void _startNewChat() {
    final newChatId = '${_user?.uid}_${widget.storeId}_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InnerChatPage(
          chatId: newChatId,
          storeId: widget.storeId,
          storeName: widget.storeName,
          storeImage: widget.storeImage,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Future<void> _sendMessage({String? textOverride}) async {
    final text = textOverride ?? _msgController.text.trim();
    if (text.isEmpty || _user == null) return;

    if (textOverride == null) {
      _msgController.clear();
    }

    final timestamp = FieldValue.serverTimestamp();
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    // 1. Save the message bubble to the subcollection
    await chatRef.collection('messages').add({
      'text': text,
      'senderId': _user!.uid, // Tracks exactly who typed this specific bubble
      'timestamp': timestamp,
    });

    // 2. SAFE PARSING: Extract the true buyer UID from the chatId string (index 0)
    // This stops a seller's reply from accidentally stealing the 'buyerId' slot!
    final String trueBuyerId = widget.chatId.split('_')[0];

    // 3. Update main chat document safely
    await chatRef.set({
      'buyerId': trueBuyerId, 
      'storeId': widget.storeId,
      'storeName': widget.storeName,
      'storeImage': widget.storeImage,
      'lastMessage': text,
      'lastMessageTime': timestamp,
    }, SetOptions(merge: true));

    // 4. Optional: If the buyer is sending the message, save their name to display for the seller
    if (_user!.uid == trueBuyerId) {
      await chatRef.set({
        'buyerName': _user!.displayName ?? 'Customer',
      }, SetOptions(merge: true));
    }
  }

  void _showReportSheet() {
    String? selectedReason;
    final otherCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Report this chat',
                    style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ...['Spam', 'Harassment', 'Inappropriate content', 'Fraud', 'Other'].map((reason) => RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15)),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: const Color(0xFF003E3B),
                        onChanged: (val) {
                          setSheetState(() => selectedReason = val);
                        },
                      )),
                  if (selectedReason == 'Other') ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDEDEDE))),
                      child: TextField(
                        controller: otherCtrl,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Describe the issue...',
                          hintStyle: TextStyle(color: Color(0xFFC3C3C3)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              
                              try {
                                await FirebaseFirestore.instance.collection('reports').add({
                                  'reporterId': _user?.uid ?? 'unknown_user',
                                  'reportedStoreId': widget.storeId,
                                  'reportedStoreName': widget.storeName,
                                  'chatId': widget.chatId,
                                  'reason': selectedReason,
                                  'details': selectedReason == 'Other' ? otherCtrl.text.trim() : '',
                                  'status': 'pending',
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Report submitted. We\'ll review it shortly.')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to submit report: $e')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit Report',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display', 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: selectedReason == null ? const Color(0xFF9F9F9F) : Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newOrder = _latestNewOrder;
    final hasNewOrder = newOrder != null;
    final hasLegacy = !hasNewOrder && _hasActiveOrder && _activeOrder != null;
    final showInput = !hasNewOrder && !_hasActiveOrder;

    final insideActions = hasNewOrder ? _insideActionsFor(newOrder) : null;
    final outsideAction = hasNewOrder ? _outsideActionFor(newOrder) : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Legacy loading + top legacy card kept only when no new order.
            if (!hasNewOrder && _isLoadingOrder)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (hasLegacy)
              OrderStatusCard(
                order: _activeOrder!,
                chatId: widget.chatId,
                storeId: widget.storeId,
                storeName: widget.storeName,
                storeImage: widget.storeImage,
                onOrderCancelled: _refreshOrders,
              ),

            // Messages
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesStream, // ── UPGRADED: Reading from the locked memory stream! ──
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)));
                  }

                  final msgDocs = snapshot.data?.docs ?? [];

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: msgDocs.length,
                    itemBuilder: (context, index) {
                      final msgData = msgDocs[index].data() as Map<String, dynamic>;
                      final text = msgData['text'] ?? '';
                      final senderId = msgData['senderId'] ?? '';
                      final isSentByMe = senderId == _user?.uid;

                      return _buildBubble(text, isSentByMe);
                    },
                  );
                },
              ),
            ),

            // Bottom slot: order card + status-specific actions → legacy
            // fallback → plain message input.
            if (hasNewOrder) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: OrderCard(order: newOrder, actions: insideActions),
              ),
              if (outsideAction != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: outsideAction,
                )
              else
                const SizedBox(height: 16),
            ]
            else if (hasLegacy)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _startNewChat,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCDEB45), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '+ Start New Chat',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003E3B),
                      ),
                    ),
                  ),
                ),
              )
            else if (showInput)
              _buildInputRow(),
          ],
        ),
      ),
    );
  }

  /// Buttons rendered INSIDE the card (Pending state only per the spec).
  Widget? _insideActionsFor(OrderCardData order) {
    if (order.status != OrderStatus.pending) return null;
    final isBuyer = _isBuyerOf(order);
    if (isBuyer) {
      return Row(
        children: [
          Expanded(
            child: _PillButton(
              label: 'New chat',
              bg: AppColors.primary,
              fg: AppColors.secondary,
              onTap: _startNewChat,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PillButton(
              label: 'Cancel order',
              bg: AppColors.pendingText,
              fg: AppColors.secondary,
              // TODO(backend): also write a system message into chat saying
              // the buyer cancelled, so the seller's chat shows context.
              onTap: () => _orderRepo.updateStatus(
                order.orderId,
                OrderStatus.cancelled,
              ),
            ),
          ),
        ],
      );
    }
    // Seller pending view.
    return Row(
      children: [
        Expanded(
          child: _PillButton(
            label: 'Accept',
            bg: AppColors.primary,
            fg: AppColors.secondary,
            onTap: () => _orderRepo.updateStatus(
              order.orderId,
              OrderStatus.active,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PillButton(
            label: 'Reject',
            bg: AppColors.pendingText,
            fg: AppColors.secondary,
            onTap: () => _orderRepo.updateStatus(
              order.orderId,
              OrderStatus.rejected,
            ),
          ),
        ),
      ],
    );
  }

  /// Full-width button rendered OUTSIDE the card for non-pending statuses.
  Widget? _outsideActionFor(OrderCardData order) {
    final isBuyer = _isBuyerOf(order);
    switch (order.status) {
      case OrderStatus.pending:
        return null;
      case OrderStatus.active:
        return isBuyer
            ? _FullWidthPill(label: 'Start new chat', onTap: _startNewChat)
            : _FullWidthPill(
                label: 'Ready for Handoff',
                onTap: () => _markReady(order),
              );
      case OrderStatus.ready:
        return isBuyer
            ? _FullWidthPill(
                label: 'Pick up order',
                onTap: () => _openBuyerPickup(order),
              )
            : _FullWidthPill(
                label: 'View pickup code',
                onTap: () => _openSellerPickup(order),
              );
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
      case OrderStatus.completed:
        return isBuyer
            ? _FullWidthPill(label: 'Start new chat', onTap: _startNewChat)
            : null;
    }
  }

  void _markReady(OrderCardData order) {
    _orderRepo.updateStatus(order.orderId, OrderStatus.ready);
    final fresh = _orderRepo.getById(order.orderId) ?? order;
    _openSellerPickup(fresh);
  }

  void _openSellerPickup(OrderCardData order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerOrderPickupPage(order: order),
      ),
    );
  }

  void _openBuyerPickup(OrderCardData order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerPickupCodePage(order: order),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFCDEB45),
            backgroundImage: widget.storeImage.isNotEmpty ? NetworkImage(widget.storeImage) : null,
            child: widget.storeImage.isEmpty
                ? Text(
                    _getInitials(widget.storeName),
                    style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF003E3B)),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiSummarisePage(
                      chatId: widget.chatId,
                      storeId: widget.storeId,
                      storeName: widget.storeName,
                      storeImage: widget.storeImage,
                    ),
                  ),
                );
              },
              child: Text(
                widget.storeName,
                style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Color(0xFF003E3B), size: 22),
            onPressed: _showReportSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isSent) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFFCDEB45) : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSent ? 18 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiSummarisePage(
                    chatId: widget.chatId,
                    storeId: widget.storeId,
                    storeName: widget.storeName,
                    storeImage: widget.storeImage,
                  ),
                ),
              );
            },
            child: Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(color: Color(0xFF003E3B), shape: BoxShape.circle),
              child: Center(
                child: SvgPicture.asset(
                  'assets/Essentials/Added/star.svg',
                  width: 24, height: 24,
                  colorFilter: const ColorFilter.mode(Color(0xFFCDEB45), BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _msgController,
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: const Icon(Icons.send, color: Color(0xFF003E3B), size: 24),
          ),
        ],
      ),
    );
  }
}

// TODO(i18n): Arabic translations needed for the action-button labels used
// below: "New chat", "Cancel order", "Accept", "Reject", "Start new chat",
// "Ready for Handoff", "Pick up order", "View pickup code".

/// Inside-card pill button — half-width Row child. Lime or orange background,
/// dark green text, used for Pending action pairs (New chat / Cancel order,
/// Accept / Reject).
class _PillButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Full-width pill rendered OUTSIDE the card for non-pending statuses.
/// Always lime + dark-green per the mockups.
class _FullWidthPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FullWidthPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.secondary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}