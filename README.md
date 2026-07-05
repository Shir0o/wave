# Wave - Hydration Tracker

**Wave** is an immersive water drink reminder application built with Flutter. It utilizes a custom offline natural-language parser to easily log drinks by description (e.g. *"two glasses of water and a cold brew"*), supports dual-layer custom fluid wave animations, incorporates adaptive notification algorithms, and integrates with mock health dashboards.

Developed for **iOS** and **Android**.

## ✨ Features

- 🌊 **Immersive Wave Animation**: Dynamic dual-wave rendering reflecting your current progress, with custom rising and fading bubble animations.
- 🤖 **Offline Smart Log**: An offline-ready regex-based natural language drink parser that extracts drink types, volumes (ml, l, oz, cups), and maps custom hydration coefficients (e.g., electrolytes hydrations are boosted, alcohol reduces progress).
- 🎙️ **Simulated Input Workflows**: Integrated voice dictation and camera photo-scanning mock flows to demonstrate hands-free logging.
- 🔔 **Adaptive Reminders**: Custom settings for sleep/wake windows and active hours to pace notifications around your actual hydration rate.
- 📊 **Trends Dashboard**: Weekly intake bar charts, streak milestones, goal counts, and hydration habit insights.
- ❤️ **Health Connect Panel**: A hub showing connection states, permission controls, and partner app integrations.

---

## 🛠️ Technology Stack

- **Framework**: Flutter (iOS & Android)
- **Language**: Dart
- **Design System**: Material 3 styled with custom Fredoka rounded typography
- **State Management**: `Provider` (lightweight ChangeNotifier model)
- **Local Persistence**: `shared_preferences`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK
- Xcode (for iOS development)
- Android Studio & SDK (for Android development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Shir0o/wave.git
   cd wave
   ```

2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```

3. Run the test suite:
   ```bash
   flutter test
   ```

4. Build and run on a emulator/device:
   ```bash
   # Run on default connected device
   flutter run
   ```

---

## 📂 Codebase Structure

```
lib/
├── main.dart                 # App wrapper, theme bindings, navigation shell
├── models/
│   └── drink_entry.dart      # Hydration log data model (with JSON serialization)
├── screens/
│   ├── home_screen.dart      # Main hub with wave container and today's log list
│   ├── onboarding_screen.dart# Initial goal adjustments and sync settings
│   ├── reminders_screen.dart # Active hours, notification intervals, and alarms
│   ├── smart_log_screen.dart # Natural language search and speech dictation triggers
│   ├── sync_screen.dart      # Health Connect and fit sync configurations
│   └── trends_screen.dart    # Weekly bar chart and streak milestones
├── state/
│   └── app_state.dart        # Global ChangeNotifier handling state logic & storage
├── theme/
│   └── app_theme.dart        # Custom color tokens for dark/light modes
├── utils/
│   ├── hydration_parser.dart # Natural-language parser port
│   └── icon_helper.dart      # String-to-IconData mappings
└── widgets/
    └── wave_painter.dart     # Sine-wave custom painter and bubble animation
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
