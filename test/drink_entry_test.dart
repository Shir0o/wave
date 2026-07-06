import 'package:flutter_test/flutter_test.dart';
import 'package:wave/models/drink_entry.dart';

void main() {
  group('DrinkEntry Tests', () {
    final now = DateTime.now();

    test('constructor sets values correctly', () {
      final entry = DrinkEntry(
        id: 'test-id',
        name: 'Water',
        icon: 'water_drop',
        oz: 12.0,
        hydration: 12.0,
        time: now,
        source: 'Manual add',
      );

      expect(entry.id, 'test-id');
      expect(entry.name, 'Water');
      expect(entry.icon, 'water_drop');
      expect(entry.oz, 12.0);
      expect(entry.hydration, 12.0);
      expect(entry.time, now);
      expect(entry.source, 'Manual add');
    });

    test('toJson and fromJson serialization works correctly', () {
      final entry = DrinkEntry(
        id: 'test-id-2',
        name: 'Orange Juice',
        icon: 'local_bar',
        oz: 8.0,
        hydration: 6.8,
        time: now,
        source: 'Quick add',
      );

      final json = entry.toJson();
      expect(json['id'], 'test-id-2');
      expect(json['name'], 'Orange Juice');
      expect(json['icon'], 'local_bar');
      expect(json['oz'], 8.0);
      expect(json['hydration'], 6.8);
      expect(json['time'], now.toIso8601String());
      expect(json['source'], 'Quick add');

      final fromJson = DrinkEntry.fromJson(json);
      expect(fromJson.id, entry.id);
      expect(fromJson.name, entry.name);
      expect(fromJson.icon, entry.icon);
      expect(fromJson.oz, entry.oz);
      expect(fromJson.hydration, entry.hydration);
      expect(fromJson.time.toIso8601String(), entry.time.toIso8601String());
      expect(fromJson.source, entry.source);
    });

    test('fromJson handles null id and auto-generates it', () {
      final json = {
        'name': 'Soda',
        'icon': 'local_drink',
        'oz': 12.0,
        'hydration': 9.0,
        'time': now.toIso8601String(),
        'source': 'AI log',
      };

      final entry = DrinkEntry.fromJson(json);
      expect(entry.id, isNotEmpty);
      expect(entry.name, 'Soda');
      expect(entry.icon, 'local_drink');
      expect(entry.oz, 12.0);
      expect(entry.hydration, 9.0);
      expect(entry.time.toIso8601String(), now.toIso8601String());
      expect(entry.source, 'AI log');
    });

    test('copyWith creates correct duplicates with overrides', () {
      final entry = DrinkEntry(
        id: 'original-id',
        name: 'Coffee',
        icon: 'local_cafe',
        oz: 12.0,
        hydration: 9.6,
        time: now,
        source: 'Quick add',
      );

      final copied = entry.copyWith(
        id: 'new-id',
        oz: 16.0,
        hydration: 12.8,
      );

      expect(copied.id, 'new-id');
      expect(copied.name, 'Coffee');
      expect(copied.icon, 'local_cafe');
      expect(copied.oz, 16.0);
      expect(copied.hydration, 12.8);
      expect(copied.time, now);
      expect(copied.source, 'Quick add');

      final copiedNoParams = entry.copyWith();
      expect(copiedNoParams.id, entry.id);
      expect(copiedNoParams.name, entry.name);
      expect(copiedNoParams.icon, entry.icon);
      expect(copiedNoParams.oz, entry.oz);
      expect(copiedNoParams.hydration, entry.hydration);
      expect(copiedNoParams.time, entry.time);
      expect(copiedNoParams.source, entry.source);
    });
  });
}
