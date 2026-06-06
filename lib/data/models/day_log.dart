import 'task_item.dart';
import '../../core/plan_data.dart';

/// One day of the rebuild — morning check-in, checklist, evening report.
class DayLog {
  final String date; // yyyy-MM-dd
  int day; // day number (refreshes when the protocol is armed)

  // morning check-in
  bool wokeOnTime;
  double? weight;
  int? sleepQuality; // 1..5
  int? energy; // 1..5
  bool weedFree;
  bool readLaw;
  String morningIntent;
  String incomeTask;
  String buildGoal;

  // checklist
  List<TaskItem> tasks;

  // evening report
  bool incomeShipped;
  bool buildShipped;
  String win1;
  String win2;
  String blocker;
  String fix;
  String verdict; // won | partial | lost | ''
  bool reported;

  DayLog({
    required this.date,
    required this.day,
    this.wokeOnTime = false,
    this.weight,
    this.sleepQuality,
    this.energy,
    this.weedFree = true,
    this.readLaw = false,
    this.morningIntent = '',
    this.incomeTask = '',
    this.buildGoal = '',
    required this.tasks,
    this.incomeShipped = false,
    this.buildShipped = false,
    this.win1 = '',
    this.win2 = '',
    this.blocker = '',
    this.fix = '',
    this.verdict = '',
    this.reported = false,
  });

  factory DayLog.fresh(String date, int day) =>
      DayLog(date: date, day: day, tasks: PlanData.defaultTasks());

  TaskItem? task(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Completion across the non-optional tasks (target-0 count tasks excluded).
  double get completion {
    final scored =
        tasks.where((t) => !(t.isCount && t.target == 0)).toList();
    if (scored.isEmpty) return 0;
    final done = scored.where((t) => t.isComplete).length;
    return done / scored.length;
  }

  /// Proof-weighted score (0..1). "Prove it or it didn't happen": a bool task
  /// checked off WITHOUT photo proof only earns half credit. Count tasks score
  /// by progress. This is the number the coach trusts, not raw completion.
  double get score {
    final scored =
        tasks.where((t) => !(t.isCount && t.target == 0)).toList();
    if (scored.isEmpty) return 0;
    double sum = 0;
    for (final t in scored) {
      if (t.isCount) {
        sum += t.progress.clamp(0.0, 1.0);
      } else if (t.isComplete) {
        sum += t.proofPath != null ? 1.0 : 0.5;
      }
    }
    return sum / scored.length;
  }

  /// How many completed bool tasks are missing proof (the "unproven" count).
  int get unprovenCount => tasks
      .where((t) => !t.isCount && t.isComplete && t.proofPath == null)
      .length;

  int completedCount(String category) => tasks
      .where((t) => t.category == category && t.isComplete)
      .length;

  int totalCount(String category) => tasks
      .where((t) =>
          t.category == category && !(t.isCount && t.target == 0))
      .length;

  Map<String, dynamic> toMap() => {
        'date': date,
        'day': day,
        'wokeOnTime': wokeOnTime,
        'weight': weight,
        'sleepQuality': sleepQuality,
        'energy': energy,
        'weedFree': weedFree,
        'readLaw': readLaw,
        'morningIntent': morningIntent,
        'incomeTask': incomeTask,
        'buildGoal': buildGoal,
        'tasks': tasks.map((t) => t.toMap()).toList(),
        'incomeShipped': incomeShipped,
        'buildShipped': buildShipped,
        'win1': win1,
        'win2': win2,
        'blocker': blocker,
        'fix': fix,
        'verdict': verdict,
        'reported': reported,
      };

  factory DayLog.fromMap(Map map) => DayLog(
        date: map['date'] as String,
        day: map['day'] as int,
        wokeOnTime: (map['wokeOnTime'] ?? false) as bool,
        weight: (map['weight'] as num?)?.toDouble(),
        sleepQuality: map['sleepQuality'] as int?,
        energy: map['energy'] as int?,
        weedFree: (map['weedFree'] ?? true) as bool,
        readLaw: (map['readLaw'] ?? false) as bool,
        morningIntent: (map['morningIntent'] ?? '') as String,
        incomeTask: (map['incomeTask'] ?? '') as String,
        buildGoal: (map['buildGoal'] ?? '') as String,
        tasks: ((map['tasks'] ?? []) as List)
            .map((e) => TaskItem.fromMap(e as Map))
            .toList(),
        incomeShipped: (map['incomeShipped'] ?? false) as bool,
        buildShipped: (map['buildShipped'] ?? false) as bool,
        win1: (map['win1'] ?? '') as String,
        win2: (map['win2'] ?? '') as String,
        blocker: (map['blocker'] ?? '') as String,
        fix: (map['fix'] ?? '') as String,
        verdict: (map['verdict'] ?? '') as String,
        reported: (map['reported'] ?? false) as bool,
      );
}
