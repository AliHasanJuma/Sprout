// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'inner_chat_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

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
                itemCount: tempChatThreads.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final thread = tempChatThreads[index];
                  return _buildChatRow(context, thread);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRow(BuildContext context, ChatThread thread) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InnerChatPage(chatThread: thread),
        ),
      ),
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
