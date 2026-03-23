// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/temp_data.dart';
import 'ai_summarise_page.dart';

class InnerChatPage extends StatefulWidget {
  final ChatThread chatThread;

  const InnerChatPage({super.key, required this.chatThread});

  @override
  State<InnerChatPage> createState() => _InnerChatPageState();
}

class _InnerChatPageState extends State<InnerChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.chatThread.messages);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isSentByMe: true,
        timeAgo: 'now',
      ));
    });
    _msgController.clear();

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            _buildTopBar(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // ── Messages ──
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildBubble(_messages[index]);
                },
              ),
            ),

            // ── Input row ──
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
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF003E3B), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFCDEB45),
            child: Text(
              widget.chatThread.initials,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003E3B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.chatThread.contactName,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final isSent = message.isSentByMe;
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
          message.text,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 15,
            color: Colors.black,
          ),
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
            onTap: () {
              // Find the store for this chat
              final store = tempStores.firstWhere(
                (s) => s.id == widget.chatThread.storeId,
                orElse: () => tempStores.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiSummarisePage(store: store),
                ),
              );
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF003E3B),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/Essentials/Added/star.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFCDEB45),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(
              Icons.send,
              color: Color(0xFF003E3B),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
