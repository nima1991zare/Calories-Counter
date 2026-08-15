import 'dart:convert';

/// A named serving size for a food, e.g. "1 cup (240 g)".
class Serving {
  final String name;
  final double grams;

  const Serving(this.name, this.grams);

  Map<String, dynamic> toJson() => {'name': name, 'grams': grams};

  factory Serving.fromJson(Map<String, dynamic> json) =>
      Serving(json['name'] as String, (json['grams'] as num).toDouble());
}

enum FoodSource { bundled, custom, recipe, openFoodFacts }

class Food {
  final int? id;
  final String name;
  final String brand;
  final FoodSource source;
  final String? barcode;

  /// Nutrient values **per 100 g**, keyed by [Nutrients] keys.
  final Map<String, double> per100g;

  /// Available serving sizes. "100 g" and "1 g" are always available implicitly.
  final List<Serving> servings;

  final bool favorite;

  /// For recipes: number of servings the total recipe yields.
  final double recipeServings;

  const Food({
    this.id,
    required this.name,
    this.brand = '',
    this.source = FoodSource.custom,
    this.barcode,
    required this.per100g,
    this.servings = const [],
    this.favorite = false,
    this.recipeServings = 1,
  });

  double nutrient(String key) => per100g[key] ?? 0;

  /// Nutrient amount for a given number of grams of this food.
  double nutrientFor(String key, double grams) => nutrient(key) * grams / 100.0;

  double get kcalPer100 => nutrient('kcal');

  Food copyWith({
    int? id,
    String? name,
    String? brand,
    FoodSource? source,
    String? barcode,
    Map<String, double>? per100g,
    List<Serving>? servings,
    bool? favorite,
    double? recipeServings,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      source: source ?? this.source,
      barcode: barcode ?? this.barcode,
      per100g: per100g ?? this.per100g,
      servings: servings ?? this.servings,
      favorite: favorite ?? this.favorite,
      recipeServings: recipeServings ?? this.recipeServings,
    );
  }

  Map<String, dynamic> toDbMap() => {
        'name': name,
        'brand': brand,
        'source': source.name,
        'barcode': barcode,
        'nutrients': jsonEncode(per100g),
        'servings': jsonEncode(servings.map((s) => s.toJson()).toList()),
        'favorite': favorite ? 1 : 0,
        'recipe_servings': recipeServings,
      };

  factory Food.fromDbMap(Map<String, dynamic> map) {
    final nutrientsRaw = jsonDecode(map['nutrients'] as String? ?? '{}');
    final servingsRaw = jsonDecode(map['servings'] as String? ?? '[]');
    return Food(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      source: FoodSource.values.firstWhere(
        (s) => s.name == map['source'],
        orElse: () => FoodSource.custom,
      ),
      barcode: map['barcode'] as String?,
      per100g: (nutrientsRaw as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      servings: (servingsRaw as List)
          .map((s) => Serving.fromJson(s as Map<String, dynamic>))
          .toList(),
      favorite: (map['favorite'] as int? ?? 0) == 1,
      recipeServings: (map['recipe_servings'] as num? ?? 1).toDouble(),
    );
  }

  /// Default serving suggestion (first named serving, otherwise 100 g).
  Serving get defaultServing =>
      servings.isNotEmpty ? servings.first : const Serving('100 g', 100);

  /// All selectable servings including gram-based fallbacks.
  List<Serving> get allServings => [
        ...servings,
        const Serving('100 g', 100),
        const Serving('1 g', 1),
      ];
}
