# BuildTracker — Design System

**Lane: Dark Brutal + Ember.** Near-black canvas, hard red urgency that warms into
ember on focal elements, serif for gravity, category-tinted squircle cards.
Vibe: an operator's tool at the gym at night — premium, never cute.

Extracted from 6 Dribbble refs (ref4 health-data + ref6 mental-health drove the
direction; minimal/glass lanes rejected). This is the single source of truth for
all design prompts. Build against existing `lib/theme/app_theme.dart`.

---

## 1. Color tokens

Keep existing, add ember + tints:

| Token | Hex | Use |
|---|---|---|
| bg | `#0A0A0B` | canvas (exists) |
| surface | `#151518` | cards (exists) |
| surfaceHi | `#1E1E22` | raised/input (exists) |
| line | `#2A2A30` | hairlines (exists) |
| **red** | `#FF3B30` | primary urgency (exists) |
| **ember1 → ember2** | `#FF3B30 → #FF8A00` | NEW gradient: priority banner, streak, score ring, primary CTA |
| green | `#30D158` | earned / proven (exists) |
| amber | `#FFB020` | partial / warning (exists) |
| textHi/Mid/Lo | `#F5F5F7` / `#A0A0A8` / `#6A6A72` | text (exists) |

**Category tints (exist, lean into them as card washes at ~8–12% alpha):**
physical `#0A84FF` · mental `#BF5AF2` · financial `#30D158` · deepwork `#FFB020`.

Ember gradient = `LinearGradient([ember1, ember2])` topLeft→bottomRight.

## 2. Typography

- **Display / headlines / verdicts → serif** (gravity): "DAY 1 / 21", THE LAW,
  day verdict, THE ONE THING. Candidate: a strong serif (e.g. Fraunces / Playfair)
  via `google_fonts`. Weight 700–900, tight letter-spacing.
- **Body / labels / numbers → keep system sans** (current). Stat numbers heavy (w900).
- SectionLabel stays: uppercase, 11px, letterSpacing 1.5.

## 3. Components to build (stolen, mapped)

| Component | From | Where it goes |
|---|---|---|
| **Proven-score ring** w/ 4 category arcs + count-up | ref3/4 | Today top (replaces flat bar), Stats |
| **Squircle cards** bigger radius (20) + soft shadow + category tint wash | ref1/3/4 | all panels |
| **Ember priority banner** w/ gradient | ref4/5 | Today |
| **Streak flame badge** (number in flame) | ref1 | header / appbar |
| **Day/Week segmented control** (sliding pill) | ref1/2/3 | Stats |
| **Floating pill bottom-nav + center FAB** (quick-log proposal/DM/proof) | ref1/3/4 | Shell |
| **Timeline status pills** done / NOW / upcoming | ref2 | Plan schedule |
| **Sparklines** on stat cards (score, proposals trend) | ref2/4 | Stats |
| **Swipeable card-stack** for mantras / coach prompts | ref6 | Today or Coach empty |
| **Mood selector** upgrade (energy/sleep) | ref6 | Today morning check-in |
| **Collapsing parallax header** | ref1/5 | Today, Stats |

## 4. Motion

- Ring fill animation + **count-up numbers** on screen enter (ref3/4).
- **Staggered card entrance** (fade+slide-up) on tab load.
- **Card-stack swipe** gestures (ref6).
- Collapsing header on scroll (SliverAppBar already in use).
- Segmented control: sliding indicator.
- Keep it snappy (200–300ms, easeOut). No bouncy/cute curves — brutal = crisp.
- Candidate libs: `flutter_animate` (entrances), custom `CustomPainter` for ring/sparkline (no heavy deps).

## 5. Rules

- Dark always. Red/ember = urgency & focus only — don't flood.
- Serif only for headline gravity; never body.
- Every card: squircle 20, 1px `line` border OR soft shadow, optional category tint.
- Numbers are heroes (big, w900). Proven score is THE number.
- No decorative fluff that softens the "no excuses" tone.

## 6. Build order (next prompts)

1. Theme: add ember gradient + serif (google_fonts) + radius bump.
2. Proven-score ring (CustomPainter) → Today + Stats.
3. Squircle card restyle + category tint wash.
4. Floating pill nav + center quick-log FAB.
5. Segmented control + sparklines on Stats.
6. Timeline status pills (Plan).
7. Motion pass (flutter_animate entrances, count-up, card-stack).
