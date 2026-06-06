import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/plan_data.dart';
import '../data/storage.dart';
import '../data/models/day_log.dart';
import '../data/models/client.dart';
import '../data/models/ai_config.dart';
import '../data/models/profile.dart';

/// Single source of truth for the whole app. Holds today's log, clients,
/// AI config and chat, and the derived "what should Build be doing right now"
/// signal.
class AppState extends ChangeNotifier {
  final Storage storage;
  AppState(this.storage);

  late DayLog today;
  List<Client> clients = [];
  List<AiConfig> aiConfigs = [];
  String activeProvider = 'ollama';
  List<ChatMessage> chat = [];
  bool notificationsEnabled = true;

  /// Null until Build hits START. The whole protocol is gated behind this.
  DateTime? startDate;
  late Profile profile;

  static String dateKey([DateTime? d]) =>
      DateFormat('yyyy-MM-dd').format(d ?? DateTime.now());

  Future<void> load() async {
    startDate = storage.startDate();
    profile = storage.profile();
    final key = dateKey();
    final dn = currentDay < 1 ? 1 : currentDay;
    today = storage.loadDay(key) ?? DayLog.fresh(key, started ? dn : 0);
    // Keep the stored day number in sync once the protocol is armed.
    if (started && today.day != dn) {
      today.day = dn;
      await storage.saveDay(today);
    }
    clients = storage.allClients();
    aiConfigs = storage.aiConfigs();
    activeProvider = storage.activeProvider();
    chat = storage.loadChat();
    notificationsEnabled = storage.notificationsEnabled();
    notifyListeners();
  }

  // ---- protocol gating ----
  bool get started => startDate != null;

  /// Current day (1-based once running). 0 means armed-but-not-yet-begun.
  int get currentDay =>
      startDate == null ? 0 : PlanData.dayNumber(startDate!).clamp(0, 9999);

  int get daysRemaining => startDate == null
      ? PlanData.totalDays
      : PlanData.daysRemaining(startDate!);

  bool get finished => started && currentDay > PlanData.totalDays;

  /// Arms the protocol. One-way: there is no pause or stop until day 21.
  Future<void> startProtocol(DateTime start) async {
    startDate = start;
    await storage.setStartDate(start);
    today.day = currentDay < 1 ? 1 : currentDay;
    await _persistDay();
    notifyListeners();
  }

  // ---- profile ----
  Future<void> saveProfile() async {
    await storage.saveProfile(profile);
    notifyListeners();
  }

  /// Locks (or updates) THE ONE THING — the single focus he is not allowed to
  /// keep switching away from.
  Future<void> setOneThing(String v) async {
    profile.oneThing = v.trim();
    await storage.saveProfile(profile);
    notifyListeners();
  }

  Future<void> _persistDay() async {
    await storage.saveDay(today);
    notifyListeners();
  }

  // ---- derived priority brain ----
  /// Active client preempts personal work. When one exists, money/delivery is
  /// the job. When none exists, the transformation IS the job.
  Client? get activeClient {
    final actives = clients.where((c) => c.isActive).toList()
      ..sort((a, b) {
        // soonest deadline first, then highest value
        final ad = a.deadline ?? '9999';
        final bd = b.deadline ?? '9999';
        final c = ad.compareTo(bd);
        return c != 0 ? c : b.valueRupees.compareTo(a.valueRupees);
      });
    return actives.isEmpty ? null : actives.first;
  }

  bool get clientMode => activeClient != null;

  String get priorityHeadline => clientMode
      ? 'CLIENT WORK FIRST — ${activeClient!.name}'
      : 'NO CLIENT YET — TRANSFORMATION IS THE JOB';

  /// The single most important thing to do right now.
  String get nextAction {
    if (clientMode) {
      return 'Deliver for ${activeClient!.name}. Then fire 5 proposals + 10 DMs.';
    }
    final p = today.task('proposals');
    final d = today.task('dms');
    if (p != null && !p.isComplete) {
      return 'Send proposals — ${p.value}/${p.target} done. Money does not wait.';
    }
    if (d != null && !d.isComplete) {
      return 'DM businesses — ${d.value}/${d.target} done. One yes changes the month.';
    }
    final train = today.task('train');
    if (train != null && !train.isComplete) return 'Train. Sweat. Feed the brain.';
    return 'Outreach done. Build your portfolio demo. Keep shipping.';
  }

  // ---- mutations: morning ----
  void setWeight(double? v) { today.weight = v; _persistDay(); }
  void setSleep(int v) { today.sleepQuality = v; _persistDay(); }
  void setEnergy(int v) { today.energy = v; _persistDay(); }
  void setWeedFree(bool v) {
    today.weedFree = v;
    today.task('weed')?.done = v;
    _persistDay();
  }
  void setWoke(bool v) { today.wokeOnTime = v; _persistDay(); }
  void setReadLaw(bool v) { today.readLaw = v; _persistDay(); }
  void setMorningIntent(String v) { today.morningIntent = v; _persistDay(); }
  void setIncomeTask(String v) { today.incomeTask = v; _persistDay(); }
  void setBuildGoal(String v) { today.buildGoal = v; _persistDay(); }

  // ---- mutations: tasks ----
  void toggleTask(String id) {
    final t = today.task(id);
    if (t == null) return;
    t.toggle();
    if (id == 'weed') today.weedFree = t.done;
    _persistDay();
  }

  void setTaskCount(String id, int v) {
    today.task(id)?.setCount(v);
    _persistDay();
  }

  void setTaskProof(String id, String path) {
    final t = today.task(id);
    if (t == null) return;
    t.proofPath = path;
    if (!t.isCount) t.done = true;
    _persistDay();
  }

  // ---- mutations: evening report ----
  void setIncomeShipped(bool v) { today.incomeShipped = v; _persistDay(); }
  void setBuildShipped(bool v) { today.buildShipped = v; _persistDay(); }
  void setWin1(String v) { today.win1 = v; _persistDay(); }
  void setWin2(String v) { today.win2 = v; _persistDay(); }
  void setBlocker(String v) { today.blocker = v; _persistDay(); }
  void setFix(String v) { today.fix = v; _persistDay(); }
  void setVerdict(String v) { today.verdict = v; _persistDay(); }
  void setReported(bool v) { today.reported = v; _persistDay(); }

  // ---- clients ----
  Future<void> upsertClient(Client c) async {
    await storage.saveClient(c);
    clients = storage.allClients();
    notifyListeners();
  }

  Future<void> deleteClient(String id) async {
    await storage.deleteClient(id);
    clients = storage.allClients();
    notifyListeners();
  }

  // ---- AI ----
  AiConfig get activeConfig => aiConfigs.firstWhere(
        (c) => c.provider == activeProvider,
        orElse: () => aiConfigs.first,
      );

  Future<void> setActiveProvider(String p) async {
    activeProvider = p;
    await storage.setActiveProvider(p);
    notifyListeners();
  }

  Future<void> saveAiConfigs() async {
    await storage.saveAiConfigs(aiConfigs);
    notifyListeners();
  }

  Future<void> addChatMessage(ChatMessage m) async {
    chat = [...chat, m];
    await storage.addChat(m);
    notifyListeners();
  }

  Future<void> clearChat() async {
    chat = [];
    await storage.clearChat();
    notifyListeners();
  }

  Future<void> setNotifications(bool v) async {
    notificationsEnabled = v;
    await storage.setNotificationsEnabled(v);
    notifyListeners();
  }

  // ---- stats ----
  List<DayLog> history() => storage.allDays();

  /// Compact last-7-days digest fed to the coach so it can confront patterns
  /// ("day 4 you skipped outreach again") instead of reacting to today only.
  String historyDigest() {
    final days = history();
    if (days.isEmpty) return 'No days logged yet.';
    final recent =
        days.length <= 7 ? days : days.sublist(days.length - 7);
    return recent.map((d) {
      final v = d.verdict.isEmpty ? '—' : d.verdict;
      final prop = d.task('proposals')?.value ?? 0;
      final dm = d.task('dms')?.value ?? 0;
      final blk = d.blocker.isEmpty ? '-' : d.blocker;
      final unproven = d.unprovenCount > 0 ? ' [${d.unprovenCount} unproven]' : '';
      return 'Day ${d.day}: score ${(d.score * 100).round()}%$unproven · $v · '
          'weed-free ${d.weedFree} · prop $prop dm $dm · blocker: $blk';
    }).join('\n');
  }

  /// Computed performance metrics across all logged days. No AI — pure numbers
  /// for the report panel.
  PerformanceReport report() {
    final days = history();
    if (days.isEmpty) return PerformanceReport.empty();
    final won = days.where((d) => d.verdict == 'won').length;
    final cleanDays = days.where((d) => d.weedFree).length;
    final avgScore =
        days.map((d) => d.score).fold(0.0, (a, b) => a + b) / days.length;
    final avgProp = days
            .map((d) => d.task('proposals')?.value ?? 0)
            .fold(0, (a, b) => a + b) /
        days.length;
    // most common non-empty blocker
    final counts = <String, int>{};
    for (final d in days) {
      final b = d.blocker.trim().toLowerCase();
      if (b.isNotEmpty) counts[b] = (counts[b] ?? 0) + 1;
    }
    String topBlocker = '—';
    int topN = 0;
    counts.forEach((k, v) {
      if (v > topN) {
        topN = v;
        topBlocker = k;
      }
    });
    return PerformanceReport(
      loggedDays: days.length,
      winRate: won / days.length,
      weedFreeRate: cleanDays / days.length,
      avgScore: avgScore,
      avgProposals: avgProp,
      topBlocker: topBlocker,
      reportedStreak: streakReported,
    );
  }

  int get streakReported {
    final days = history()..sort((a, b) => b.day.compareTo(a.day));
    int s = 0;
    for (final d in days) {
      if (d.reported && d.weedFree) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  String get _voiceLine {
    switch (profile.coachStyle) {
      case 'warm':
        return 'Voice: tough but warm. Honest and direct, never cruel — push hard but make it clear you have his back.';
      case 'strategist':
        return 'Voice: calm strategist. Quiet, surgical, no shouting. Treat him as a high-performer who needs clarity, not noise.';
      case 'adaptive':
        return 'Voice: adaptive. Brutal when he slacks, calm-strategic when he is working, warm when he is genuinely down. Read the moment.';
      case 'drill':
      default:
        return 'Voice: DRILL SERGEANT, always on. Maximum pressure. Short, loud, commanding. Every message ends with an order, not a suggestion.';
    }
  }

  /// System prompt that makes the in-app AI act as Build's coach with full
  /// context of today AND his psychological profile. This is what makes it feel
  /// "mind-readable" — it knows exactly how he fails and what to leverage.
  String coachSystemPrompt() {
    final t = today;
    final w = profile.weaknesses.isEmpty
        ? '—'
        : profile.weaknesses.map((e) => '- $e').join('\n');
    final st = profile.strengths.isEmpty
        ? '—'
        : profile.strengths.map((e) => '- $e').join('\n');
    final oneThing = profile.locked
        ? profile.oneThing
        : '(not locked yet — force him to commit to ONE thing)';
    return '''
You are Build Tracker's coach — Build's accountability partner for a 21-day
rebuild across PHYSICAL, MENTAL, FINANCIAL fronts. He is out of money and must
earn this month. No coddling.

$_voiceLine

WHO HE IS — and his ONE fatal pattern:
He THINKS and LEARNS constantly but does NOT execute. The moment work gets hard
or boring he ESCAPES — switches language, idea, or whole profession — and starts
over. He has done this for years and finished nothing. He only really knows
${profile.language}. Your #1 job: keep him LOCKED to one thing and SHIPPING.

HARD RULES (never break these):
1. NEVER endorse switching language, stack, idea, or project. If he proposes a
   new one, refuse and drag him back to THE ONE THING. Name the pattern out loud.
2. Stay in ${profile.language}. Do not suggest other languages.
3. Bias every answer toward SHIPPING today, not learning more or planning more.
   "What did you ship?" beats "what did you learn?".
4. Do not let him quit or leave his work. Loyal, but immovable on this.

THE ONE THING (his locked focus): $oneThing

HIS WEAKNESSES (guard these):
$w

HIS STRENGTHS (pull these when he is winning):
$st

TODAY = Day ${t.day}/21 (${t.date}).
Priority: $priorityHeadline.
Next action: $nextAction.
Weed-free today: ${t.weedFree}. Weight: ${t.weight ?? '—'}kg.
Proposals: ${t.task('proposals')?.value ?? 0}/5. DMs: ${t.task('dms')?.value ?? 0}/10.
Proof-weighted score today: ${(t.score * 100).round()}% (${t.unprovenCount} tasks checked WITHOUT proof — do not give full credit for those).
Reported streak: $streakReported days.

RECENT HISTORY (last logged days):
${historyDigest()}

Use the history to call out repeated patterns by day number. If a task is marked
done but has no proof, treat it as suspect and demand proof. Keep replies short
and punchy. Tell the real truth even when it stings.
''';
  }
}

/// Pure computed performance metrics for the Stats report panel.
class PerformanceReport {
  final int loggedDays;
  final double winRate;
  final double weedFreeRate;
  final double avgScore;
  final double avgProposals;
  final String topBlocker;
  final int reportedStreak;

  PerformanceReport({
    required this.loggedDays,
    required this.winRate,
    required this.weedFreeRate,
    required this.avgScore,
    required this.avgProposals,
    required this.topBlocker,
    required this.reportedStreak,
  });

  factory PerformanceReport.empty() => PerformanceReport(
        loggedDays: 0,
        winRate: 0,
        weedFreeRate: 0,
        avgScore: 0,
        avgProposals: 0,
        topBlocker: '—',
        reportedStreak: 0,
      );
}
