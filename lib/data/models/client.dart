/// A client / paid opportunity. When an ACTIVE client exists, the app flips
/// the daily priority to "client work first".
class Client {
  final String id;
  String name;
  String project;
  int valueRupees;
  String status; // lead | active | delivered | paid | lost
  String? deadline; // yyyy-MM-dd
  String notes;
  final int createdAtMillis;

  Client({
    required this.id,
    required this.name,
    this.project = '',
    this.valueRupees = 0,
    this.status = 'lead',
    this.deadline,
    this.notes = '',
    required this.createdAtMillis,
  });

  /// A client that should preempt personal work.
  bool get isActive => status == 'lead' || status == 'active';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'project': project,
        'valueRupees': valueRupees,
        'status': status,
        'deadline': deadline,
        'notes': notes,
        'createdAtMillis': createdAtMillis,
      };

  factory Client.fromMap(Map map) => Client(
        id: map['id'] as String,
        name: map['name'] as String,
        project: (map['project'] ?? '') as String,
        valueRupees: (map['valueRupees'] ?? 0) as int,
        status: (map['status'] ?? 'lead') as String,
        deadline: map['deadline'] as String?,
        notes: (map['notes'] ?? '') as String,
        createdAtMillis: (map['createdAtMillis'] ??
            DateTime.now().millisecondsSinceEpoch) as int,
      );
}
