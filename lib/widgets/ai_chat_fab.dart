import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';

/// Floating AI Chat button + bottom sheet panel, injected by AppShell.
class AiChatFab extends StatefulWidget {
  const AiChatFab({super.key});

  @override
  State<AiChatFab> createState() => _AiChatFabState();
}

class _AiChatFabState extends State<AiChatFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppState>(),
        child: const _ChatPanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(
                    alpha: 0.2 + 0.15 * _pulseController.value),
                blurRadius: 12 + 8 * _pulseController.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: FloatingActionButton.extended(
        onPressed: _openChat,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.smart_toy_outlined, size: 20),
        label: const Text(
          'Ask Narmada AI',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Panel (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _ChatPanel extends StatefulWidget {
  const _ChatPanel();

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const _quickPrompts = [
    ('💧', 'Water Status', 'water status'),
    ('📅', 'Schedule', 'my schedule'),
    ('⚖️', 'Fairness', 'fairness score'),
    ('🚨', 'Shortage', 'shortage risk'),
    ('📊', 'Summary', 'today summary'),
    ('🌾', 'Farmer Help', 'tail end underserved'),
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _inputCtrl.clear();
    context.read<AppState>().sendChatMessage(t);
    Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
    Future.delayed(const Duration(milliseconds: 1200), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final messages = state.chatMessages;
    final typing = state.chatTyping;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(context, state),
            if (messages.isEmpty) _buildWelcome(),
            Expanded(
              child: messages.isEmpty
                  ? _buildQuickPrompts()
                  : _buildMessageList(messages, typing),
            ),
            if (messages.isNotEmpty) _buildQuickChips(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Narmada AI Assistant',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text('Ask me about water, fairness & schedules',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          if (state.chatMessages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
              onPressed: () {
                context.read<AppState>().clearChat();
              },
              tooltip: 'Clear chat',
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.waving_hand, size: 18, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text('Hello! I\'m Narmada AI',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    fontSize: 14)),
          ]),
          const SizedBox(height: 6),
          const Text(
            'I have access to live system data. Ask me about water status, fairness, schedules, alerts, or disputes.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _quickPrompts.map((p) {
          return ActionChip(
            label: Text('${p.$1} ${p.$2}',
                style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
            backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
            side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25)),
            onPressed: () => _send(p.$3),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _quickPrompts.map((p) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text('${p.$1} ${p.$2}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
              backgroundColor: AppTheme.primary.withValues(alpha: 0.07),
              side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
              padding: EdgeInsets.zero,
              onPressed: () => _send(p.$3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageList(List messages, bool typing) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (typing ? 1 : 0),
      itemBuilder: (_, i) {
        if (typing && i == messages.length) {
          return const _TypingIndicator();
        }
        final msg = messages[i];
        return _MessageBubble(message: msg);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              onSubmitted: _send,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ask about water, fairness, schedules...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: AppTheme.surface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primary,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: () => _send(_inputCtrl.text),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser as bool;
    final time = message.timestamp as DateTime;
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 15),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.65)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing indicator
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(3, (i) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600));
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dotControllers[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7 + 4 * _dotControllers[i].value,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(
                          alpha: 0.4 + 0.6 * _dotControllers[i].value),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
