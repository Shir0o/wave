import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:health/health.dart';
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

  // Health Connect & Other Apps settings
  bool _healthConnectConnected = true;
  String _lastSyncStr = '2 min ago';
  List<Map<String, dynamic>> _otherApps = [
    {'name': 'Google Fit', 'connected': true, 'status': 'Connected'},
    {'name': 'Samsung Health', 'connected': false, 'status': 'Connect'},
    {'name': 'Fitbit', 'connected': false, 'status': 'Connect'},
  ];
  List<Map<String, dynamic>> _permissions = [
    {
      'label': 'Read hydration',
      'desc': 'Pull water logged in other apps',
      'enabled': true,
    },
    {
      'label': 'Write hydration',
      'desc': 'Save your logs to Health Connect',
      'enabled': true,
    },
    {
      'label': 'Nutrition',
      'desc': 'Caffeine & calories from drinks',
      'enabled': true,
    },
    {
      'label': 'Activity & workouts',
      'desc': 'Raise your goal on active days',
      'enabled': true,
    },
    {
      'label': 'Body weight',
      'desc': 'Personalize your daily target',
      'enabled': false,
    },
  ];

  // Health Connect synced variables
  int _syncedSteps = 0;
  double _syncedWeightLbs = 0.0;

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

  double get goalOz {
    double baseGoal = _goalOz;
    if (_healthConnectConnected) {
      if (_permissions[4]['enabled'] == true && _syncedWeightLbs > 0.0) {
        baseGoal = _syncedWeightLbs * 0.5;
      }
      if (_permissions[3]['enabled'] == true) {
        baseGoal += (_syncedSteps / 1000.0) * 4.0;
      }
    }
    return baseGoal;
  }

  int get syncedSteps => _syncedSteps;
  double get syncedWeightLbs => _syncedWeightLbs;
  bool get isDarkTheme => _isDarkTheme;
  List<DrinkEntry> get entries => _entries;
  bool get adaptiveReminders => _adaptiveReminders;
  String get wakeTime => _wakeTime;
  String get sleepTime => _sleepTime;
  int get reminderInterval => _reminderInterval;
  List<Map<String, dynamic>> get reminders => _reminders;
  bool get healthConnectConnected => _healthConnectConnected;
  String get lastSyncStr => _lastSyncStr;
  List<Map<String, dynamic>> get otherApps => _otherApps;
  List<Map<String, dynamic>> get permissions => _permissions;
  String get aiText => _aiText;
  HydrationParseResult? get aiResult => _aiResult;
  bool get aiListening => _aiListening;
  double get onbGoal => _onbGoal;
  bool get onbConnect => _onbConnect;
  String? get toastMessage => _toastMessage;

  // Constructor loads persisted settings
  AppState() {
    _loadFromPrefs().then((_) {
      _initHealth();
    });
  }

  void _initHealth() {
    Health().configure();
    if (_healthConnectConnected) {
      syncNow(silent: true);
    }
  }

  // Load from local storage
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _goalOz = prefs.getDouble('goalOz') ?? 100.0;
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _adaptiveReminders = prefs.getBool('adaptiveReminders') ?? true;
      _wakeTime = prefs.getString('wakeTime') ?? '7:00 AM';
      _sleepTime = prefs.getString('sleepTime') ?? '10:30 PM';
      _reminderInterval = prefs.getInt('reminderInterval') ?? 90;
      _healthConnectConnected = prefs.getBool('healthConnectConnected') ?? true;
      _syncedSteps = prefs.getInt('syncedSteps') ?? 0;
      _syncedWeightLbs = prefs.getDouble('syncedWeightLbs') ?? 0.0;

      final otherAppsJson = prefs.getString('otherApps');
      if (otherAppsJson != null) {
        final List<dynamic> decoded = jsonDecode(otherAppsJson);
        _otherApps = decoded.map((o) => Map<String, dynamic>.from(o)).toList();
      }

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
            id: 'm1',
            name: 'Water',
            icon: 'water_drop',
            oz: 100.0,
            hydration: 100.0,
            time: today.subtract(const Duration(days: 4)),
            source: 'Quick add',
          ),
          DrinkEntry(
            id: 'm2',
            name: 'Water',
            icon: 'water_drop',
            oz: 100.0,
            hydration: 100.0,
            time: today.subtract(const Duration(days: 3)),
            source: 'Quick add',
          ),
          DrinkEntry(
            id: 'm3',
            name: 'Water',
            icon: 'water_drop',
            oz: 100.0,
            hydration: 100.0,
            time: today.subtract(const Duration(days: 2)),
            source: 'Quick add',
          ),
          DrinkEntry(
            id: 'm4',
            name: 'Water',
            icon: 'water_drop',
            oz: 100.0,
            hydration: 100.0,
            time: today.subtract(const Duration(days: 1)),
            source: 'Quick add',
          ),
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
        _permissions = decoded
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
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
      await prefs.setString('wakeTime', _wakeTime);
      await prefs.setString('sleepTime', _sleepTime);
      await prefs.setInt('reminderInterval', _reminderInterval);
      await prefs.setBool('healthConnectConnected', _healthConnectConnected);
      await prefs.setInt('syncedSteps', _syncedSteps);
      await prefs.setDouble('syncedWeightLbs', _syncedWeightLbs);
      await prefs.setString('otherApps', jsonEncode(_otherApps));

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

  // Active hours setters
  void setWakeTime(String time) {
    _wakeTime = time;
    _saveToPrefs();
    notifyListeners();
  }

  void setSleepTime(String time) {
    _sleepTime = time;
    _saveToPrefs();
    notifyListeners();
  }

  // Other Apps toggle
  void toggleOtherApp(int index) {
    final bool curr = _otherApps[index]['connected'] == true;
    _otherApps[index]['connected'] = !curr;
    _otherApps[index]['status'] = !curr ? 'Connected' : 'Connect';
    _saveToPrefs();
    notifyListeners();
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
    _postLogToHealthConnect(entry);
  }

  // Health Connect upload helpers
  void _postLogToHealthConnect(DrinkEntry entry) {
    if (_healthConnectConnected) {
      if (_permissions[1]['enabled'] == true) {
        _writeHydrationToHealthConnect(entry);
      }
      if (_permissions[2]['enabled'] == true) {
        _writeNutritionToHealthConnect(entry);
      }
    }
  }

  Future<void> _writeHydrationToHealthConnect(DrinkEntry entry) async {
    try {
      final double liters = entry.hydration / 33.814;
      bool success = await Health().writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: entry.time,
        endTime: entry.time,
      );
      if (success) {
        debugPrint('Successfully wrote hydration to Health Connect: $liters L');
      } else {
        debugPrint('Failed to write hydration to Health Connect');
      }
    } catch (e) {
      debugPrint('Error writing hydration to Health Connect: $e');
    }
  }

  Future<void> _writeNutritionToHealthConnect(DrinkEntry entry) async {
    try {
      if (entry.name.toLowerCase() == 'coffee') {
        final double caffeineMg = entry.oz * 12.5;
        if (Platform.isAndroid) {
          await Health().writeMeal(
            mealType: MealType.SNACK,
            startTime: entry.time,
            endTime: entry.time,
            name: 'Coffee',
            caffeine: caffeineMg,
          );
        } else {
          await Health().writeHealthData(
            value: caffeineMg,
            type: HealthDataType.DIETARY_CAFFEINE,
            startTime: entry.time,
            endTime: entry.time,
          );
        }
      }
    } catch (e) {
      debugPrint('Error writing nutrition to Health Connect: $e');
    }
  }

  // Quick Add convenience methods
  void quickAddGlass() {
    addDrinkEntry(
      DrinkEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Water',
        icon: 'water_drop',
        oz: 8.0,
        hydration: 8.0,
        time: DateTime.now(),
        source: 'Quick add',
      ),
    );
  }

  void quickAddBottle() {
    addDrinkEntry(
      DrinkEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Water',
        icon: 'water_drop',
        oz: 16.0,
        hydration: 16.0,
        time: DateTime.now(),
        source: 'Quick add',
      ),
    );
  }

  void quickAddCoffee() {
    addDrinkEntry(
      DrinkEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Coffee',
        icon: 'local_cafe',
        oz: 12.0,
        hydration: 10.0,
        time: DateTime.now(),
        source: 'Quick add',
      ),
    );
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
      final entry = DrinkEntry(
        id: '${now.microsecondsSinceEpoch}_${parsed.name}',
        name: parsed.name,
        icon: parsed.icon,
        oz: parsed.oz,
        hydration: parsed.hydration,
        time: now,
        source: 'AI log',
      );
      _entries.add(entry);
      _postLogToHealthConnect(entry);
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

  // Health Connect real operations
  List<HealthDataType> _mapPermissionToTypes(int index) {
    switch (index) {
      case 0: // Read hydration
        return [HealthDataType.WATER];
      case 1: // Write hydration
        return [HealthDataType.WATER];
      case 2: // Nutrition
        if (Platform.isAndroid) {
          return [HealthDataType.NUTRITION];
        }
        return [
          HealthDataType.DIETARY_CAFFEINE,
          HealthDataType.DIETARY_ENERGY_CONSUMED,
        ];
      case 3: // Activity & workouts
        return [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
      case 4: // Body weight
        return [HealthDataType.WEIGHT];
      default:
        return [];
    }
  }

  List<HealthDataAccess> _mapPermissionToAccess(int index) {
    switch (index) {
      case 0:
        return [HealthDataAccess.READ];
      case 1:
        return [HealthDataAccess.WRITE];
      case 2:
        if (Platform.isAndroid) {
          return [HealthDataAccess.READ_WRITE];
        }
        return [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE];
      case 3:
        return [HealthDataAccess.READ, HealthDataAccess.READ];
      case 4:
        return [HealthDataAccess.READ];
      default:
        return [];
    }
  }

  Future<bool> _requestHealthPermissions() async {
    try {
      final List<HealthDataType> types = [];
      final List<HealthDataAccess> accessList = [];

      for (int i = 0; i < _permissions.length; i++) {
        if (_permissions[i]['enabled'] == true) {
          final typesForPerm = _mapPermissionToTypes(i);
          final accessForPerm = _mapPermissionToAccess(i);
          for (int j = 0; j < typesForPerm.length; j++) {
            if (!types.contains(typesForPerm[j])) {
              types.add(typesForPerm[j]);
              accessList.add(accessForPerm[j]);
            } else {
              final idx = types.indexOf(typesForPerm[j]);
              if (accessList[idx] != accessForPerm[j]) {
                accessList[idx] = HealthDataAccess.READ_WRITE;
              }
            }
          }
        }
      }

      if (types.isEmpty) return true;

      bool granted = await Health().requestAuthorization(
        types,
        permissions: accessList,
      );
      return granted;
    } catch (e) {
      debugPrint('Error requesting health permissions: $e');
      return false;
    }
  }

  void toggleHealthConnect() async {
    if (!_healthConnectConnected) {
      bool granted = await _requestHealthPermissions();
      if (granted) {
        _healthConnectConnected = true;
        _lastSyncStr = 'just now';
        showToast('Connected to Health Connect');
        syncNow();
      } else {
        showToast('Permission denied');
      }
    } else {
      _healthConnectConnected = false;
      showToast('Disconnected');
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> syncNow({bool silent = false}) async {
    if (!_healthConnectConnected) return;

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // 1. Sync Hydration logs (Read Hydration)
      if (_permissions[0]['enabled'] == true) {
        List<HealthDataPoint> waterPoints = await Health()
            .getHealthDataFromTypes(
              startTime: midnight,
              endTime: now,
              types: [HealthDataType.WATER],
            );
        for (var point in waterPoints) {
          if (point.value is NumericHealthValue) {
            if (point.sourceId == 'com.twang.wave.wave') continue;
            if (_entries.any((e) => e.id == point.uuid)) continue;

            final double liters = (point.value as NumericHealthValue)
                .numericValue
                .toDouble();
            final double oz = liters * 33.814;

            _entries.add(
              DrinkEntry(
                id: point.uuid,
                name: 'Water',
                icon: 'water_drop',
                oz: oz.roundToDouble(),
                hydration: oz.roundToDouble(),
                time: point.dateFrom,
                source: 'Health Connect',
              ),
            );
          }
        }
      }

      // 2. Sync Steps / Activity
      if (_permissions[3]['enabled'] == true) {
        List<HealthDataPoint> stepsPoints = await Health()
            .getHealthDataFromTypes(
              startTime: midnight,
              endTime: now,
              types: [HealthDataType.STEPS],
            );
        int steps = 0;
        for (var point in stepsPoints) {
          if (point.value is NumericHealthValue) {
            steps += (point.value as NumericHealthValue).numericValue.round();
          }
        }
        _syncedSteps = steps;
      }

      // 3. Sync Body Weight
      if (_permissions[4]['enabled'] == true) {
        List<HealthDataPoint> weightPoints = await Health()
            .getHealthDataFromTypes(
              startTime: now.subtract(const Duration(days: 30)),
              endTime: now,
              types: [HealthDataType.WEIGHT],
            );
        if (weightPoints.isNotEmpty) {
          weightPoints.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
          var newestWeight = weightPoints.first;
          if (newestWeight.value is NumericHealthValue) {
            double weightKg = (newestWeight.value as NumericHealthValue)
                .numericValue
                .toDouble();
            _syncedWeightLbs = weightKg * 2.20462;
          }
        }
      }

      _lastSyncStr = 'just now';
      if (!silent) {
        showToast('Synced with Health Connect');
      }
      _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing with Health Connect: $e');
      if (!silent) {
        showToast('Sync failed');
      }
    }
  }

  void togglePermission(int index) async {
    final bool newval = !_permissions[index]['enabled'];
    _permissions[index]['enabled'] = newval;
    _saveToPrefs();
    notifyListeners();

    if (_healthConnectConnected && newval) {
      final types = _mapPermissionToTypes(index);
      final access = _mapPermissionToAccess(index);
      bool granted = await Health().requestAuthorization(
        types,
        permissions: access,
      );
      if (granted) {
        showToast('Permission granted');
        syncNow();
      } else {
        _permissions[index]['enabled'] = false;
        _saveToPrefs();
        notifyListeners();
        showToast('Permission denied');
      }
    }
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

  void finishOnboarding() async {
    _goalOz = _onbGoal;
    _healthConnectConnected = _onbConnect;
    _currentScreen = 'home';
    showToast("You're all set");
    _saveToPrefs();
    notifyListeners();
    if (_healthConnectConnected) {
      bool granted = await _requestHealthPermissions();
      if (granted) {
        syncNow();
      }
    }
  }

  // Statistics calculation helpers
  double get totalConsumedToday {
    final today = DateTime.now();
    return _entries
        .where(
          (e) =>
              e.time.year == today.year &&
              e.time.month == today.month &&
              e.time.day == today.day,
        )
        .fold(0.0, (sum, e) => sum + e.hydration);
  }

  int get currentStreak {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final targetDate = todayDate.subtract(Duration(days: i));
      final dayTotal = _entries
          .where((e) =>
              e.time.year == targetDate.year &&
              e.time.month == targetDate.month &&
              e.time.day == targetDate.day)
          .fold(0.0, (sum, e) => sum + e.hydration);

      if (dayTotal >= goalOz) {
        streak++;
      } else {
        if (i == 0) continue;
        break;
      }
    }
    return streak;
  }

  List<double> get weeklyHydrationData {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    List<double> result = [];
    for (int i = 6; i >= 0; i--) {
      final targetDate = todayDate.subtract(Duration(days: i));
      final dayTotal = _entries
          .where((e) =>
              e.time.year == targetDate.year &&
              e.time.month == targetDate.month &&
              e.time.day == targetDate.day)
          .fold(0.0, (sum, e) => sum + e.hydration);
      result.add(dayTotal);
    }
    return result;
  }

  String get hydrationInsight {
    final today = DateTime.now();
    final todayEntries = _entries.where((e) =>
        e.time.year == today.year &&
        e.time.month == today.month &&
        e.time.day == today.day).toList();
    if (todayEntries.isEmpty) {
      return 'Start your day with a fresh glass of water to kickstart hydration!';
    }
    double morningTotal = 0.0;
    double afternoonTotal = 0.0;
    for (var e in todayEntries) {
      if (e.time.hour < 12) {
        morningTotal += e.hydration;
      } else {
        afternoonTotal += e.hydration;
      }
    }
    if (morningTotal > afternoonTotal) {
      return 'Great morning momentum! Keep steady intake through the afternoon wave.';
    } else if (afternoonTotal > morningTotal) {
      return 'Strong afternoon recovery! Try starting with a larger morning glass tomorrow.';
    } else {
      return 'Balanced hydration flow! You ride a steady wave across your day.';
    }
  }
}
