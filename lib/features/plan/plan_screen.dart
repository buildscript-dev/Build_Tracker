import 'package:flutter/material.dart';
import '../../core/plan_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('THE PLAN')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SectionLabel('The 7 daily laws', color: AppTheme.red),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  children: [
                    for (var i = 0; i < PlanData.dailyLaws.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${i + 1}',
                                style: const TextStyle(
                                    color: AppTheme.red,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(PlanData.dailyLaws[i],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Daily timeline'),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  children: [
                    for (final b in PlanData.schedule)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 52,
                              child: Text(
                                  '${b.hour.toString().padLeft(2, '0')}:${b.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: AppTheme.amber,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  Text(b.detail,
                                      style: const TextStyle(
                                          color: AppTheme.textLo,
                                          fontSize: 11,
                                          height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Mindset — your idols, decoded'),
              const SizedBox(height: 10),
              for (final m in PlanData.mindsetLaws) ...[
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name,
                          style: const TextStyle(
                              color: AppTheme.mental,
                              fontWeight: FontWeight.w900,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(m.headline,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(m.body,
                          style: const TextStyle(
                              color: AppTheme.textMid,
                              fontSize: 13,
                              height: 1.4)),
                    ],
                  ),
                ),
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
