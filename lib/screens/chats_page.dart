import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'inner_chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late List<ChatThread> _threads;

  @override
  void initState() {
    super.initState();
    _threads = List.from(tempChatThreads);
  }

  void _confirmDelete(int index) {
    final thread = _threads[index];

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
                  'Your conversation with ${thread.contactName} will be removed from your chats.',
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
                      _deleteChat(index, thread);
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

  void _deleteChat(int index, ChatThread thread) {
    setState(() {
      _threads.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat deleted'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _threads.insert(index, thread);
            });
          },
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _threads.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final thread = _threads[index];
                  return Dismissible(
                    key: ValueKey(thread.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 28),
                    ),
                    confirmDismiss: (_) async {
                      _confirmDelete(index);
                      return false; // We handle deletion manually
                    },
                    child: _buildChatRow(context, thread),
                  );
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
