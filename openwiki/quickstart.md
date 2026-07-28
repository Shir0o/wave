# Wave — OpenWiki Quickstart

Wave is a Flutter (iOS + Android) hydration-tracking app. Users log drinks via
quick-add buttons or an offline natural-language parser ("two glasses of water
and a cold brew"), watch an animated dual-wave progress visualization fill up
toward a daily goal, configure adaptive reminders, view weekly trends/streaks,
and sync hydration/nutrition/activity data with Google Health Connect (and
mocked third-party apps like Google Fit/Samsung Health/Fitbit).

Source of truth: README.md and this repo's own `lib/` tree. This wiki is a
navigation layer over that code — read it first, then jump to source files
for exact implementation details.

## Start here

| If you want to... | Go to |
|---|---|
| Understand the app shell, state management, theming, and where files live | [architecture/overview.md](architecture/overview.md) |
| Understand how a drink gets logged (quick add, NL parser, entries, streaks/trends) | [workflows/hydration-logging.md](workflows/hydration-logging.md) |
| Understand Health Connect integration, permissions, and sync | [workflows/health-connect-sync.md](workflows/health-connect-sync.md) |
| Run tests, understand CI/coverage gates, or follow contribution rules | [operations/testing-and-ci.md](operations/testing-and-ci.md) |

## Repo facts an agent should know immediately

- **Stack**: Flutter/Dart, Material 3, `Fredoka` font via `google_fonts`, `provider` for state (single `ChangeNotifier`: `AppState`), `shared_preferences` for local persistence, `health: ^13.3.1` for Health Connect/HealthKit.
- **Single global state object**: `lib/state/app_state.dart` (`AppState`) owns almost everything — navigation, entries, reminders, sync, onboarding, toast messages. Screens are dumb `Provider.of<AppState>(context)` consumers. See [architecture/overview.md](architecture/overview.md).
- **No backend**: everything is local-first. "Sync" means device Health Connect / HealthKit, not a cloud service. Other-app integrations (Google Fit, Samsung Health, Fitbit) are simulated toggle state only, not real API integrations.
- **Testing is enforced**: CI (`.github/workflows/flutter.yml`) runs `dart format`, `flutter analyze`, `flutter test --coverage`, and fails the build if line coverage drops below **90%** (`tool/check_coverage.dart`). See [operations/testing-and-ci.md](operations/testing-and-ci.md).
- **Changelog discipline**: `AGENTS.md`/`CLAUDE.md` (identical, git-ignored duplicates for different agent tools) require checking `CHANGELOG.md` before changes and updating its `[Unreleased]` section after. Recent history (git log) shows this convention is followed consistently across PRs.
- **`openwiki/` is agent-generated documentation**, refreshed on a schedule by `.github/workflows/openwiki-update.yml`. Don't hand-edit generated pages other than `INSTRUCTIONS.md` (the human-authored brief) unless asked.

## Repository layout

```
lib/
├── main.dart                  # App entrypoint, MaterialApp, bottom-nav shell, toast overlay
├── models/drink_entry.dart    # DrinkEntry data model (JSON round-trip)
├── screens/                   # One StatelessWidget per tab/flow (see architecture page)
├── state/app_state.dart       # AppState ChangeNotifier — all business logic lives here
├── theme/app_theme.dart       # AppThemeColors light/dark token sets
├── utils/hydration_parser.dart# Offline regex NL parser for drink logging
├── utils/icon_helper.dart     # icon-name string -> IconData lookup
└── widgets/wave_painter.dart  # Custom-painted animated dual sine wave + bubbles

test/            # Unit + widget tests, one file per screen/model/util + mock_health.dart
tool/check_coverage.dart   # Parses coverage/lcov.info and enforces the CI threshold
android/, ios/   # Platform shells; android/app/.../AndroidManifest.xml carries Health Connect permission + rationale wiring
design/          # Non-shipped UI/product exploration artifacts (see Backlog)
```

## Backlog

Areas intentionally not documented in depth in this initial pass:

- **`design/` directory** (source anchor: `design/CLAUDE.md`, `design/Wave.dc.html`, `design/hydration.js`) — a separate design-exploration workspace (HTML/JS mockups, archived alternate concepts). Not part of the shipped Flutter app; deferred because it's product-exploration material rather than app source.
- **Reminder notification delivery** (source anchor: `lib/screens/reminders_screen.dart`, `lib/state/app_state.dart` reminder fields) — the app models reminder times/intervals and toggles in state, but no OS-level local-notification scheduling code was found wired to these settings. Flagged here rather than assumed; verify before treating reminders as "real" push notifications.
- **iOS HealthKit-specific behavior** — `lib/state/app_state.dart` branches on `Platform.isAndroid` for Health Connect-specific checks (availability, nutrition types); iOS/HealthKit-only code paths and `ios/Podfile`/`ios/Runner` config are not separately detailed. Covered at a high level in [workflows/health-connect-sync.md](workflows/health-connect-sync.md) but the iOS native project itself isn't inventoried.
