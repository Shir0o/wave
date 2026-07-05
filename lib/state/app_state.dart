import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/models/drink_entry.dart';
import 'package:wave/utils/hydration_parser.dart';

class AppState extends ChangeNotifier {
  String _currentScreen = 'home';
  double _goalOz = 100.0;
  bool _isDarkTheme = false;
  List<DrinkEntry> _entries = [];

  // Reminder settings
  bool _adaptiveReminders = true;
  String _wakeTime = '7:00 AM';
  String _sleepTime = '10:30 PM';
  int _reminderInterval = 90; // in minutes
  List<Map<String, dynamic>> _reminders = [
    {'time': '8:00 AM', 'enabled': true},
    {'time': '9:30 AM', 'enabled': true},
    {'time': '11:00 AM', 'enabled': true},
    {'time': '1:00 PM', 'enabled': true},
    {'time': '3:00 PM', 'enabled': false},
    {'time': '5:30 PM', 'enabled': true},
    {'time': '7:30 PM', 'enabled': true},
  ];

  // Health Connect settings
  bool _healthConnectConnected = true;
  String _lastSyncStr = '2 min ago';
  List<Map<String, dynamic>> _permissions = [
    {'label': 'Read hydration', 'desc': 'Pull water logged in other apps', 'enabled': true},
    {'label': 'Write hydration', 'desc': 'Save your logs to Health Connect', 'enabled': true},
    {'label': 'Nutrition', 'desc': 'Caffeine & calories from drinks', 'enabled': true},
    {'label': 'Activity & workouts', 'desc': 'Raise your goal on active days', 'enabled': true},
    {'label': 'Body weight', 'desc': 'Personalize your daily target', 'enabled': false},
  ];

  // AI log screen transient states
  String _aiText = '';
  HydrationParseResult? _aiResult;
  bool _aiListening = false;

  // Onboarding temporary states
  double _onbGoal = 100.0;
  bool _onbConnect = true;

  // Toast notifications
  String? _toastMessage;

  // Getters
  String get currentScreen => _currentScreen;
  double get goalOz => _goalOz;
  bool get isDarkTheme => _isDarkTheme;
  List<DrinkEntry> get entries => _entries;
  bool get adaptiveReminders => _adaptiveReminders;
  String get wakeTime => _wakeTime;
  String get sleepTime => _sleepTime;
  int get reminderInterval => _reminderInterval;
  List<Map<String, dynamic>> get reminders => _reminders;
  bool get healthConnectConnected => _healthConnectConnected;
  String get lastSyncStr => _lastSyncStr;
  List<Map<String, dynamic>> get permissions => _permissions;
  String get aiText => _aiText;
  HydrationParseResult? get aiResult => _aiResult;
  bool get aiListening => _aiListening;
  double get onbGoal => _onbGoal;
  bool get onbConnect => _onbConnect;
  String? get toastMessage => _toastMessage;

  // Constructor loads persisted settings
  AppState() {
    _loadFromPrefs();
  }

  // Load from local storage
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _goalOz = prefs.getDouble('goalOz') ?? 100.0;
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _adaptiveReminders = prefs.getBool('adaptiveReminders') ?? true;
      _reminderInterval = prefs.getInt('reminderInterval') ?? 90;
      _healthConnectConnected = prefs.getBool('healthConnectConnected') ?? true;

      // Load entries
      final entriesJson = prefs.getString('entries');
      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        _entries = decoded.map((e) => DrinkEntry.fromJson(e)).toList();
      } else {
        // Mock default entries for prototype if empty
        final today = DateTime.now();
        _entries = [
          DrinkEntry(
            id: '1',
            name: 'Water',
            icon: 'water_drop',
            oz: 16.0,
            hydration: 16.0,
            time: DateTime(today.year, today.month, today.day, 7, 20),
            source: 'Quick add',
          ),
          DrinkEntry(
            id: '2',
            name: 'Coffee',
            icon: 'local_cafe',
            oz: 12.0,
            hydration: 10.0,
            time: DateTime(today.year, today.month, today.day, 9, 45),
            source: 'AI log',
          ),
          DrinkEntry(
            id: '3',
            name: 'Water',
            icon: 'water_drop',
            oz: 8.0,
            hydration: 8.0,
            time: DateTime(today.year, today.month, today.day, 12, 30),
            source: 'Quick add',
          ),
        ];
      }

      // Load reminders
      final remindersJson = prefs.getString('reminders');
      if (remindersJson != null) {
        final List<dynamic> decoded = jsonDecode(remindersJson);
        _reminders = decoded.map((r) => Map<String, dynamic>.from(r)).toList();
      }

      // Load permissions
      final permsJson = prefs.getString('permissions');
      if (permsJson != null) {
        final List<dynamic> decoded = jsonDecode(permsJson);
        _permissions = decoded.map((p) => Map<String, dynamic>.from(p)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Save changes to local storage
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('goalOz', _goalOz);
      await prefs.setBool('isDarkTheme', _isDarkTheme);
      await prefs.setBool('adaptiveReminders', _adaptiveReminders);
      await prefs.setInt('reminderInterval', _reminderInterval);
      await prefs.setBool('healthConnectConnected', _healthConnectConnected);

      final entriesJson = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString('entries', entriesJson);

      final remindersJson = jsonEncode(_reminders);
      await prefs.setString('reminders', remindersJson);

      final permsJson = jsonEncode(_permissions);
      await prefs.setString('permissions', permsJson);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  // Navigation
  void navigateTo(String screenName) {
    _currentScreen = screenName;
    if (screenName == 'onboard') {
      _onbGoal = _goalOz;
      _onbConnect = _healthConnectConnected;
    }
    notifyListeners();
  }

  // Toast helper
  void showToast(String message) {
    _toastMessage = message;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (_toastMessage == message) {
        _toastMessage = null;
        notifyListeners();
      }
    });
  }

  // Toggle Theme
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  // Add Log Entry
  void addDrinkEntry(DrinkEntry entry) {
    _entries.add(entry);
    showToast('+${entry.oz.round()} oz ${entry.name}');
    _saveToPrefs();
    notifyListeners();
  }

  // Quick Add convenience methods
  void quickAddGlass() {
    addDrinkEntry(DrinkEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: 'Water',
      icon: 'water_drop',
      oz: 8.0,
      hydration: 8.0,
      time: DateTime.now(),
      source: 'Quick add',
    ));
  }

  void quickAddBottle() {
    addDrinkEntry(DrinkEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: 'Water',
      icon: 'water_drop',
      oz: 16.0,
      hydration: 16.0,
      time: DateTime.now(),
      source: 'Quick add',
    ));
  }

  void quickAddCoffee() {
    addDrinkEntry(DrinkEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: 'Coffee',
      icon: 'local_cafe',
      oz: 12.0,
      hydration: 10.0,
      time: DateTime.now(),
      source: 'Quick add',
    ));
  }

  // Remove Entry
  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // AI Input parsing
  void setAiText(String text) {
    _aiText = text;
    if (text.trim().isNotEmpty) {
      _aiResult = HydrationParser.parse(text);
    } else {
      _aiResult = null;
    }
    notifyListeners();
  }

  void clearAi() {
    _aiText = '';
    _aiResult = null;
    notifyListeners();
  }

  void triggerVoiceSim() {
    _aiListening = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1100), () {
      _aiListening = false;
      const text = 'two glasses of water and a cold brew';
      _aiText = text;
      _aiResult = HydrationParser.parse(text);
      notifyListeners();
    });
  }

  void triggerPhotoSim() {
    final list = HydrationParser.photoSamples;
    final text = list[(DateTime.now().millisecond % list.length)];
    setAiText(text);
  }

  void confirmAiLog() {
    if (_aiResult == null || _aiResult!.items.isEmpty) return;
    final now = DateTime.now();
    for (final parsed in _aiResult!.items) {
      _entries.add(DrinkEntry(
        id: '${now.microsecondsSinceEpoch}_${parsed.name}',
        name: parsed.name,
        icon: parsed.icon,
        oz: parsed.oz,
        hydration: parsed.hydration,
        time: now,
        source: 'AI log',
      ));
    }
    showToast('Logged +${_aiResult!.hydration.round()} oz');
    _aiText = '';
    _aiResult = null;
    _currentScreen = 'home';
    _saveToPrefs();
    notifyListeners();
  }

  // Reminders configurations
  void toggleAdaptiveReminders() {
    _adaptiveReminders = !_adaptiveReminders;
    _saveToPrefs();
    notifyListeners();
  }

  void incrementInterval() {
    if (_reminderInterval < 240) {
      _reminderInterval += 15;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void decrementInterval() {
    if (_reminderInterval > 30) {
      _reminderInterval -= 15;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void toggleReminderRow(int index) {
    _reminders[index]['enabled'] = !_reminders[index]['enabled'];
    _saveToPrefs();
    notifyListeners();
  }

  // Health Connect config
  void toggleHealthConnect() {
    _healthConnectConnected = !_healthConnectConnected;
    _lastSyncStr = _healthConnectConnected ? 'just now' : _lastSyncStr;
    showToast(_healthConnectConnected ? 'Connected to Health Connect' : 'Disconnected');
    _saveToPrefs();
    notifyListeners();
  }

  void syncNow() {
    _lastSyncStr = 'just now';
    showToast('Synced with Health Connect');
    notifyListeners();
  }

  void togglePermission(int index) {
    _permissions[index]['enabled'] = !_permissions[index]['enabled'];
    _saveToPrefs();
    notifyListeners();
  }

  // Onboarding controls
  void adjustOnbGoal(double delta) {
    _onbGoal = (onbGoal + delta).clamp(48.0, 200.0);
    notifyListeners();
  }

  void toggleOnbConnect() {
    _onbConnect = !_onbConnect;
    notifyListeners();
  }

  void finishOnboarding() {
    _goalOz = _onbGoal;
    _healthConnectConnected = _onbConnect;
    _currentScreen = 'home';
    showToast("You're all set");
    _saveToPrefs();
    notifyListeners();
  }

  // Statistics calculation helpers
  double get totalConsumedToday {
    final today = DateTime.now();
    return _entries
        .where((e) => e.time.year == today.year && e.time.month == today.month && e.time.day == today.day)
        .fold(0.0, (sum, e) => sum + e.hydration);
  }

  List<double> get weeklyHydrationData {
    // Return standard week logs + today's logs
    // Design template historical values: Mon: 82, Tue: 64, Wed: 98, Thu: 58, Fri: 100, Sat: 70
    return [82.0, 64.0, 98.0, 58.0, 100.0, 70.0, totalConsumedToday];
  }
}
