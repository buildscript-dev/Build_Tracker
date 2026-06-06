/// Ankit's operator profile. This is what makes the coach "mind-readable": it
/// remembers who he is, what derails him, what to leverage, and the single
/// thing he is locked to. Stored locally and injected into every coach prompt.
class Profile {
  /// Coach voice: drill | adaptive | warm | strategist.
  String coachStyle;

  /// The ONE locked focus. The whole point is he does not get to switch this.
  String oneThing;

  /// Only language he actually knows. Used to refuse stack-switching.
  String language;

  /// What derails him (his weakness map).
  List<String> weaknesses;

  /// What to pull when he is winning (his strengths).
  List<String> strengths;

  Profile({
    this.coachStyle = 'drill',
    this.oneThing = '',
    this.language = 'Python',
    List<String>? weaknesses,
    List<String>? strengths,
  })  : weaknesses = weaknesses ?? const [],
        strengths = strengths ?? const [];

  bool get locked => oneThing.trim().isNotEmpty;

  /// Seeded from the onboarding answers Ankit gave on 2026-06-06.
  factory Profile.seed() => Profile(
        coachStyle: 'drill',
        language: 'Python',
        weaknesses: const [
          'Weed / numbing out',
          'Doomscroll / screens',
          'Fear of rejection (skips outreach)',
          'Late waking / no routine',
          'Thinks & learns but never executes — switches idea/language/profession to escape',
        ],
        strengths: const [
          'Builds / codes fast once locked',
          'Obsesses once in flow (hard to start, unstoppable after)',
          'Learns anything fast',
          'Deeply loyal / heart-driven',
        ],
      );

  Map<String, dynamic> toMap() => {
        'coachStyle': coachStyle,
        'oneThing': oneThing,
        'language': language,
        'weaknesses': weaknesses,
        'strengths': strengths,
      };

  factory Profile.fromMap(Map map) => Profile(
        coachStyle: (map['coachStyle'] ?? 'drill') as String,
        oneThing: (map['oneThing'] ?? '') as String,
        language: (map['language'] ?? 'Python') as String,
        weaknesses:
            ((map['weaknesses'] ?? const []) as List).map((e) => '$e').toList(),
        strengths:
            ((map['strengths'] ?? const []) as List).map((e) => '$e').toList(),
      );
}
