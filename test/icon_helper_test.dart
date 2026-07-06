import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave/utils/icon_helper.dart';

void main() {
  group('IconHelper Tests', () {
    test('getIconData returns correct icons for each name', () {
      expect(getIconData('bolt'), Icons.bolt_rounded);
      expect(getIconData('bubble_chart'), Icons.bubble_chart_rounded);
      expect(getIconData('water_drop'), Icons.water_drop_rounded);
      expect(
        getIconData('emoji_food_beverage'),
        Icons.emoji_food_beverage_rounded,
      );
      expect(getIconData('local_cafe'), Icons.local_cafe_rounded);
      expect(getIconData('local_bar'), Icons.local_bar_rounded);
      expect(getIconData('grocery'), Icons.local_grocery_store_rounded);
      expect(getIconData('sports_bar'), Icons.sports_bar_rounded);
      expect(getIconData('local_drink'), Icons.local_drink_rounded);
    });

    test('getIconData falls back to water_drop_rounded for unknown icons', () {
      expect(getIconData('unknown_icon'), Icons.water_drop_rounded);
      expect(getIconData(''), Icons.water_drop_rounded);
    });
  });
}
