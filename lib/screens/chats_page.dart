// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'inner_chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // Create a mutable copy of chat threads
  List<ChatThread> _chatThreads = [];

  @override
  void initState() {
    super.initState();
    // Copy the data from tempChatThreads to make it mutable
    _chatThreads = List.from(tempChatThreads);
  }

  // Function to delete a chat thread
  void _deleteChat(int index) {
    setState(() {
      _chatThreads.removeAt(index);
    });
    
    // Show a snackbar to confirm deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat deleted'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // TODO: Later, also delete from Firebase
  }

  // Function to mark chat as read when pressed
  void _markChatAsRead(int index) {
    setState(() {
      final thread = _chatThreads[index];
      // Create a new ChatThread with unreadCount set to 0
      _chatThreads[index] = ChatThread(
        id: thread.id,
        contactName: thread.contactName,
        initials: thread.initials,
        lastMessage: thread.lastMessage,
        timeAgo: thread.timeAgo,
        unreadCount: 0, // Set to 0
        isOnline: thread.isOnline,
        storeId: thread.storeId,
        messages: thread.messages,
      );
    });
    
    // TODO: Later, also update read status in Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
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

            // ── Chat list ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _chatThreads.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final thread = _chatThreads[index];
                  // Wrap each item with Dismissible for swipe-to-delete
                  return Dismissible(
                    key: Key(thread.contactName),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteChat(index);
                    },
                    child: _buildChatRow(context, thread, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRow(BuildContext context, ChatThread thread, int index) {
    return GestureDetector(
      onTap: () {
        // Mark chat as read before navigating
        _markChatAsRead(index);
        
        // Navigate to chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InnerChatPage(chatThread: _chatThreads[index]),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // ── Avatar with online indicator ──
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFCDEB45),
                    child: Text(
                      thread.initials,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003E3B),
                      ),
                    ),
                  ),
                  if (thread.isOnline)
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

            // ── Name + last message ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.contactName,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage,
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

            // ── Time + unread badge ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  thread.timeAgo,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                if (thread.unreadCount > 0) ...[
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
                        '${thread.unreadCount}',
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