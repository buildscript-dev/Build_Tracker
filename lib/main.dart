import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/storage.dart';
import 'state/app_state.dart';
import 'services/notifications.dart';
import 'theme/app_theme.dart';
import 'features/shell.dart';
import 'features/start_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = Storage();
  await storage.init();
  await Notifications.init();

  final state = AppState(storage);
  await state.load();

  if (state.notificationsEnabled && state.started) {
    await Notifications.scheduleDaily(state.currentDay);
  }

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const BuildTrackerApp(),
    ),
  );
}

class BuildTrackerApp extends StatelessWidget {
  const BuildTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const _Root(),
    );
  }
}

/// Gates the whole app behind the START button. Until armed, only the
/// StartGate is reachable — no way into the protocol without committing.
class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    final started = context.select<AppState, bool>((s) => s.started);
    return started ? const Shell() : const StartGate();
  }
}
