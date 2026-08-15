import 'food.dart';

enum Meal { breakfast, lunch, dinner, snacks }

extension MealX on Meal {
  String get label {
    switch (this) {
      case Meal.breakfast:
        return 'Breakfast';
      case Meal.lunch:
        return 'Lunch';
      case Meal.dinner:
        return 'Dinner';
      case Meal.snacks:
        return 'Snacks';
    }
  }
}

/// A food logged in the diary.
class DiaryEntry {
  final int? id;
  final String date; // yyyy-MM-dd
  final Meal meal;
  final int foodId;
  final double grams;
  final String servingName;
  final double servingQty;

  const DiaryEntry({
    this.id,
    required this.date,
    required this.meal,
    required this.foodId,
    required this.grams,
    this.servingName = 'g',
    this.servingQty = 0,
  });

  DiaryEntry copyWith({
    int? id,
    String? date,
    Meal? meal,
    int? foodId,
    double? grams,
    String? servingName,
    double? servingQty,
  }) =>
      DiaryEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        meal: meal ?? this.meal,
        foodId: foodId ?? this.foodId,
        grams: grams ?? this.grams,
        servingName: servingName ?? this.servingName,
        servingQty: servingQty ?? this.servingQty,
      );

  Map<String, dynamic> toDbMap() => {
        'date': date,
        'meal': meal.index,
        'food_id': foodId,
        'grams': grams,
        'serving_name': servingName,
        'serving_qty': servingQty,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

  factory DiaryEntry.fromDbMap(Map<String, dynamic> map) => DiaryEntry(
        id: map['id'] as int?,
        date: map['date'] as String,
        meal: Meal.values[(map['meal'] as int?) ?? 0],
        foodId: map['food_id'] as int,
        grams: (map['grams'] as num).toDouble(),
        servingName: map['serving_name'] as String? ?? 'g',
        servingQty: (map['serving_qty'] as num? ?? 0).toDouble(),
      );
}

/// A diary entry joined with its food.
class LoggedFood {
  final DiaryEntry entry;
  final Food food;

  const LoggedFood(this.entry, this.food);

  double nutrient(String key) => food.nutrientFor(key, entry.grams);

  String get amountLabel {
    if (entry.servingQty > 0 && entry.servingName != 'g') {
      final qty = entry.servingQty;
      final qtyStr = qty == qty.roundToDouble()
          ? qty.toInt().toString()
          : qty.toStringAsFixed(2);
      return '$qtyStr × ${entry.servingName}';
    }
    return '${entry.grams.round()} g';
  }
}

class ExerciseEntry {
  final int? id;
  final String date;
  final String name;
  final double minutes;
  final double kcal;

  const ExerciseEntry({
    this.id,
    required this.date,
    required this.name,
    required this.minutes,
    required this.kcal,
  });

  Map<String, dynamic> toDbMap() => {
        'date': date,
        'name': name,
        'minutes': minutes,
        'kcal': kcal,
      };

  factory ExerciseEntry.fromDbMap(Map<String, dynamic> map) => ExerciseEntry(
        id: map['id'] as int?,
        date: map['date'] as String,
        name: map['name'] as String,
        minutes: (map['minutes'] as num).toDouble(),
        kcal: (map['kcal'] as num).toDouble(),
      );
}

/// Types of biometric measurements the user can track.
class BiometricType {
  final String key;
  final String name;
  final String unit;

  const BiometricType(this.key, this.name, this.unit);

  static const List<BiometricType> all = [
    BiometricType('weight', 'Weight', 'kg'),
    BiometricType('body_fat', 'Body Fat', '%'),
    BiometricType('waist', 'Waist', 'cm'),
    BiometricType('hips', 'Hips', 'cm'),
    BiometricType('chest', 'Chest', 'cm'),
    BiometricType('arm', 'Arm', 'cm'),
    BiometricType('thigh', 'Thigh', 'cm'),
    BiometricType('heart_rate', 'Resting Heart Rate', 'bpm'),
    BiometricType('systolic', 'Blood Pressure (Systolic)', 'mmHg'),
    BiometricType('diastolic', 'Blood Pressure (Diastolic)', 'mmHg'),
    BiometricType('blood_glucose', 'Blood Glucose', 'mg/dL'),
    BiometricType('sleep', 'Sleep', 'hours'),
  ];

  static BiometricType byKey(String key) =>
      all.firstWhere((t) => t.key == key, orElse: () => all.first);
}

class BiometricEntry {
  final int? id;
  final String date;
  final String type;
  final double value;

  const BiometricEntry({
    this.id,
    required this.date,
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toDbMap() => {
        'date': date,
        'type': type,
        'value': value,
      };

  factory BiometricEntry.fromDbMap(Map<String, dynamic> map) => BiometricEntry(
        id: map['id'] as int?,
        date: map['date'] as String,
        type: map['type'] as String,
        value: (map['value'] as num).toDouble(),
      );
}

class RecipeItem {
  final int? id;
  final int recipeId;
  final int foodId;
  final double grams;

  const RecipeItem({
    this.id,
    required this.recipeId,
    required this.foodId,
    required this.grams,
  });

  Map<String, dynamic> toDbMap() => {
        'recipe_id': recipeId,
        'food_id': foodId,
        'grams': grams,
      };

  factory RecipeItem.fromDbMap(Map<String, dynamic> map) => RecipeItem(
        id: map['id'] as int?,
        recipeId: map['recipe_id'] as int,
        foodId: map['food_id'] as int,
        grams: (map['grams'] as num).toDouble(),
      );
}
