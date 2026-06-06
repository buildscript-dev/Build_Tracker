import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'today/today_screen.dart';
import 'plan/plan_screen.dart';
import 'clients/clients_screen.dart';
import 'chat/chat_screen.dart';
import 'stats/stats_screen.dart';
import 'settings/settings_screen.dart';

/// Responsive frame: bottom NavigationBar on narrow (phone/watch-ish),
/// side NavigationRail on wide (web/desktop). Same screens everywhere.
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  final _dests = const [
    _Dest('Today', Icons.bolt),
    _Dest('Plan', Icons.flag),
    _Dest('Clients', Icons.work),
    _Dest('Coach', Icons.forum),
    _Dest('Stats', Icons.insights),
    _Dest('Settings', Icons.settings),
  ];

  Widget _page(int i) {
    switch (i) {
      case 0:
        return const TodayScreen();
      case 1:
        return const PlanScreen();
      case 2:
        return const ClientsScreen();
      case 3:
        return const ChatScreen();
      case 4:
        return const StatsScreen();
      default:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 720;
    final body = _page(_i);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width >= 1000,
              backgroundColor: AppTheme.surface,
              selectedIndex: _i,
              onDestinationSelected: (v) => setState(() => _i = v),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.fitness_center, color: AppTheme.red),
              ),
              destinations: _dests
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1, color: AppTheme.line),
            Expanded(child: SafeArea(child: body)),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: _dests
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _Dest {
  final String label;
  final IconData icon;
  const _Dest(this.label, this.icon);
}
