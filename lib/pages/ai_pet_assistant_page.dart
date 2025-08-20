import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class AIPetAssistantPage extends StatefulWidget {
  const AIPetAssistantPage({super.key});

  @override
  State<AIPetAssistantPage> createState() => _AIPetAssistantPageState();
}

class _AIPetAssistantPageState extends State<AIPetAssistantPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final _uuid = const Uuid();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  static const String _apiKey = 'AIzaSyB32jJtKaieqAx2OLUs0TkXnBJD2zhuilc';

  // Streaming animation controllers
  late AnimationController _typingController;
  late AnimationController _fadeController;
  String _streamingText = '';
  bool _isStreaming = false;
  Timer? _scrollTimer; // Timer for periodic scrolling during streaming
  
  // Animation controllers for word fade-in
  final List<AnimationController> _wordAnimationControllers = [];
  final List<Animation<double>> _wordFadeAnimations = [];
  final List<String> _currentWords = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 600), // Much faster typing animation
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _fadeController.dispose();
    
    // Dispose word animation controllers
    for (var controller in _wordAnimationControllers) {
      controller.dispose();
    }
    
    // Cancel scroll timer
    _scrollTimer?.cancel();
    
    super.dispose();
  }
  
  void _disposeWordAnimations() {
    for (var controller in _wordAnimationControllers) {
      controller.dispose();
    }
    _wordAnimationControllers.clear();
    _wordFadeAnimations.clear();
    _currentWords.clear();
  }

  void _loadMessages() {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId != null) {
      _chatService.getChatMessages(userId).listen((messages) {
        if (mounted) {
          setState(() {
            _messages = messages;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      });
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    if (_scrollController.hasClients) {
      if (immediate) {
        // Immediate scroll for streaming animation
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        // Smooth scroll for normal messages
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      }
    }
  }

  Future<String> _fetchGeminiReply(String userMessage) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "You are Lufi, a friendly AI pet assistant. You help with pet care advice, health questions, training tips, and general pet-related queries. Respond in a helpful, warm, and professional manner. Keep responses concise but informative. Detect and respond in the same language the user uses."
            },
            {"text": userMessage}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final parts = data['candidates'][0]['content']['parts'];
          if (parts != null && parts.isNotEmpty && parts[0]['text'] != null) {
            return parts[0]['text'];
          }
        }
        return 'Sorry, I couldn\'t process that request.';
      } else {
        return 'I\'m having trouble connecting right now. Please try again.';
      }
    } catch (e) {
      return 'Network error. Please check your connection and try again.';
    }
  }

  Future<void> _simulateStreamingResponse(String fullText) async {
    // Dispose previous animations
    _disposeWordAnimations();
    
    setState(() {
      _isStreaming = true;
      _streamingText = '';
    });
    
    // Start periodic scrolling during streaming
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isStreaming && mounted) {
        _scrollToBottom(immediate: true);
      }
    });

    final words = fullText.split(' ');
    _currentWords.addAll(words);
    
    // Create animation controllers for each word
    for (int i = 0; i < words.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200), // Faster word fade-in
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
      
      _wordAnimationControllers.add(controller);
      _wordFadeAnimations.add(animation);
    }
    
    // Animate words one by one
    for (int i = 0; i < words.length; i++) {
      if (!mounted || !_isStreaming) break;
      
      // Start the fade-in animation for this word
      _wordAnimationControllers[i].forward();
      
      // Update the streaming text
      setState(() {
        if (i == 0) {
          _streamingText = words[i];
        } else {
          _streamingText += ' ${words[i]}';
        }
      });
      
      // Auto-scroll during streaming with immediate scroll to follow text
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(immediate: true);
      });
      
      // Dynamic delay based on message length - faster for longer messages
      final baseDelay = _currentWords.length > 50 ? 25 : 
                       _currentWords.length > 30 ? 35 : 
                       _currentWords.length > 15 ? 50 : 70;
      await Future.delayed(Duration(milliseconds: baseDelay));
    }

    // Complete the streaming
    _scrollTimer?.cancel();
    _scrollTimer = null;
    
    setState(() {
      _isStreaming = false;
    });
    
    // Final scroll to ensure we're at the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Save the complete message to chat service
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId != null) {
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        text: fullText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      await _chatService.addMessage(userId, assistantMessage);
    }
    
    // Clean up animations after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _disposeWordAnimations();
      }
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    // Clear the input
    _messageController.clear();

    // Save user message
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId != null) {
      final userChatMessage = ChatMessage(
        id: _uuid.v4(),
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      await _chatService.addMessage(userId, userChatMessage);
    }

    setState(() {
      _isLoading = true;
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // Get AI response
      final response = await _fetchGeminiReply(userMessage);
      
      setState(() {
        _isLoading = false;
        _isTyping = false;
      });

      // Start streaming animation
      await _simulateStreamingResponse(response);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isTyping = false;
      });
    }
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI Avatar with Lufi's image
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.5),
                child: Image.asset(
                  'assets/images/ai_lufi.png',
                  width: 29,
                  height: 29,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.5),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFFFF9800)
                    : Colors.grey[100],
                borderRadius: message.isUser
                    ? BorderRadius.circular(25) // Pill-shaped for user messages
                    : BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: const Radius.circular(4),
                        bottomRight: const Radius.circular(20),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          // User avatar removed - showing only message content
        ],
      ),
    );
  }

  Widget _buildStreamingMessage() {
    if (!_isStreaming) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar with Lufi's image
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Image.asset(
                'assets/images/ai_lufi.png',
                width: 29,
                height: 29,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.5),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Streaming message bubble with animated words - expands dynamically
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), // Smooth expansion animation
              curve: Curves.easeOut,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: _streamingText.isEmpty ? 50 : 0, // Small minimum width when empty
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildAnimatedStreamingText(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedStreamingText() {
    // Show only the text that has been streamed so far
    if (_streamingText.isEmpty) {
      return const Text(
        '▊', // Just show cursor when starting
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.4,
        ),
      );
    }
    
    if (_currentWords.isEmpty) {
      return Text(
        '$_streamingText${_isStreaming ? '▊' : ''}',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.4,
        ),
      );
    }
    
    // Only show words that have been streamed (up to current _streamingText length)
    final streamedWords = _streamingText.split(' ');
    final wordsToShow = streamedWords.length;
    
    return Wrap(
      children: _currentWords.asMap().entries.where((entry) => entry.key < wordsToShow).map((entry) {
        final index = entry.key;
        final word = entry.value;
        
        if (index >= _wordFadeAnimations.length) {
          return Text(
            '$word ',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.4,
            ),
          );
        }
        
        return AnimatedBuilder(
          animation: _wordFadeAnimations[index],
          builder: (context, child) {
            return AnimatedOpacity(
              opacity: _wordFadeAnimations[index].value,
              duration: const Duration(milliseconds: 100), // Faster opacity animation
              child: Transform.translate(
                offset: Offset(0, (1 - _wordFadeAnimations[index].value) * 10),
                child: Text(
                  index == wordsToShow - 1 && _isStreaming 
                      ? '$word▊' 
                      : '$word ',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // AI Avatar with Lufi's image
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Image.asset(
                'assets/images/ai_lufi.png',
                width: 29,
                height: 29,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.5),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.3;
                    final animationValue = (_typingController.value - delay).clamp(0.0, 1.0);
                    final opacity = (animationValue * 2).clamp(0.0, 1.0);
                    
                    return Container(
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      child: AnimatedOpacity(
                        opacity: opacity > 1 ? 2 - opacity : opacity,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.5),
                child: Image.asset(
                  'assets/images/ai_lufi.png',
                  width: 33,
                  height: 33,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.5),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lufi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'AI Pet Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
            onPressed: () async {
              final userId = context.read<AuthService>().currentUser?.id;
              if (userId != null) {
                await _chatService.clearChat(userId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0) + (_isStreaming ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessage(_messages[index]);
                } else if (_isStreaming && index == _messages.length) {
                  return _buildStreamingMessage();
                } else if (_isTyping) {
                  return _buildTypingIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask Lufi about your pet...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CupertinoActivityIndicator(
                                color: Colors.white,
                                radius: 10,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
