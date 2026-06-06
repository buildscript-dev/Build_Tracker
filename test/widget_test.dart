import 'package:flutter_test/flutter_test.dart';

import 'package:build_tracker/core/plan_data.dart';

void main() {
  test('day number is 1 on start date', () {
    final start = DateTime(2026, 6, 6);
    expect(PlanData.dayNumber(start, start), 1);
  });

  test('default tasks seed all four categories', () {
    final tasks = PlanData.defaultTasks();
    final cats = tasks.map((t) => t.category).toSet();
    expect(cats, containsAll(['physical', 'mental', 'financial', 'deepwork']));
  });

  test('proposals task targets 5', () {
    final p = PlanData.defaultTasks().firstWhere((t) => t.id == 'proposals');
    expect(p.target, 5);
  });
}
