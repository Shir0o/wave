import 'dart:math' as math;

class ParsedItem {
  final String name;
  final String icon;
  final double oz;
  final double hydration;
  final double factor;
  final double qty;

  ParsedItem({
    required this.name,
    required this.icon,
    required this.oz,
    required this.hydration,
    required this.factor,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'oz': oz,
        'hydration': hydration,
        'factor': factor,
        'qty': qty,
      };

  factory ParsedItem.fromJson(Map<String, dynamic> json) => ParsedItem(
        name: json['name'] as String,
        icon: json['icon'] as String,
        oz: (json['oz'] as num).toDouble(),
        hydration: (json['hydration'] as num).toDouble(),
        factor: (json['factor'] as num).toDouble(),
        qty: (json['qty'] as num).toDouble(),
      );
}

class HydrationParseResult {
  final List<ParsedItem> items;
  final double oz;
  final double hydration;
  final double confidence;

  HydrationParseResult({
    required this.items,
    required this.oz,
    required this.hydration,
    required this.confidence,
  });
}

class ContainerRule {
  final RegExp re;
  final double oz;
  ContainerRule(String pattern, this.oz) : re = RegExp(pattern, caseSensitive: false);
}

class DrinkRule {
  final RegExp re;
  final String name;
  final String icon;
  final double factor;
  DrinkRule(String pattern, this.name, this.icon, this.factor)
      : re = RegExp(pattern, caseSensitive: false);
}

class HydrationParser {
  static const double ML_TO_OZ = 0.033814;
  static const double L_TO_OZ = 33.814;

  static final Map<String, double> numWords = {
    'a': 1.0,
    'an': 1.0,
    'one': 1.0,
    'two': 2.0,
    'three': 3.0,
    'four': 4.0,
    'five': 5.0,
    'six': 6.0,
    'seven': 7.0,
    'eight': 8.0,
    'nine': 9.0,
    'ten': 10.0,
    'half': 0.5,
    'couple': 2.0,
    'few': 3.0,
    'several': 3.0,
  };

  static final List<ContainerRule> containers = [
    ContainerRule(r'\b(venti|large|big|tall|jumbo)\b', 20.0),
    ContainerRule(r'\b(grande|medium|regular)\b', 16.0),
    ContainerRule(r'\bpint\b', 16.0),
    ContainerRule(r'\bbottle\b', 16.0),
    ContainerRule(r'\bmug\b', 12.0),
    ContainerRule(r'\bcan\b', 12.0),
    ContainerRule(r'\b(small|short|shot|espresso)\b', 4.0),
    ContainerRule(r'\b(glass|cup)\b', 8.0),
    ContainerRule(r'\b(sip|swig)\b', 2.0),
  ];

  static final List<DrinkRule> drinks = [
    DrinkRule(r'electrolyte|lmnt|liquid iv|pedialyte', 'Electrolytes', 'bolt', 1.1),
    DrinkRule(r'sparkling|seltzer|soda water|club soda', 'Sparkling water', 'bubble_chart', 1.0),
    DrinkRule(r'\bwater\b|h2o|hydrate', 'Water', 'water_drop', 1.0),
    DrinkRule(r'matcha|green tea|herbal|chamomile|\btea\b', 'Tea', 'emoji_food_beverage', 0.9),
    DrinkRule(r'latte|cappuccino|cappucino|mocha|americano|cold brew|espresso|coffee|flat white', 'Coffee', 'local_cafe', 0.8),
    DrinkRule(r'smoothie|juice|lemonade', 'Juice', 'local_bar', 0.85),
    DrinkRule(r'oat milk|almond milk|\bmilk\b|latte milk', 'Milk', 'grocery', 0.9),
    DrinkRule(r'gatorade|powerade|sports drink|energy drink', 'Sports drink', 'sports_bar', 0.9),
    DrinkRule(r'soda|cola|coke|pepsi|sprite|fanta|pop\b', 'Soft drink', 'local_drink', 0.75),
    DrinkRule(r'\b(beer|wine|cocktail|whiskey|vodka|margarita|alcohol)\b', 'Alcohol', 'sports_bar', 0.4),
  ];

  static final List<String> photoSamples = [
    'Stainless steel bottle, ~24 oz water',
    '16 oz iced latte',
    '500 ml sparkling water',
  ];

  static ParsedItem? parseClause(String raw) {
    String c = ' ${raw.toLowerCase().trim()} ';
    if (c.trim().isEmpty) return null;

    // 1) explicit volume wins
    double? volOz;
    RegExpMatch? m;

    m = RegExp(r'(\d+(?:\.\d+)?)\s*(ml|milliliters?|millilitres?)', caseSensitive: false).firstMatch(c);
    if (m != null) {
      volOz = double.parse(m.group(1)!) * ML_TO_OZ;
    } else {
      m = RegExp(r'(\d+(?:\.\d+)?)\s*(l|liters?|litres?)\b', caseSensitive: false).firstMatch(c);
      if (m != null) {
        volOz = double.parse(m.group(1)!) * L_TO_OZ;
      } else {
        m = RegExp(r'(\d+(?:\.\d+)?)\s*(fl\s*oz|ounces?|oz)\b', caseSensitive: false).firstMatch(c);
        if (m != null) {
          volOz = double.parse(m.group(1)!);
        } else {
          m = RegExp(r'(\d+(?:\.\d+)?)\s*cups?\b', caseSensitive: false).firstMatch(c);
          if (m != null) {
            volOz = double.parse(m.group(1)!) * 8.0;
          }
        }
      }
    }

    // 2) quantity multiplier (leading number / word)
    double qty = 1.0;
    bool qtyExplicit = false;

    m = RegExp(r'\b(\d+(?:\.\d+)?)\b').firstMatch(c);
    if (m != null && volOz == null) {
      qty = double.parse(m.group(1)!);
      qtyExplicit = true;
    } else {
      for (final entry in numWords.entries) {
        if (RegExp('\\b${entry.key}\\b').hasMatch(c)) {
          qty = entry.value;
          qtyExplicit = entry.key != 'a' && entry.key != 'an';
          break;
        }
      }
    }

    // 3) container base
    double? baseOz;
    for (final ct in containers) {
      if (ct.re.hasMatch(c)) {
        baseOz = ct.oz;
        break;
      }
    }

    // 4) drink type
    DrinkRule? drinkRule;
    for (final d in drinks) {
      if (d.re.hasMatch(c)) {
        drinkRule = d;
        break;
      }
    }

    // must reference *some* drink or container or explicit volume to count
    if (drinkRule == null && baseOz == null && volOz == null) return null;

    final name = drinkRule?.name ?? 'Water';
    final icon = drinkRule?.icon ?? 'water_drop';
    final factor = drinkRule?.factor ?? 1.0;

    double oz;
    if (volOz != null) {
      oz = volOz * (qtyExplicit ? qty : 1.0);
    } else if (baseOz != null) {
      oz = baseOz * qty;
    } else {
      oz = 12.0 * qty; // drink named without container -> assume a serving (12 oz)
    }

    final hydration = oz * factor;
    return ParsedItem(
      name: name,
      icon: icon,
      oz: oz.roundToDouble(),
      hydration: hydration.roundToDouble(),
      factor: factor,
      qty: qtyExplicit
          ? qty
          : (baseOz != null || volOz != null ? qty : 1.0),
    );
  }

  static HydrationParseResult parse(String text) {
    if (text.trim().isEmpty) {
      return HydrationParseResult(items: [], oz: 0.0, hydration: 0.0, confidence: 0.0);
    }

    // split clauses by comma, semicolon, "and", "&", "+", "with", "plus"
    final clauses = text.split(RegExp(r'\s*(?:,|;|\band\b|&|\+|\bwith\b|\bplus\b)\s*', caseSensitive: false));
    final items = <ParsedItem>[];

    for (final cl in clauses) {
      final it = parseClause(cl);
      if (it != null && it.oz > 0.0) {
        items.add(it);
      }
    }

    // fallback: nothing matched -> assume a glass of water, low confidence
    double confidence = items.isNotEmpty ? 0.92 : 0.4;
    if (items.isEmpty && text.trim().isNotEmpty) {
      items.add(ParsedItem(
        name: 'Water',
        icon: 'water_drop',
        oz: 8.0,
        hydration: 8.0,
        factor: 1.0,
        qty: 1.0,
      ));
    }

    double totalOz = items.fold(0.0, (sum, item) => sum + item.oz);
    double totalHydration = items.fold(0.0, (sum, item) => sum + item.hydration);

    return HydrationParseResult(
      items: items,
      oz: totalOz.roundToDouble(),
      hydration: totalHydration.roundToDouble(),
      confidence: confidence,
    );
  }
}
