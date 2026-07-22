# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Wired active hours wake and sleep time picker dialogs in `RemindersScreen`.
- Added dynamic streak counter calculation in `AppState` and bound to `TrendsScreen`.
- Added dynamic 7-day intake calculation for weekly hydration chart and personalized intake insights.
- Added interactive connection dialogs and state management for Google Fit, Samsung Health, and Fitbit in `SyncScreen`.
- Added unit and widget test suite covering active hours, dynamic streak calculation, weekly hydration data, and third-party app toggling.
- Added versioned GitHub main branch protection ruleset JSON template (`.github/rulesets/main-branch-protection.json`) enforcing PR review approvals, status check completion, linear history, and admin bypass.

### Fixed
- Fixed race condition between `_loadFromPrefs()` and `_initHealth()` in `AppState` constructor.
- Added Android 14+ Health Connect rationale intent filter (`android.intent.action.VIEW_PERMISSION_USAGE`) and package visibility queries in `AndroidManifest.xml`.

## [1.0.0] - 2026-07-06

### Added
- Integrated Google Health Connect for reading/writing hydration and nutrition data.
- Set test coverage threshold to 90% and added initial unit/widget test suite.
- Initial scaffold of Wave hydration tracker app with dark mode support, quick add drinks, and smart natural language log parser.

### Fixed
- Resolved unsupported Health Connect types on Android.
- Resolved GitHub CI formatting, analysis, and channel mock compliance.
