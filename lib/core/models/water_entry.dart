import 'package:flutter/material.dart';

enum DrinkType {
  water,
  tea,
  juice,
  coffee,
  milk,
  sports,
}

class WaterEntry {
  final String id;
  final DateTime timestamp;
  final int amountMl;
  final DrinkType drinkType;

  WaterEntry({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    required this.drinkType,
  });

  // Hydration factor: coffee = 50%, milk = 90%, etc.
  double get hydrationFactor {
    switch (drinkType) {
      case DrinkType.water:
        return 1.0;
      case DrinkType.tea:
        return 0.95;
      case DrinkType.juice:
        return 0.85;
      case DrinkType.coffee:
        return 0.5;
      case DrinkType.milk:
        return 0.9;
      case DrinkType.sports:
        return 0.95;
    }
  }

  int get effectiveMl => (amountMl * hydrationFactor).round();

  Color get drinkColor {
    switch (drinkType) {
      case DrinkType.water:
        return const Color(0xFF5DCCFC);
      case DrinkType.tea:
        return const Color(0xFF96CEB4);
      case DrinkType.juice:
        return const Color(0xFFFFB347);
      case DrinkType.coffee:
        return const Color(0xFF8B6914);
      case DrinkType.milk:
        return const Color(0xFFD4D4D4);
      case DrinkType.sports:
        return const Color(0xFF7BC8F6);
    }
  }

  String get drinkEmoji {
    switch (drinkType) {
      case DrinkType.water:
        return '💧';
      case DrinkType.tea:
        return '🍵';
      case DrinkType.juice:
        return '🍊';
      case DrinkType.coffee:
        return '☕';
      case DrinkType.milk:
        return '🥛';
      case DrinkType.sports:
        return '🏃';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
        'drinkType': drinkType.name,
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        amountMl: json['amountMl'] as int,
        drinkType: DrinkType.values.firstWhere(
          (e) => e.name == json['drinkType'],
          orElse: () => DrinkType.water,
        ),
      );
}
