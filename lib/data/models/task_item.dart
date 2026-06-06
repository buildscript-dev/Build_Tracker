/// A single trackable item in a day. Two kinds:
/// - boolean task: [target] == 0, completion is [done].
/// - count task:   [target]  > 0, completion is [value] >= [target].
class TaskItem {
  final String id;
  final String title;
  final String category; // physical | mental | financial | deepwork
  final String hint;
  final int target; // 0 => boolean task
  int value; // for count tasks
  bool done;
  String? proofPath; // photo proof
  int? doneAtMillis;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    this.hint = '',
    this.target = 0,
    this.value = 0,
    this.done = false,
    this.proofPath,
    this.doneAtMillis,
  });

  factory TaskItem.boolTask(
          String id, String title, String category, String hint) =>
      TaskItem(id: id, title: title, category: category, hint: hint);

  factory TaskItem.countTask(
          String id, String title, String category, int target) =>
      TaskItem(id: id, title: title, category: category, target: target);

  bool get isCount => target > 0;

  /// Completed if boolean done, or count reached target (target 0 count = optional).
  bool get isComplete =>
      isCount ? (target > 0 && value >= target) : done;

  /// Progress 0..1 for count tasks.
  double get progress {
    if (!isCount) return done ? 1 : 0;
    if (target == 0) return value > 0 ? 1 : 0;
    return (value / target).clamp(0, 1).toDouble();
  }

  void toggle() {
    done = !done;
    doneAtMillis = done ? DateTime.now().millisecondsSinceEpoch : null;
  }

  void setCount(int v) {
    value = v < 0 ? 0 : v;
    done = isComplete;
    doneAtMillis =
        isComplete ? DateTime.now().millisecondsSinceEpoch : null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'hint': hint,
        'target': target,
        'value': value,
        'done': done,
        'proofPath': proofPath,
        'doneAtMillis': doneAtMillis,
      };

  factory TaskItem.fromMap(Map map) => TaskItem(
        id: map['id'] as String,
        title: map['title'] as String,
        category: map['category'] as String,
        hint: (map['hint'] ?? '') as String,
        target: (map['target'] ?? 0) as int,
        value: (map['value'] ?? 0) as int,
        done: (map['done'] ?? false) as bool,
        proofPath: map['proofPath'] as String?,
        doneAtMillis: map['doneAtMillis'] as int?,
      );
}
