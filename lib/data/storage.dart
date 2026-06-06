import 'package:hive_flutter/hive_flutter.dart';

import 'models/day_log.dart';
import 'models/client.dart';
import 'models/ai_config.dart';
import 'models/profile.dart';

/// Local-first persistence. Hive works on mobile + web + desktop with no
/// backend, so the app runs offline and free.
class Storage {
  static const _days = 'days';
  static const _clients = 'clients';
  static const _settings = 'settings';
  static const _chat = 'chat';

  late Box _daysBox;
  late Box _clientsBox;
  late Box _settingsBox;
  late Box _chatBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _daysBox = await Hive.openBox(_days);
    _clientsBox = await Hive.openBox(_clients);
    _settingsBox = await Hive.openBox(_settings);
    _chatBox = await Hive.openBox(_chat);
  }

  // ---- days ----
  DayLog? loadDay(String date) {
    final raw = _daysBox.get(date);
    if (raw == null) return null;
    return DayLog.fromMap(Map.from(raw));
  }

  Future<void> saveDay(DayLog d) => _daysBox.put(d.date, d.toMap());

  List<DayLog> allDays() => _daysBox.values
      .map((e) => DayLog.fromMap(Map.from(e)))
      .toList()
    ..sort((a, b) => a.day.compareTo(b.day));

  // ---- clients ----
  List<Client> allClients() => _clientsBox.values
      .map((e) => Client.fromMap(Map.from(e)))
      .toList()
    ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));

  Future<void> saveClient(Client c) => _clientsBox.put(c.id, c.toMap());
  Future<void> deleteClient(String id) => _clientsBox.delete(id);

  // ---- settings / AI ----
  List<AiConfig> aiConfigs() {
    final raw = _settingsBox.get('aiConfigs');
    if (raw == null) {
      return [
        AiConfig.defaultFor('ollama'),
        AiConfig.defaultFor('openrouter'),
        AiConfig.defaultFor('claude'),
        AiConfig.defaultFor('openai'),
      ];
    }
    return (raw as List).map((e) => AiConfig.fromMap(Map.from(e))).toList();
  }

  Future<void> saveAiConfigs(List<AiConfig> configs) =>
      _settingsBox.put('aiConfigs', configs.map((e) => e.toMap()).toList());

  String activeProvider() =>
      _settingsBox.get('activeProvider', defaultValue: 'openrouter') as String;

  Future<void> setActiveProvider(String p) =>
      _settingsBox.put('activeProvider', p);

  bool notificationsEnabled() =>
      _settingsBox.get('notifications', defaultValue: true) as bool;

  Future<void> setNotificationsEnabled(bool v) =>
      _settingsBox.put('notifications', v);

  // ---- protocol start (the START button) ----
  /// Null until Build arms the protocol. The clock does not run before this.
  DateTime? startDate() {
    final ms = _settingsBox.get('startMillis');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms as int);
  }

  Future<void> setStartDate(DateTime d) =>
      _settingsBox.put('startMillis', d.millisecondsSinceEpoch);

  // ---- profile ----
  Profile profile() {
    final raw = _settingsBox.get('profile');
    if (raw == null) return Profile.seed();
    return Profile.fromMap(Map.from(raw));
  }

  Future<void> saveProfile(Profile p) =>
      _settingsBox.put('profile', p.toMap());

  // ---- chat ----
  List<ChatMessage> loadChat() => _chatBox.values
      .map((e) => ChatMessage.fromMap(Map.from(e)))
      .toList()
    ..sort((a, b) => a.timeMillis.compareTo(b.timeMillis));

  Future<void> addChat(ChatMessage m) => _chatBox.add(m.toMap());
  Future<void> clearChat() => _chatBox.clear();
}
