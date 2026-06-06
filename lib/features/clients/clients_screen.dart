import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../data/models/client.dart';
import '../../widgets/common.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final clients = s.clients;
    final pipeline =
        clients.fold<int>(0, (sum, c) => sum + (c.isActive ? c.valueRupees : 0));
    final earned = clients
        .where((c) => c.status == 'paid')
        .fold<int>(0, (sum, c) => sum + c.valueRupees);

    return Scaffold(
      appBar: AppBar(title: const Text('CLIENTS')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.red,
        onPressed: () => _edit(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Panel(
                  child: StatTile('₹$pipeline', 'active pipeline',
                      color: AppTheme.amber),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Panel(
                  child: StatTile('₹$earned', 'earned (paid)',
                      color: AppTheme.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (clients.isEmpty)
            Panel(
              child: Column(
                children: [
                  const Icon(Icons.work_outline,
                      color: AppTheme.textLo, size: 40),
                  const SizedBox(height: 12),
                  const Text('No clients yet.',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text(
                      'No client = transformation is the job. Land one and the app flips to client-first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textLo, fontSize: 12, height: 1.4)),
                ],
              ),
            )
          else
            for (final c in clients) ...[
              _ClientCard(client: c, onTap: () => _edit(context, c)),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _edit(BuildContext context, Client? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ClientEditor(existing: existing),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  const _ClientCard({required this.client, required this.onTap});

  Color get _statusColor {
    switch (client.status) {
      case 'active':
        return AppTheme.amber;
      case 'lead':
        return AppTheme.blue;
      case 'delivered':
        return AppTheme.mental;
      case 'paid':
        return AppTheme.green;
      default:
        return AppTheme.textLo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Panel(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  if (client.project.isNotEmpty)
                    Text(client.project,
                        style: const TextStyle(
                            color: AppTheme.textMid, fontSize: 13)),
                  if (client.deadline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('due ${client.deadline}',
                          style: const TextStyle(
                              color: AppTheme.textLo, fontSize: 11)),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${client.valueRupees}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(client.status.toUpperCase(),
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientEditor extends StatefulWidget {
  final Client? existing;
  const _ClientEditor({this.existing});
  @override
  State<_ClientEditor> createState() => _ClientEditorState();
}

class _ClientEditorState extends State<_ClientEditor> {
  late TextEditingController _name;
  late TextEditingController _project;
  late TextEditingController _value;
  late TextEditingController _deadline;
  late TextEditingController _notes;
  late String _status;

  static const _statuses = ['lead', 'active', 'delivered', 'paid', 'lost'];

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _project = TextEditingController(text: c?.project ?? '');
    _value = TextEditingController(text: c?.valueRupees.toString() ?? '');
    _deadline = TextEditingController(text: c?.deadline ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
    _status = c?.status ?? 'lead';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final pad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'New client' : 'Edit client',
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 14),
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 10),
          TextField(
              controller: _project,
              decoration:
                  const InputDecoration(labelText: 'Project / scope')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                    controller: _value,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Value (₹)')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                    controller: _deadline,
                    decoration: const InputDecoration(
                        labelText: 'Deadline (yyyy-mm-dd)')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _statuses.map((st) {
              final on = st == _status;
              return ChoiceChip(
                label: Text(st),
                selected: on,
                onSelected: (_) => setState(() => _status = st),
                selectedColor: AppTheme.red,
                backgroundColor: AppTheme.surfaceHi,
                labelStyle: TextStyle(
                    color: on ? Colors.white : AppTheme.textMid,
                    fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.existing != null)
                IconButton(
                  onPressed: () {
                    s.deleteClient(widget.existing!.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, color: AppTheme.red),
                ),
              Expanded(
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(backgroundColor: AppTheme.red),
                  onPressed: () {
                    final c = Client(
                      id: widget.existing?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _name.text.trim().isEmpty
                          ? 'Unnamed'
                          : _name.text.trim(),
                      project: _project.text.trim(),
                      valueRupees: int.tryParse(_value.text) ?? 0,
                      status: _status,
                      deadline: _deadline.text.trim().isEmpty
                          ? null
                          : _deadline.text.trim(),
                      notes: _notes.text.trim(),
                      createdAtMillis: widget.existing?.createdAtMillis ??
                          DateTime.now().millisecondsSinceEpoch,
                    );
                    s.upsertClient(c);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
