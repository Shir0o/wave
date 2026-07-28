## Plan

Pages:
1. quickstart.md - overview, links, backlog
2. architecture/overview.md - app shell, state mgmt, theming, navigation, source map
3. workflows/hydration-logging.md - quick add / smart log / parser / drink entry model / streaks / trends
4. workflows/health-connect-sync.md - Health Connect integration, permissions, sync, android manifest, sync/onboarding screens
5. operations/testing-and-ci.md - test suite structure, mock_health, coverage tool, CI workflow, contributing/branch protection, changelog discipline

Backlog: design/ directory (design exploration source, not app code), iOS-specific Health Connect nuances beyond what's documented, reminders notification scheduling (currently UI-only, no actual OS notification firing found).

Evidence gathered: README.md, CLAUDE.md/AGENTS.md, pubspec.yaml, lib/main.dart, lib/state/app_state.dart (full read in chunks), lib/models/drink_entry.dart, lib/utils/hydration_parser.dart, lib/utils/icon_helper.dart, lib/widgets/wave_painter.dart, lib/theme/app_theme.dart, screens (home/onboarding/reminders/sync/smart_log/trends - partial reads), test/ dir listing + app_state_test.dart + mock_health.dart, tool/check_coverage.dart, .github/workflows/flutter.yml + openwiki-update.yml, android/app/src/main/AndroidManifest.xml, CHANGELOG.md, git log (20 commits), git show on health connect fix commits, CONTRIBUTING.md, design/CLAUDE.md.
