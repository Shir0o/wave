class DrinkEntry {
  final String id;
  final String name;
  final String icon;
  final double oz;
  final double hydration;
  final DateTime time;
  final String source;

  DrinkEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.oz,
    required this.hydration,
    required this.time,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'oz': oz,
    'hydration': hydration,
    'time': time.toIso8601String(),
    'source': source,
  };

  factory DrinkEntry.fromJson(Map<String, dynamic> json) => DrinkEntry(
    id:
        json['id'] as String? ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    name: json['name'] as String,
    icon: json['icon'] as String,
    oz: (json['oz'] as num).toDouble(),
    hydration: (json['hydration'] as num).toDouble(),
    time: DateTime.parse(json['time'] as String),
    source: json['source'] as String,
  );

  DrinkEntry copyWith({
    String? id,
    String? name,
    String? icon,
    double? oz,
    double? hydration,
    DateTime? time,
    String? source,
  }) {
    return DrinkEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      oz: oz ?? this.oz,
      hydration: hydration ?? this.hydration,
      time: time ?? this.time,
      source: source ?? this.source,
    );
  }
}
