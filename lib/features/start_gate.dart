import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/plan_data.dart';
import '../state/app_state.dart';
import '../services/notifications.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// The arming screen. The app is dark until Build commits. There is a START
/// button and nothing else — no pause, no stop. Once armed, the clock runs to
/// day 21 and cannot be turned off.
class StartGate extends StatefulWidget {
  const StartGate({super.key});
  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  late DateTime _start;
  bool _arming = false;

  @override
  void initState() {
    super.initState();
    // Default chosen by Build: tomorrow 05:30.
    final t = DateTime.now().add(const Duration(days: 1));
    _start = DateTime(t.year, t.month, t.day, 5, 30);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (d != null) {
      setState(() => _start = DateTime(d.year, d.month, d.day, 5, 30));
    }
  }

  Future<void> _start_() async {
    setState(() => _arming = true);
    final s = context.read<AppState>();
    await s.startProtocol(_start);
    if (s.notificationsEnabled) {
      await Notifications.scheduleDaily(s.currentDay);
    }
    // Root rebuilds into the Shell automatically via notifyListeners.
  }

  bool get _isTomorrow {
    final t = DateTime.now().add(const Duration(days: 1));
    return _start.year == t.year && _start.month == t.month && _start.day == t.day;
  }

  @override
  Widget build(BuildContext context) {
    final label = _isTomorrow
        ? 'Day 1 begins tomorrow, 05:30'
        : 'Day 1 begins ${DateFormat('EEE d MMM').format(_start)}, 05:30';
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('THE 21-DAY REBUILD',
                  style: TextStyle(
                      color: AppTheme.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              const Text('You haven’t started yet.',
                  style: TextStyle(
                      color: AppTheme.textHi,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      height: 1.1)),
              const SizedBox(height: 8),
              const Text(
                  'Once you press START there is no pause and no stop. The clock runs to Day 21. Choose the morning, then commit.',
                  style: TextStyle(
                      color: AppTheme.textMid, fontSize: 14, height: 1.4)),
              const SizedBox(height: 24),
              const SectionLabel('THE LAW'),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < PlanData.dailyLaws.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 16, color: AppTheme.line),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}',
                              style: const TextStyle(
                                  color: AppTheme.red,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(PlanData.dailyLaws[i],
                                style: const TextStyle(
                                    color: AppTheme.textHi,
                                    fontSize: 13.5,
                                    height: 1.35)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textMid,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: _arming ? null : _pickDate,
                  child: const Text('Pick another morning'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _arming ? null : _start_,
                  child: _arming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('START — LOCK ME IN',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.5,
                              color: Colors.black)),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text('No pause. No stop. Build. Ship. Report.',
                    style: TextStyle(color: AppTheme.textLo, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
