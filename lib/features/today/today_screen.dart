import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/plan_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../data/models/task_item.dart';
import '../../widgets/common.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final day = s.today;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
              'DAY ${s.currentDay < 1 ? 1 : s.currentDay} / ${PlanData.totalDays}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${s.daysRemaining} left',
                  style: const TextStyle(
                      color: AppTheme.textMid, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _OneThingCard(),
              const SizedBox(height: 16),
              _PriorityBanner(s: s),
              const SizedBox(height: 16),
              _DayProgress(completion: day.completion),
              const SizedBox(height: 16),
              const _MorningCheckIn(),
              const SizedBox(height: 16),
              ..._categories(context, s),
              const SizedBox(height: 16),
              const _EveningReport(),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _categories(BuildContext context, AppState s) {
    const order = ['financial', 'deepwork', 'physical', 'mental'];
    const titles = {
      'financial': 'FINANCIAL — pays rent',
      'deepwork': 'DEEP WORK',
      'physical': 'PHYSICAL',
      'mental': 'MENTAL',
    };
    final out = <Widget>[];
    for (final cat in order) {
      final tasks = s.today.tasks.where((t) => t.category == cat).toList();
      out.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            SectionLabel(titles[cat]!, color: AppTheme.categoryColor(cat)),
            const Spacer(),
            Text('${s.today.completedCount(cat)}/${s.today.totalCount(cat)}',
                style: const TextStyle(
                    color: AppTheme.textLo,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ),
      ));
      out.add(Panel(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < tasks.length; i++) ...[
              _TaskRow(task: tasks[i]),
              if (i < tasks.length - 1)
                const Divider(height: 1, color: AppTheme.line),
            ],
          ],
        ),
      ));
      out.add(const SizedBox(height: 8));
    }
    return out;
  }
}

/// THE ONE THING — the single locked focus. Ankit's fatal pattern is switching
/// ideas/languages and never finishing; this card exists to stop that. Once
/// locked it shows as immovable; changing it requires a deliberate confirm.
class _OneThingCard extends StatefulWidget {
  const _OneThingCard();
  @override
  State<_OneThingCard> createState() => _OneThingCardState();
}

class _OneThingCardState extends State<_OneThingCard> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _confirmChange(BuildContext context, AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Change THE ONE THING?'),
        content: const Text(
            'Switching focus is the exact pattern that has cost you years. '
            'Only change this if the current one is genuinely shipped or dead — '
            'never because it got hard.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep it')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change anyway',
                style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      _c.text = s.profile.oneThing;
      s.setOneThing('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final locked = s.profile.locked;

    if (locked) {
      return Panel(
        color: AppTheme.red.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.red, size: 16),
                const SizedBox(width: 8),
                const SectionLabel('THE ONE THING', color: AppTheme.red),
                const Spacer(),
                GestureDetector(
                  onTap: () => _confirmChange(context, s),
                  child: const Icon(Icons.edit_outlined,
                      color: AppTheme.textLo, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(s.profile.oneThing,
                style: const TextStyle(
                    color: AppTheme.textHi,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.25)),
            const SizedBox(height: 8),
            Text('${s.profile.language} only. No new ideas. No switching. Ship this.',
                style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
          ],
        ),
      );
    }

    return Panel(
      color: AppTheme.red.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_open, color: AppTheme.amber, size: 16),
              SizedBox(width: 8),
              SectionLabel('LOCK YOUR ONE THING', color: AppTheme.amber),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'One project. One goal. The thing you will finish before anything new. Lock it.',
              style: TextStyle(color: AppTheme.textMid, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'e.g. Ship BuildTracker to my phone, in Python tooling',
                isDense: true),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
              icon: const Icon(Icons.lock, size: 18),
              label: const Text('LOCK IT IN'),
              onPressed: () {
                final v = _c.text.trim();
                if (v.isNotEmpty) s.setOneThing(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBanner extends StatelessWidget {
  final AppState s;
  const _PriorityBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    final client = s.clientMode;
    final color = client ? AppTheme.amber : AppTheme.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(client ? Icons.work : Icons.local_fire_department,
                  color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.priorityHeadline,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.nextAction,
              style: const TextStyle(
                  color: AppTheme.textHi,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.3)),
        ],
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  final double completion;
  const _DayProgress({required this.completion});

  @override
  Widget build(BuildContext context) {
    final pct = (completion * 100).round();
    final color = pct >= 80
        ? AppTheme.green
        : pct >= 40
            ? AppTheme.amber
            : AppTheme.red;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$pct%',
                  style: TextStyle(
                      color: color,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('day won',
                    style:
                        TextStyle(color: AppTheme.textLo, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Bar(completion, color: color),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final TaskItem task;
  const _TaskRow({required this.task});

  Future<void> _pickProof(BuildContext context) async {
    final s = context.read<AppState>();
    final picker = ImagePicker();
    final shot = await picker.pickImage(
        source: ImageSource.camera, maxWidth: 1280, imageQuality: 70);
    if (shot != null) s.setTaskProof(task.id, shot.path);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final color = AppTheme.categoryColor(task.category);

    if (task.isCount) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  if (task.target > 0) ...[
                    const SizedBox(height: 6),
                    Bar(task.progress, color: color, height: 5),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Stepper(
              value: task.value,
              target: task.target,
              done: task.isComplete,
              onMinus: () => s.setTaskCount(task.id, task.value - 1),
              onPlus: () => s.setTaskCount(task.id, task.value + 1),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => s.toggleTask(task.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              task.done ? Icons.check_circle : Icons.circle_outlined,
              color: task.done ? AppTheme.green : AppTheme.textLo,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: task.done ? AppTheme.textMid : AppTheme.textHi,
                        decoration:
                            task.done ? TextDecoration.lineThrough : null,
                      )),
                  if (task.hint.isNotEmpty)
                    Text(task.hint,
                        style: const TextStyle(
                            color: AppTheme.textLo, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                task.proofPath != null
                    ? Icons.photo_camera
                    : Icons.photo_camera_outlined,
                size: 18,
                color: task.proofPath != null
                    ? AppTheme.green
                    : AppTheme.textLo,
              ),
              tooltip: 'Photo proof',
              onPressed: () => _pickProof(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final int target;
  final bool done;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _Stepper({
    required this.value,
    required this.target,
    required this.done,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceHi,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _btn(Icons.remove, onMinus),
          SizedBox(
            width: 44,
            child: Text(
              target > 0 ? '$value/$target' : '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: done ? AppTheme.green : AppTheme.textHi,
              ),
            ),
          ),
          _btn(Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _btn(IconData i, VoidCallback f) => IconButton(
        icon: Icon(i, size: 18),
        onPressed: f,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      );
}

class _MorningCheckIn extends StatefulWidget {
  const _MorningCheckIn();
  @override
  State<_MorningCheckIn> createState() => _MorningCheckInState();
}

class _MorningCheckInState extends State<_MorningCheckIn> {
  late final TextEditingController _weight;
  late final TextEditingController _income;
  late final TextEditingController _build;

  @override
  void initState() {
    super.initState();
    final d = context.read<AppState>().today;
    _weight = TextEditingController(text: d.weight?.toString() ?? '');
    _income = TextEditingController(text: d.incomeTask);
    _build = TextEditingController(text: d.buildGoal);
  }

  @override
  void dispose() {
    _weight.dispose();
    _income.dispose();
    _build.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final d = s.today;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('☀ Morning check-in'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _weight,
                  decoration: const InputDecoration(
                      labelText: 'Weight (kg)', isDense: true),
                  onChanged: (v) => s.setWeight(double.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              _Toggle(
                label: 'Weed-free',
                value: d.weedFree,
                onChanged: s.setWeedFree,
                onColor: AppTheme.green,
                offColor: AppTheme.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Sleep quality',
              style: TextStyle(color: AppTheme.textMid, fontSize: 12)),
          const SizedBox(height: 6),
          Rating(value: d.sleepQuality, onChanged: s.setSleep),
          const SizedBox(height: 12),
          const Text('Energy',
              style: TextStyle(color: AppTheme.textMid, fontSize: 12)),
          const SizedBox(height: 6),
          Rating(value: d.energy, onChanged: s.setEnergy),
          const SizedBox(height: 14),
          TextField(
            controller: _income,
            decoration: const InputDecoration(
                labelText: "Today's ONE income task", isDense: true),
            onChanged: s.setIncomeTask,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _build,
            decoration: const InputDecoration(
                labelText: "Today's ONE build/ship goal", isDense: true),
            onChanged: s.setBuildGoal,
          ),
        ],
      ),
    );
  }
}

class _EveningReport extends StatefulWidget {
  const _EveningReport();
  @override
  State<_EveningReport> createState() => _EveningReportState();
}

class _EveningReportState extends State<_EveningReport> {
  late final TextEditingController _blocker;

  @override
  void initState() {
    super.initState();
    _blocker = TextEditingController(text: context.read<AppState>().today.blocker);
  }

  @override
  void dispose() {
    _blocker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final d = s.today;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('🌙 Evening report'),
          const SizedBox(height: 14),
          _Toggle(
            label: 'Income task shipped',
            value: d.incomeShipped,
            onChanged: s.setIncomeShipped,
            onColor: AppTheme.green,
            offColor: AppTheme.surfaceHi,
            wide: true,
          ),
          const SizedBox(height: 8),
          _Toggle(
            label: 'Build goal shipped',
            value: d.buildShipped,
            onChanged: s.setBuildShipped,
            onColor: AppTheme.green,
            offColor: AppTheme.surfaceHi,
            wide: true,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _blocker,
            decoration: const InputDecoration(
                labelText: 'Where I leaked time / what blocked me',
                isDense: true),
            onChanged: s.setBlocker,
          ),
          const SizedBox(height: 16),
          const Text('Day verdict',
              style: TextStyle(color: AppTheme.textMid, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              _verdict(context, s, 'won', 'WON', AppTheme.green),
              const SizedBox(width: 8),
              _verdict(context, s, 'partial', 'PARTIAL', AppTheme.amber),
              const SizedBox(width: 8),
              _verdict(context, s, 'lost', 'LOST', AppTheme.red),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                    d.reported ? AppTheme.green : AppTheme.surfaceHi,
                foregroundColor: d.reported ? Colors.black : AppTheme.textHi,
              ),
              onPressed: () => s.setReported(!d.reported),
              icon: Icon(d.reported ? Icons.check : Icons.send),
              label: Text(d.reported ? 'Reported ✓' : 'Mark reported to Claude'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verdict(
      BuildContext context, AppState s, String key, String label, Color c) {
    final on = s.today.verdict == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => s.setVerdict(on ? '' : key),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? c : AppTheme.surfaceHi,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              style: TextStyle(
                  color: on ? Colors.black : AppTheme.textLo,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color onColor;
  final Color offColor;
  final bool wide;
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onColor,
    required this.offColor,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: wide ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? onColor.withValues(alpha: 0.18) : offColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: value ? onColor : AppTheme.line, width: 1),
        ),
        child: Row(
          mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(value ? Icons.check_circle : Icons.circle_outlined,
                size: 18, color: value ? onColor : AppTheme.textLo),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: value ? AppTheme.textHi : AppTheme.textMid)),
          ],
        ),
      ),
    );
  }
}
