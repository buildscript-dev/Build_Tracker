import '../data/models/task_item.dart';

/// The 21-day protocol seed data: start date, THE LAW, daily schedule,
/// and the default checklist that seeds every new day.
class PlanData {
  static const int totalDays = 21;

  /// Current day number (1-based) given the chosen [start] date. Can exceed 21
  /// if overshooting. The start date is no longer hardcoded — Ankit arms it with
  /// the START button, so the clock only runs once he commits.
  static int dayNumber(DateTime start, [DateTime? now]) {
    final today = now ?? DateTime.now();
    final d0 = DateTime(start.year, start.month, start.day);
    final d1 = DateTime(today.year, today.month, today.day);
    return d1.difference(d0).inDays + 1;
  }

  static int daysRemaining(DateTime start, [DateTime? now]) =>
      (totalDays - dayNumber(start, now)).clamp(0, totalDays);

  /// THE LAW — read aloud every morning.
  static const List<String> dailyLaws = [
    'Wake 05:30. Sleep 21:30. No exceptions.',
    'No weed. Zero. Not less — zero.',
    'No screen-entertainment before income work ships.',
    'Send 5 proposals / DM 10 businesses — every day.',
    'Train. Sweat. Daily.',
    'Hit protein. Eat only in the 12:00–20:00 window.',
    'Log it. Report it. The chain cannot break.',
  ];

  static const List<MindsetLaw> mindsetLaws = [
    MindsetLaw('ELON', 'First principles + brutal volume.',
        'Find what is true, take the fastest path, then do 10x the work. Compete on output per day.'),
    MindsetLaw('PAVEL DUROV', 'Monk discipline + total ownership.',
        'Own less, control more. Solitude is the forge. Being alone in a flat is the exact condition that builds you.'),
    MindsetLaw('ZUCKERBERG', 'Ship, measure, iterate, distribute.',
        'Done beats perfect. Ship ugly today, fix with feedback tomorrow. Building is half — distribution is the other half.'),
  ];

  /// The daily timeline used to schedule notifications/alarms.
  static const List<ScheduleBlock> schedule = [
    ScheduleBlock(5, 30, 'WAKE', 'Lemon-salt water. Cold splash. Read THE LAW aloud.'),
    ScheduleBlock(5, 45, 'WALK', '45-min fasted walk. Nose breathing. No phone.'),
    ScheduleBlock(6, 30, 'PRIME', 'Posture drills 10 min + voice/read-aloud 10 min.'),
    ScheduleBlock(7, 0, 'DEEP WORK 1', 'Hardest income build. 2 hrs zero distraction.'),
    ScheduleBlock(10, 0, 'MONEY BLOCK', '5 proposals + 10 DMs. This pays rent.'),
    ScheduleBlock(12, 0, 'BREAK FAST', 'Mess lunch + stew + salad. Skip rice.'),
    ScheduleBlock(13, 0, 'LEARN', '1 hr sharpening — stack / competitor study.'),
    ScheduleBlock(16, 0, 'TRAIN', 'Boxing HIIT or bodyweight. Sweat hard.'),
    ScheduleBlock(17, 0, 'RECOVER', 'Protein shake. Shower. Oil-pull.'),
    ScheduleBlock(18, 30, 'DINNER', 'Window closes 20:00. Nothing after.'),
    ScheduleBlock(20, 30, 'SHUTDOWN', 'No screens. Book / journal / silence.'),
    ScheduleBlock(21, 0, 'REPORT', 'Fill evening report. Report to Claude.'),
    ScheduleBlock(21, 30, 'SLEEP', 'Hard stop.'),
  ];

  /// Default checklist seeded into each new day.
  static List<TaskItem> defaultTasks() => [
        // PHYSICAL
        TaskItem.boolTask('walk', 'Walk', 'physical', '45-min fasted walk'),
        TaskItem.boolTask('posture', 'Posture drills', 'physical', '10 min'),
        TaskItem.boolTask('train', 'Training session', 'physical', 'boxing or bodyweight'),
        TaskItem.boolTask('protein', 'Protein hit', 'physical', '~120g'),
        TaskItem.boolTask('window', 'Ate in window', 'physical', 'nothing after 20:00'),
        // MENTAL
        TaskItem.boolTask('weed', 'Weed-free all day', 'mental', 'ZERO'),
        TaskItem.boolTask('noscroll', 'No screen-fun before income', 'mental', 'earn dopamine'),
        TaskItem.boolTask('voice', 'Voice / read-aloud', 'mental', ''),
        TaskItem.boolTask('silence', '5-min silence / journal', 'mental', 'at shutdown'),
        // FINANCIAL
        TaskItem.countTask('proposals', 'Proposals sent', 'financial', 5),
        TaskItem.countTask('dms', 'DMs sent', 'financial', 10),
        TaskItem.countTask('replies', 'Replies received', 'financial', 0),
        // DEEP WORK
        TaskItem.boolTask('dw1', 'Deep Work 1 (income build)', 'deepwork', ''),
        TaskItem.boolTask('dw2', 'Deep Work 2 (outreach)', 'deepwork', ''),
      ];
}

class MindsetLaw {
  final String name;
  final String headline;
  final String body;
  const MindsetLaw(this.name, this.headline, this.body);
}

class ScheduleBlock {
  final int hour;
  final int minute;
  final String label;
  final String detail;
  const ScheduleBlock(this.hour, this.minute, this.label, this.detail);
}
