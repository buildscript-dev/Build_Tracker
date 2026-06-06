import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../data/ai_service.dart';
import '../../data/models/ai_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending) return;
    final s = context.read<AppState>();
    _input.clear();
    setState(() => _sending = true);
    await s.addChatMessage(ChatMessage('user', text));
    _jump();
    try {
      final reply = await AiService.chat(
        config: s.activeConfig,
        history: s.chat,
        system: s.coachSystemPrompt(),
      );
      await s.addChatMessage(ChatMessage('assistant', reply));
    } catch (e) {
      await s.addChatMessage(ChatMessage('assistant',
          '⚠ Could not reach ${s.activeProvider}. $e\n\nCheck Settings → AI (key / base URL / model).'));
    }
    setState(() => _sending = false);
    _jump();
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('COACH'),
        actions: [
          _ProviderPicker(),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: s.chat.isEmpty ? null : s.clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: s.chat.isEmpty
                ? _EmptyChat(onTap: (p) => _send(p))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: s.chat.length,
                    itemBuilder: (_, i) => _Bubble(msg: s.chat[i]),
                  ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('coach is thinking…',
                  style: TextStyle(color: AppTheme.textLo, fontSize: 12)),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                          hintText: 'Ask your coach. Get the brutal truth.'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    backgroundColor: AppTheme.red,
                    onPressed: _send,
                    child: const Icon(Icons.send, size: 18),
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

class _ProviderPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: s.activeProvider,
        dropdownColor: AppTheme.surfaceHi,
        style: const TextStyle(
            color: AppTheme.textHi, fontWeight: FontWeight.w700, fontSize: 13),
        items: s.aiConfigs
            .map((c) => DropdownMenuItem(
                value: c.provider, child: Text(c.provider)))
            .toList(),
        onChanged: (v) => v == null ? null : s.setActiveProvider(v),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _EmptyChat({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final prompts = [
      'Roast my day. Where am I leaking time?',
      'Write me a cold DM for a local restaurant.',
      'I want to skip training. Talk me out of it.',
      "I'm thinking of switching to a new project. Stop me.",
      "What's my single most important task right now?",
    ];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.forum, size: 48, color: AppTheme.textLo),
        const SizedBox(height: 16),
        const Center(
          child: Text('Your coach knows today',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text('via ${s.activeProvider} · ${s.activeConfig.model}',
              style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
        ),
        const SizedBox(height: 24),
        for (final p in prompts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap(p),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(p,
                          style: const TextStyle(
                              color: AppTheme.textMid, fontSize: 13)),
                    ),
                    const Icon(Icons.arrow_forward,
                        size: 14, color: AppTheme.textLo),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.red.withValues(alpha: 0.18) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isUser ? AppTheme.red.withValues(alpha: 0.4) : AppTheme.line),
        ),
        child: Text(msg.content,
            style: const TextStyle(fontSize: 14, height: 1.4)),
      ),
    );
  }
}
