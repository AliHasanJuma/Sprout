import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'dart:async'; // ── ADDED FOR STREAM SUBSCRIPTION ──
import 'inner_chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

// ── 1. ADDED MEMORY LOCK MIXIN ──
class _ChatsPageState extends State<ChatsPage> with AutomaticKeepAliveClientMixin {
  
  // ── 2. KEEP ALIVE SET TO TRUE ──
  @override
  bool get wantKeepAlive => true;

  User? get _user => FirebaseAuth.instance.currentUser;
  
  // ── NEW: State variables to hold data securely ──
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  List<QueryDocumentSnapshot> _chatDocs = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _listenToChats(); // Start the background listener
  }

  @override
  void dispose() {
    _chatSubscription?.cancel(); // Always clean up listeners!
    super.dispose();
  }

  // ── 3. THE HYBRID FETCH: Background Real-time Listener ──
  void _listenToChats() async {
    final uid = _user?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    String? myStoreId;
    try {
      // 1. Fetch the user's profile to see if they have a storeId linked to their account
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        myStoreId = userData['storeId'];
      }
      
      // 2. Fallback: Check the stores collection if ownerId is tracked there
      if (myStoreId == null) {
        final storeQuery = await FirebaseFirestore.instance
            .collection('stores')
            .where('ownerId', isEqualTo: uid)
            .limit(1)
            .get();
        if (storeQuery.docs.isNotEmpty) {
          myStoreId = storeQuery.docs.first.id;
        }
      }
    } catch (e) {
      print("Error fetching store credentials: $e");
    }

    // 3. Construct an OR query targeting buyerId OR your custom storeId
    final chatQuery = FirebaseFirestore.instance.collection('chats').where(
      Filter.or(
        Filter('buyerId', isEqualTo: uid),
        myStoreId != null 
            ? Filter('storeId', isEqualTo: myStoreId)
            : Filter('storeId', isEqualTo: 'no_store_placeholder'), // Prevents empty query crashes
      )
    );

    _chatSubscription = chatQuery
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            _chatDocs = snapshot.docs;
            _isLoading = false;
            _hasError = false;
          });
        }
      },
      onError: (error) {
        print("Chat listing subscription failed: $error");
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      },
    );
  }

  // ── 4. PULL-TO-REFRESH HANDLER ──
  Future<void> _handleRefresh() async {
    // Because the stream is already keeping data perfectly up-to-date, 
    // we just add a small delay to give the user the visual satisfaction of a refresh!
    await Future.delayed(const Duration(milliseconds: 600));
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  void _confirmDelete(String chatId, String contactName) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Color(0xFFEF4444), size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Conversation',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your conversation with $contactName will be removed from your chats.',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteChat(chatId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete Conversation',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDEDEDE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat deleted'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ── REQUIRED FOR KEEPALIVE ──

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ── 5. WRAPPED IN REFRESH INDICATOR ──
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF003E3B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 24, top: 24, bottom: 8),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              
              // ── DYNAMIC UI BASED ON LOCAL STATE ──
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)))
                    : _hasError
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              alignment: Alignment.center,
                              child: const Text(
                                'Error loading chats.\nPlease check database indexes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'SF Pro Display', color: Colors.red),
                              ),
                            ),
                          )
                        : _chatDocs.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'No active chats.',
                                    style: TextStyle(fontFamily: 'SF Pro Display', color: Color(0xFF9F9F9F)),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _chatDocs.length,
                                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                itemBuilder: (context, index) {
                                  final data = _chatDocs[index].data() as Map<String, dynamic>;
                                  final chatId = _chatDocs[index].id;

                                  return Dismissible(
                                    key: ValueKey(chatId),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      child: const Icon(Icons.delete, color: Colors.white, size: 28),
                                    ),
                                    confirmDismiss: (_) async {
                                      _confirmDelete(chatId, data['storeName'] ?? 'Unknown');
                                      return false; 
                                    },
                                    child: _buildChatRow(context, data, chatId),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildChatRow(BuildContext context, Map<String, dynamic> data, String chatId) {
  final uid = _user?.uid;
  
  // ── CHECK IF LOGGED-IN USER IS THE BUYER ──
  final bool isBuyer = data['buyerId'] == uid;

  // If buyer, show the store details. If seller, show the customer's details!
  final displayOriginName = isBuyer 
      ? (data['storeName'] ?? 'Unknown Store') 
      : (data['buyerName'] ?? 'Customer');
      
  final displayImage = isBuyer 
      ? (data['storeImage'] ?? '') 
      : (data['buyerImage'] ?? '');

  final lastMessage = data['lastMessage'] ?? '';
  final timeAgo = _formatTime(data['lastMessageTime'] as Timestamp?);
  final unreadCount = data['unreadCount'] ?? 0;
  final storeId = data['storeId'] ?? '';
  final isOnline = data['isOnline'] ?? false; 

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InnerChatPage(
          chatId: chatId,
          storeId: storeId,
          storeName: data['storeName'] ?? 'Store', // Keep original store context for internal processing
          storeImage: data['storeImage'] ?? '',
        ),
      ),
    ),
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFCDEB45),
                  backgroundImage: displayImage.isNotEmpty ? NetworkImage(displayImage) : null,
                  child: displayImage.isEmpty
                      ? Text(
                          _getInitials(displayOriginName),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003E3B),
          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayOriginName, // Shows Store Name to Buyer, and Customer Name to Seller!
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastMessage,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 6),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCDEB45),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003E3B),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
}