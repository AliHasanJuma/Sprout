import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/temp_data.dart';
import 'ai_summarise_page.dart';
import 'store_page.dart';

class InnerChatPage extends StatefulWidget {
  final ChatThread chatThread;
  final String? initialMessage;

  const InnerChatPage({super.key, required this.chatThread, this.initialMessage});

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

    // If an initial message was passed (e.g. from order), send it immediately
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _messages.add(ChatMessage(
        text: widget.initialMessage!,
        isSentByMe: true,
        timeAgo: 'now',
      ));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
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

  void _navigateToStore() {
    final store = tempStores.firstWhere(
      (s) => s.id == widget.chatThread.storeId,
      orElse: () => tempStores.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StorePage(store: store)),
    );
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
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Report this chat',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reason options
                  ...['Spam', 'Harassment', 'Inappropriate content', 'Fraud', 'Other']
                      .map((reason) => RadioListTile<String>(
                            title: Text(
                              reason,
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 15,
                              ),
                            ),
                            value: reason,
                            groupValue: selectedReason,
                            activeColor: const Color(0xFF003E3B),
                            onChanged: (val) {
                              setSheetState(() => selectedReason = val);
                            },
                          )),
                  // Other text field
                  if (selectedReason == 'Other') ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                      ),
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
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Report submitted. We\'ll review it shortly.'),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit Report',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedReason == null
                              ? const Color(0xFF9F9F9F)
                              : Colors.white,
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
          // Tappable username → navigates to store page
          Expanded(
            child: GestureDetector(
              onTap: _navigateToStore,
              child: Text(
                widget.chatThread.contactName,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Report button
          IconButton(
            icon: const Icon(Icons.flag_outlined,
                color: Color(0xFF003E3B), size: 22),
            onPressed: _showReportSheet,
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
