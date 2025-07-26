import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'typing_indicator.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AIPetAssistantCard extends StatefulWidget {
  final VoidCallback onTap;
  final bool isExpanded;

  const AIPetAssistantCard({
    super.key,
    required this.onTap,
    this.isExpanded = false,
  });

  @override
  State<AIPetAssistantCard> createState() => _AIPetAssistantCardState();
}

class _AIPetAssistantCardState extends State<AIPetAssistantCard> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final _uuid = const Uuid();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  static const String _apiKey = 'AIzaSyB32jJtKaieqAx2OLUs0TkXnBJD2zhuilc';
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  ChatMessage? _animatingMessage;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingMessage = null;
        });
        _slideController.reset();
      }
    });

    // Load existing messages
    _loadMessages();
  }

  void _loadMessages() {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId != null) {
      _chatService.getChatMessages(userId).listen((messages) {
        if (mounted) {
          setState(() {
            _messages = messages;
          });
          // Scroll to bottom when new messages are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<String> _fetchGeminiReply(String userMessage) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": "You are a virtual pet dog named Lufi. You are a helpful pet assistant that detects and responds in the same language the user uses. For example, if they write in French, respond in French. If they write in English, respond in English, etc. Focus on giving clear, practical, short, focus on short and supportive pet care advice while maintaining a warm and approachable AND proffessional tone in the user's preferred language. but prioritize being informative and helpful over being playful."
            },
            {"text": userMessage}
          ]
        }
      ]
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final parts = data['candidates'][0]['content']['parts'];
        if (parts != null && parts.isNotEmpty && parts[0]['text'] != null) {
          return parts[0]['text'];
        }
      }
      return 'No response from Gemini.';
    } else {
      return 'Error: ${response.statusCode}\n${response.body}';
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final userMessage = _messageController.text;
    _messageController.clear();

    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return;

    final newMessage = ChatMessage(
      id: _uuid.v4(),
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );

    await _chatService.addMessage(userId, newMessage);
    setState(() {
      _animatingMessage = newMessage;
    });

    // Start animation
    _slideController.forward();

    setState(() {
      _isLoading = true;
    });

    try {
      final reply = await _fetchGeminiReply(userMessage);
      if (mounted) {
        final aiMessage = ChatMessage(
          id: _uuid.v4(),
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        );
        await _chatService.addMessage(userId, aiMessage);
        setState(() {
          _isLoading = false;
          _animatingMessage = aiMessage;
        });
        // Reset and start new animation for AI message
        _slideController.reset();
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ChatMessage(
          id: _uuid.v4(),
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        await _chatService.addMessage(userId, errorMessage);
        setState(() {
          _isLoading = false;
          _animatingMessage = errorMessage;
        });
        // Reset and start new animation for error message
        _slideController.reset();
        _slideController.forward();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isAnimating = _animatingMessage?.id == message.id;
    final messageWidget = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: message.isUser ? Colors.orange : Colors.grey[100],
        borderRadius: message.isUser
            ? BorderRadius.circular(24)  // Pill shape for user messages
            : const BorderRadius.only(  // Chat bubble for AI messages
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: message.isUser ? Colors.white : Colors.black87,
        ),
      ),
    );

    final aiAvatar = Image.asset(
      'assets/images/ai_lufi.png',
      width: 40,
      height: 40,
    );

    Widget finalWidget;
    if (!message.isUser) {
      finalWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          aiAvatar,
          const SizedBox(width: 8),
          Flexible(child: messageWidget),
        ],
      );
    } else {
      finalWidget = messageWidget;
    }

    if (isAnimating) {
      return AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          final slideDistance = message.isUser ? 100.0 : -100.0;
          return Transform.translate(
            offset: Offset(
              (1 - _slideAnimation.value) * slideDistance,
              (1 - _slideAnimation.value) * 50,
            ),
            child: Opacity(
              opacity: _slideAnimation.value,
              child: child,
            ),
          );
        },
        child: finalWidget,
      );
    }

    return finalWidget;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      // Show the last message in the preview if available
      final lastMessage = _messages.isNotEmpty ? _messages.last : null;
      
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            height: 140, // Fixed height for the widget
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/ai_lufi.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                                                         child: Text(
                               lastMessage?.text ?? 'Hi! ask me about any pet advice,\nand I\'ll do my best to help you, and\nyour little one!',
                               style: const TextStyle(
                                 fontSize: 14,
                                 color: Colors.black87,
                               ),
                               maxLines: 5, // Limit to 5 lines
                               overflow: TextOverflow.fade, // Fade out at the end of complete lines
                             ),
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Tap to chat...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onTap,
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/ai_lufi.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Pet Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final userId = context.read<AuthService>().currentUser?.id;
                      if (userId != null) {
                        await _chatService.clearChat(userId);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    key: ValueKey(message.id),
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 16,
                        right: message.isUser ? 4 : 0,
                      ),
                      child: _buildMessageItem(message),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TypingIndicator(),
                ),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 