import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Added Auth
import '../data/temp_data.dart'; // Kept for the 'Store' object structure
import 'ai_summarise_page.dart';
import 'store_page.dart';

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
  
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // If an initial message was passed (e.g. from an Order Sheet), send it automatically
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(textOverride: widget.initialMessage);
      });
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to generate initials for the avatar fallback
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

    // 1. Add the message to the sub-collection
    await chatRef.collection('messages').add({
      'text': text,
      'senderId': _user!.uid,
      'timestamp': timestamp,
    });

    // 2. Update (or create) the parent document so the Chats list page updates
    await chatRef.set({
      'buyerId': _user!.uid,
      'storeId': widget.storeId,
      'storeName': widget.storeName,
      'storeImage': widget.storeImage,
      'lastMessage': text,
      'lastMessageTime': timestamp,
    }, SetOptions(merge: true)); // merge: true ensures it updates existing fields or creates if missing
  }

  // Generic method to fetch the Store from Firebase and pass it to either StorePage or AiPage
  Future<void> _fetchStoreAndNavigate(Widget Function(Store) buildTargetPage) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B))),
    );

    try {
      final doc = await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).get();
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (doc.exists) {
        final data = doc.data()!;
        final store = Store(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          description: data['description'] ?? '',
          imagePath: data['imageUrl'] ?? '',
          logoPath: data['logoUrl'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          category: data['category'] ?? '',
          distanceKm: (data['distanceKm'] ?? 0.0).toDouble(),
          products: [],
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => buildTargetPage(store)));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load store: $e')));
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
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                      // ── NEW: FIRESTORE SAVE LOGIC ──
                      onPressed: selectedReason == null
                          ? null
                          : () async {
                              Navigator.pop(ctx); // Close the sheet immediately
                              
                              try {
                                // Push to a new 'reports' collection
                                await FirebaseFirestore.instance.collection('reports').add({
                                  'reporterId': _user?.uid ?? 'unknown_user',
                                  'reportedStoreId': widget.storeId,
                                  'reportedStoreName': widget.storeName,
                                  'chatId': widget.chatId,
                                  'reason': selectedReason,
                                  'details': selectedReason == 'Other' ? otherCtrl.text.trim() : '',
                                  'status': 'pending', // Good for admin dashboards
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            
            // ── DYNAMIC FIRESTORE MESSAGES ──
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false) // Oldest top, newest bottom
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)));
                  }

                  final msgDocs = snapshot.data?.docs ?? [];

                  // Auto-scroll to the bottom when new messages arrive
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
            
            _buildInputRow(),
          ],
        ),
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
          // Navigates to store page
          Expanded(
            child: GestureDetector(
              onTap: () => _fetchStoreAndNavigate((store) => StorePage(store: store)),
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
          // AI sparkle button
          GestureDetector(
            // NOTE: We temporarily removed `chatId: widget.chatId` to prevent the compile error
            onTap: () => _fetchStoreAndNavigate((store) => AiSummarisePage(store: store)),
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