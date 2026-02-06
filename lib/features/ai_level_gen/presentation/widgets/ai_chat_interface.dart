import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AI chat interface for natural language level creation
class AIChatInterface extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSuggestionSelected;
  final List<String> suggestions;
  
  const AIChatInterface({
    super.key,
    required this.controller,
    required this.onSuggestionSelected,
    required this.suggestions,
  });

  @override
  State<AIChatInterface> createState() => _AIChatInterfaceState();
}

class _AIChatInterfaceState extends State<AIChatInterface>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  late AnimationController _typingController;
  
  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Hi! I\'m your AI level designer. Describe the level you want to create!',
      isAI: true,
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.2),
            border: Border(
              bottom: BorderSide(
                color: Colors.purple.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI ASSISTANT',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _typingController,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(
                        alpha: 0.5 + 0.5 * _typingController.value,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(_messages[index]);
            },
          ),
        ),
        
        // Suggestions
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.suggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(
                    widget.suggestions[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.cyan.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: Colors.cyan.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onSuggestionSelected(widget.suggestions[index]);
                  },
                ),
              );
            },
          ),
        ),
        
        // Input field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            border: Border(
              top: BorderSide(
                color: Colors.cyan.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Describe your level idea...',
                    hintStyle: TextStyle(color: Colors.white30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.cyan),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _sendMessage(widget.controller.text),
                icon: const Icon(Icons.send, color: Colors.cyan),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isAI) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isAI
                    ? Colors.purple.withValues(alpha: 0.2)
                    : Colors.cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (message.isAI ? Colors.purple : Colors.cyan)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (!message.isAI) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.cyan,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  void _sendMessage(String text) {
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isAI: false,
        timestamp: DateTime.now(),
      ));
    });
    
    widget.controller.clear();
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Great idea! I\'ll create a level with ${_extractKeyElements(text)}. Click Generate to see it!',
            isAI: true,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }
  
  String _extractKeyElements(String text) {
    final elements = <String>[];
    
    if (text.contains('portal')) elements.add('portals');
    if (text.contains('magnet')) elements.add('magnetic fields');
    if (text.contains('time')) elements.add('time manipulation');
    if (text.contains('gravity')) elements.add('gravity puzzles');
    if (text.contains('quantum')) elements.add('quantum mechanics');
    
    return elements.isEmpty ? 'exciting physics challenges' : elements.join(', ');
  }
}

class ChatMessage {
  final String text;
  final bool isAI;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isAI,
    required this.timestamp,
  });
}