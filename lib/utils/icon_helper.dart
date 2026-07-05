import 'package:flutter/material.dart';

IconData getIconData(String name) {
  switch (name) {
    case 'bolt':
      return Icons.bolt_rounded;
    case 'bubble_chart':
      return Icons.bubble_chart_rounded;
    case 'water_drop':
      return Icons.water_drop_rounded;
    case 'emoji_food_beverage':
      return Icons.emoji_food_beverage_rounded;
    case 'local_cafe':
      return Icons.local_cafe_rounded;
    case 'local_bar':
      return Icons.local_bar_rounded;
    case 'grocery':
      return Icons.local_grocery_store_rounded;
    case 'sports_bar':
      return Icons.sports_bar_rounded;
    case 'local_drink':
      return Icons.local_drink_rounded;
    default:
      return Icons.water_drop_rounded;
  }
}
