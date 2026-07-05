import 'package:flutter_test/flutter_test.dart';
import 'package:wave/utils/hydration_parser.dart';

void main() {
  group('HydrationParser Tests', () {
    test('Empty text parsing returns empty results', () {
      final res = HydrationParser.parse('');
      expect(res.items, isEmpty);
      expect(res.oz, 0.0);
      expect(res.hydration, 0.0);
      expect(res.confidence, 0.0);
    });

    test('Single standard drink: 16 oz iced latte', () {
      final res = HydrationParser.parse('16 oz iced latte');
      expect(res.items.length, 1);
      final item = res.items[0];
      expect(item.name, 'Coffee');
      expect(item.oz, 16.0);
      expect(item.hydration, 13.0); // 16 * 0.8 = 12.8, rounded to 13
      expect(res.confidence, 0.92);
    });

    test('Single container drink: a venti oat latte', () {
      final res = HydrationParser.parse('a venti oat latte');
      expect(res.items.length, 1);
      final item = res.items[0];
      expect(item.name, 'Coffee');
      expect(item.oz, 20.0); // venti = 20
      expect(item.hydration, 16.0); // 20 * 0.8 = 16
      expect(res.confidence, 0.92);
    });

    test('Multiple drinks: two glasses of water and a cold brew', () {
      final res = HydrationParser.parse('two glasses of water and a cold brew');
      expect(res.items.length, 2);

      // Drink 1: two glasses of water
      final water = res.items[0];
      expect(water.name, 'Water');
      expect(water.oz, 24.0); // 2 servings * 12 oz = 24 oz (JS default)
      expect(water.hydration, 24.0);

      // Drink 2: a cold brew
      final coffee = res.items[1];
      expect(coffee.name, 'Coffee');
      expect(coffee.oz, 12.0); // default 12 oz
      expect(coffee.hydration, 10.0); // 12 * 0.8 = 9.6, rounded to 10
    });

    test('Metric volume: 500 ml sparkling water', () {
      final res = HydrationParser.parse('500 ml sparkling water');
      expect(res.items.length, 1);
      final item = res.items[0];
      expect(item.name, 'Sparkling water');
      expect(item.oz, (500 * 0.033814).roundToDouble()); // 17.0 oz
      expect(item.hydration, 17.0);
    });

    test('Fallback to default water cup when no match', () {
      final res = HydrationParser.parse('something random');
      expect(res.items.length, 1);
      final item = res.items[0];
      expect(item.name, 'Water');
      expect(item.oz, 8.0);
      expect(item.hydration, 8.0);
      expect(res.confidence, 0.4);
    });
  });
}
