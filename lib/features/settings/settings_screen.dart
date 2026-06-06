import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../services/notifications.dart';
import '../../data/models/ai_config.dart';
import '../../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('SETTINGS')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SectionLabel('Reminders — the force engine'),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.red,
                      title: const Text('Daily timeline notifications'),
                      subtitle: const Text(
                          'Brutal reminders at every block of the day',
                          style: TextStyle(
                              color: AppTheme.textLo, fontSize: 12)),
                      value: s.notificationsEnabled,
                      onChanged: (v) async {
                        await s.setNotifications(v);
                        if (v) {
                          await Notifications.scheduleDaily(s.currentDay);
                        } else {
                          await Notifications.cancelAll();
                        }
                      },
                    ),
                    const Divider(height: 1, color: AppTheme.line),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Test a reminder'),
                      trailing: const Icon(Icons.notifications_active,
                          color: AppTheme.amber),
                      onTap: () => Notifications.buzz(
                          'Build Tracker',
                          'This is your coach. Stop scrolling. Go ship.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SectionLabel('AI providers'),
              const SizedBox(height: 6),
              const Text(
                  'Use any engine you already pay for. Ollama runs free & local on your RTX 4050.',
                  style: TextStyle(color: AppTheme.textLo, fontSize: 12)),
              const SizedBox(height: 12),
              for (final c in s.aiConfigs) ...[
                _ProviderCard(config: c, active: c.provider == s.activeProvider),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 60),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatefulWidget {
  final AiConfig config;
  final bool active;
  const _ProviderCard({required this.config, required this.active});
  @override
  State<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<_ProviderCard> {
  late TextEditingController _url;
  late TextEditingController _key;
  late TextEditingController _model;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.config.baseUrl);
    _key = TextEditingController(text: widget.config.apiKey);
    _model = TextEditingController(text: widget.config.model);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final c = widget.config;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.active ? AppTheme.green : AppTheme.textLo,
                ),
              ),
              const SizedBox(width: 10),
              Text(c.provider.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 14)),
              const Spacer(),
              if (!widget.active)
                TextButton(
                  onPressed: () => s.setActiveProvider(c.provider),
                  child: const Text('Use this'),
                )
              else
                const Text('ACTIVE',
                    style: TextStyle(
                        color: AppTheme.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              IconButton(
                icon: Icon(_open ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _open = !_open),
              ),
            ],
          ),
          if (_open) ...[
            const SizedBox(height: 8),
            TextField(
                controller: _url,
                decoration: const InputDecoration(
                    labelText: 'Base URL', isDense: true)),
            const SizedBox(height: 8),
            if (c.provider != 'ollama')
              TextField(
                  controller: _key,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'API key', isDense: true)),
            if (c.provider != 'ollama') const SizedBox(height: 8),
            if (c.provider == 'openrouter') ...[
              const Text('Free models (no credits used)',
                  style: TextStyle(color: AppTheme.textLo, fontSize: 11)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in AiConfig.freeOpenRouterModels)
                    GestureDetector(
                      onTap: () => setState(() => _model.text = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _model.text == m
                              ? AppTheme.red.withValues(alpha: 0.18)
                              : AppTheme.surfaceHi,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _model.text == m
                                  ? AppTheme.red
                                  : AppTheme.line),
                        ),
                        child: Text(m.split('/').last.replaceAll(':free', ''),
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _model.text == m
                                    ? AppTheme.textHi
                                    : AppTheme.textMid)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            TextField(
                controller: _model,
                decoration: const InputDecoration(
                    labelText: 'Model', isDense: true)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
                onPressed: () {
                  c.baseUrl = _url.text.trim();
                  c.apiKey = _key.text.trim();
                  c.model = _model.text.trim();
                  s.saveAiConfigs();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved')));
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
