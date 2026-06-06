import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/plan_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../data/models/day_log.dart';
import '../../widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final days = s.history();
    final won = days.where((d) => d.verdict == 'won').length;
    final weights = days
        .where((d) => d.weight != null)
        .map((d) => MapEntry(d.day, d.weight!))
        .toList();
    final cleanDays = days.where((d) => d.weedFree).length;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('STATS')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Expanded(
                    child: Panel(
                        child: StatTile('${s.streakReported}', 'day streak',
                            color: AppTheme.red)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Panel(
                        child: StatTile('$won', 'days won',
                            color: AppTheme.green)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Panel(
                        child: StatTile(
                            '${s.currentDay < 1 ? 0 : s.currentDay}/${PlanData.totalDays}',
                            'progress',
                            color: AppTheme.amber)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Panel(
                        child: StatTile('$cleanDays', 'weed-free days',
                            color: AppTheme.mental)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SectionLabel('Performance report'),
              const SizedBox(height: 10),
              _ReportPanel(r: s.report()),
              const SizedBox(height: 16),
              const SectionLabel('Weight trend'),
              const SizedBox(height: 10),
              Panel(
                child: weights.isEmpty
                    ? const Text('Log your weight each morning to see the trend.',
                        style: TextStyle(color: AppTheme.textLo))
                    : _WeightChart(points: weights),
              ),
              const SizedBox(height: 16),
              const SectionLabel('Day log'),
              const SizedBox(height: 10),
              if (days.isEmpty)
                Panel(
                    child: const Text('No days logged yet.',
                        style: TextStyle(color: AppTheme.textLo)))
              else
                for (final d in days.reversed) ...[
                  _DayRow(d: d),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 60),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ReportPanel extends StatelessWidget {
  final PerformanceReport r;
  const _ReportPanel({required this.r});

  @override
  Widget build(BuildContext context) {
    if (r.loggedDays == 0) {
      return Panel(
        child: const Text(
            'No data yet. Log a day and the report wakes up.',
            style: TextStyle(color: AppTheme.textLo)),
      );
    }
    final scoreColor = r.avgScore >= 0.8
        ? AppTheme.green
        : r.avgScore >= 0.5
            ? AppTheme.amber
            : AppTheme.red;
    final verdict = r.avgScore >= 0.8
        ? 'Locked in. Hold the line.'
        : r.avgScore >= 0.5
            ? 'Half-committed. Half is how you got here. Close the gap.'
            : 'You are coasting. Numbers do not lie. Fix it today.';
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${(r.avgScore * 100).round()}%',
                  style: TextStyle(
                      color: scoreColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('avg proven score',
                    style: TextStyle(color: AppTheme.textLo, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _line('Win rate', '${(r.winRate * 100).round()}%'),
          _line('Weed-free', '${(r.weedFreeRate * 100).round()}% of days'),
          _line('Avg proposals/day', r.avgProposals.toStringAsFixed(1)),
          _line('Reported streak', '${r.reportedStreak} days'),
          _line('Biggest leak', r.topBlocker),
          const SizedBox(height: 10),
          Text(verdict,
              style: TextStyle(
                  color: scoreColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3)),
        ],
      ),
    );
  }

  Widget _line(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text(k,
                style: const TextStyle(color: AppTheme.textMid, fontSize: 13)),
            const Spacer(),
            Text(v,
                style: const TextStyle(
                    color: AppTheme.textHi,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _DayRow extends StatelessWidget {
  final DayLog d;
  const _DayRow({required this.d});
  @override
  Widget build(BuildContext context) {
    final pct = (d.completion * 100).round();
    final c = d.verdict == 'won'
        ? AppTheme.green
        : d.verdict == 'lost'
            ? AppTheme.red
            : AppTheme.amber;
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text('D${d.day}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 14)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bar(d.completion, color: c, height: 6),
                const SizedBox(height: 4),
                Text(
                    '${d.weight != null ? '${d.weight}kg · ' : ''}${d.weedFree ? 'clean' : 'WEED'} · $pct%',
                    style:
                        const TextStyle(color: AppTheme.textLo, fontSize: 11)),
              ],
            ),
          ),
          if (d.verdict.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(d.verdict.toUpperCase(),
                  style: TextStyle(
                      color: c, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}

/// Tiny dependency-free line chart for weight.
class _WeightChart extends StatelessWidget {
  final List<MapEntry<int, double>> points;
  const _WeightChart({required this.points});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        size: Size.infinite,
        painter: _LinePainter(points),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<MapEntry<int, double>> pts;
  _LinePainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    final ws = pts.map((e) => e.value).toList();
    final minW = ws.reduce((a, b) => a < b ? a : b) - 0.5;
    final maxW = ws.reduce((a, b) => a > b ? a : b) + 0.5;
    final range = (maxW - minW).abs() < 0.01 ? 1 : (maxW - minW);
    final minD = pts.first.key;
    final maxD = pts.last.key;
    final dRange = (maxD - minD) == 0 ? 1 : (maxD - minD);

    Offset at(MapEntry<int, double> e) {
      final x = (e.key - minD) / dRange * size.width;
      final y = size.height - ((e.value - minW) / range * size.height);
      return Offset(x, y);
    }

    final line = Paint()
      ..color = AppTheme.green
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = AppTheme.green;

    final path = Path()..moveTo(at(pts.first).dx, at(pts.first).dy);
    for (final e in pts.skip(1)) {
      final o = at(e);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(path, line);
    for (final e in pts) {
      canvas.drawCircle(at(e), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.pts != pts;
}
