# Build Tracker

Cross-platform accountability app that runs Build's 21-day rebuild — **physical, mental, financial** — in one place. Brutal, honest, operator-grade. Phone (S24) + Web + Desktop from one Flutter codebase.

> No client = transformation is the job. Land a client and the app flips to **client-first**.

---

## What's built (MVP v1)

| Area | Status |
|------|--------|
| **Today** — day N/21, priority brain, morning check-in, 4-category checklist (count steppers + photo proof), evening report + verdict | ✅ |
| **Plan** — THE LAW (7 daily laws), daily timeline, mindset (Elon/Durov/Zuck) | ✅ |
| **Clients** — pipeline, add/edit, status; active client preempts personal work | ✅ |
| **Coach** — in-app AI chat that knows today's state; multi-provider | ✅ |
| **Stats** — streak, days won, weed-free count, weight line chart, day log | ✅ |
| **Settings** — notification toggle + test, AI provider config | ✅ |
| **Notifications** — brutal reminder at every block of the day (Android) | ✅ |
| Local-first storage (Hive) — offline, free, no backend | ✅ |

### AI providers (use what you already pay for)
- **Ollama** — free, local, runs on the RTX 4050 (`localhost:11434`)
- **OpenRouter** — one key, many models
- **OpenAI** — `gpt-4o-mini` etc.
- **Claude** — `claude-sonnet-4-6`

Set keys/base-URL/model in **Settings → AI providers**. Switch the live engine from the Coach screen dropdown.

---

## Run it

```bash
cd ~/Projects/BuildTracker

# web (fastest to see it)
flutter run -d chrome

# on the S24 (USB debugging on, plugged in)
flutter devices
flutter run -d <device-id>

# desktop (Nobara)
flutter run -d linux
```

Build:
```bash
flutter build web        # -> build/web
flutter build apk        # -> build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture

```
lib/
  core/plan_data.dart        # start date, THE LAW, schedule, default tasks
  data/
    models/                  # TaskItem, DayLog, Client, AiConfig, ChatMessage
    storage.dart             # Hive boxes (days/clients/settings/chat)
    ai_service.dart          # 4-provider chat abstraction
  services/notifications.dart# daily reminder engine
  state/app_state.dart       # single ChangeNotifier source of truth + priority brain
  theme/app_theme.dart       # dark brutal-premium theme
  features/                  # today / plan / clients / chat / stats / settings
  widgets/common.dart        # shared UI
```

State: `provider` (one `AppState`). Storage: `hive`. No backend — runs offline.

---

## Roadmap (Phase 2, after rent is covered)

- **Watch app** (Galaxy Watch 6 / Wear OS) — quick check-offs + glanceable day %
- **Health Connect sync** — pull steps, heart rate, sleep, workouts automatically
- **App-usage tracking** — "you're leaking time" alerts (Android UsageStats)
- **Photo → AI extract** — vision model reads a meal/workout photo and auto-fills tasks
- **Cloud sync** (Firebase/Supabase) — phone ↔ watch ↔ web shared state
- **Could become a sellable SaaS** — this app is also a portfolio piece for clients

---

*Built as the engine for the 21-day rebuild. Tracker docs live in `~/transformation/`.*
