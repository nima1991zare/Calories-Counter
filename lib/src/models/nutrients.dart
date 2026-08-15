/// Central registry of all nutrients tracked by the app (Cronometer style).
///
/// All food nutrient values are stored **per 100 g** of food.
library;

enum NutrientGroup { general, carbohydrates, lipids, protein, vitamins, minerals }

class NutrientDef {
  final String key;
  final String name;
  final String unit;
  final NutrientGroup group;

  const NutrientDef(this.key, this.name, this.unit, this.group);
}

class Nutrients {
  // ---- General ----
  static const kcal = 'kcal';
  static const water = 'water';
  static const caffeine = 'caffeine';
  static const alcohol = 'alcohol';

  // ---- Carbohydrates ----
  static const carbs = 'carbs';
  static const fiber = 'fiber';
  static const sugar = 'sugar';

  // ---- Lipids ----
  static const fat = 'fat';
  static const satFat = 'sat_fat';
  static const transFat = 'trans_fat';
  static const monoFat = 'mono_fat';
  static const polyFat = 'poly_fat';
  static const cholesterol = 'cholesterol';

  // ---- Protein ----
  static const protein = 'protein';

  // ---- Vitamins ----
  static const vitA = 'vit_a';
  static const vitC = 'vit_c';
  static const vitD = 'vit_d';
  static const vitE = 'vit_e';
  static const vitK = 'vit_k';
  static const b1 = 'b1';
  static const b2 = 'b2';
  static const b3 = 'b3';
  static const b5 = 'b5';
  static const b6 = 'b6';
  static const b12 = 'b12';
  static const folate = 'folate';
  static const choline = 'choline';

  // ---- Minerals ----
  static const sodium = 'sodium';
  static const potassium = 'potassium';
  static const calcium = 'calcium';
  static const iron = 'iron';
  static const magnesium = 'magnesium';
  static const phosphorus = 'phosphorus';
  static const zinc = 'zinc';
  static const copper = 'copper';
  static const manganese = 'manganese';
  static const selenium = 'selenium';

  static const List<NutrientDef> all = [
    // General
    NutrientDef(kcal, 'Energy', 'kcal', NutrientGroup.general),
    NutrientDef(water, 'Water', 'g', NutrientGroup.general),
    NutrientDef(caffeine, 'Caffeine', 'mg', NutrientGroup.general),
    NutrientDef(alcohol, 'Alcohol', 'g', NutrientGroup.general),
    // Protein
    NutrientDef(protein, 'Protein', 'g', NutrientGroup.protein),
    // Carbs
    NutrientDef(carbs, 'Carbohydrates', 'g', NutrientGroup.carbohydrates),
    NutrientDef(fiber, 'Fiber', 'g', NutrientGroup.carbohydrates),
    NutrientDef(sugar, 'Sugars', 'g', NutrientGroup.carbohydrates),
    // Lipids
    NutrientDef(fat, 'Fat', 'g', NutrientGroup.lipids),
    NutrientDef(satFat, 'Saturated Fat', 'g', NutrientGroup.lipids),
    NutrientDef(transFat, 'Trans Fat', 'g', NutrientGroup.lipids),
    NutrientDef(monoFat, 'Monounsaturated Fat', 'g', NutrientGroup.lipids),
    NutrientDef(polyFat, 'Polyunsaturated Fat', 'g', NutrientGroup.lipids),
    NutrientDef(cholesterol, 'Cholesterol', 'mg', NutrientGroup.lipids),
    // Vitamins
    NutrientDef(vitA, 'Vitamin A', 'µg', NutrientGroup.vitamins),
    NutrientDef(vitC, 'Vitamin C', 'mg', NutrientGroup.vitamins),
    NutrientDef(vitD, 'Vitamin D', 'µg', NutrientGroup.vitamins),
    NutrientDef(vitE, 'Vitamin E', 'mg', NutrientGroup.vitamins),
    NutrientDef(vitK, 'Vitamin K', 'µg', NutrientGroup.vitamins),
    NutrientDef(b1, 'B1 (Thiamine)', 'mg', NutrientGroup.vitamins),
    NutrientDef(b2, 'B2 (Riboflavin)', 'mg', NutrientGroup.vitamins),
    NutrientDef(b3, 'B3 (Niacin)', 'mg', NutrientGroup.vitamins),
    NutrientDef(b5, 'B5 (Pantothenic Acid)', 'mg', NutrientGroup.vitamins),
    NutrientDef(b6, 'B6 (Pyridoxine)', 'mg', NutrientGroup.vitamins),
    NutrientDef(b12, 'B12 (Cobalamin)', 'µg', NutrientGroup.vitamins),
    NutrientDef(folate, 'Folate', 'µg', NutrientGroup.vitamins),
    NutrientDef(choline, 'Choline', 'mg', NutrientGroup.vitamins),
    // Minerals
    NutrientDef(sodium, 'Sodium', 'mg', NutrientGroup.minerals),
    NutrientDef(potassium, 'Potassium', 'mg', NutrientGroup.minerals),
    NutrientDef(calcium, 'Calcium', 'mg', NutrientGroup.minerals),
    NutrientDef(iron, 'Iron', 'mg', NutrientGroup.minerals),
    NutrientDef(magnesium, 'Magnesium', 'mg', NutrientGroup.minerals),
    NutrientDef(phosphorus, 'Phosphorus', 'mg', NutrientGroup.minerals),
    NutrientDef(zinc, 'Zinc', 'mg', NutrientGroup.minerals),
    NutrientDef(copper, 'Copper', 'mg', NutrientGroup.minerals),
    NutrientDef(manganese, 'Manganese', 'mg', NutrientGroup.minerals),
    NutrientDef(selenium, 'Selenium', 'µg', NutrientGroup.minerals),
  ];

  static final Map<String, NutrientDef> byKey = {
    for (final n in all) n.key: n,
  };

  static String groupName(NutrientGroup g) {
    switch (g) {
      case NutrientGroup.general:
        return 'General';
      case NutrientGroup.carbohydrates:
        return 'Carbohydrates';
      case NutrientGroup.lipids:
        return 'Lipids';
      case NutrientGroup.protein:
        return 'Protein';
      case NutrientGroup.vitamins:
        return 'Vitamins';
      case NutrientGroup.minerals:
        return 'Minerals';
    }
  }

  /// Daily targets (RDA / AI) for micronutrients for adults.
  /// Values differ by sex. Energy & macro targets come from the user profile.
  static Map<String, double> rdaTargets({required bool male}) {
    return {
      fiber: male ? 38 : 25,
      satFat: 22, // soft limit, ~10% of 2000 kcal
      cholesterol: 300,
      sugar: 50,
      vitA: male ? 900 : 700,
      vitC: male ? 90 : 75,
      vitD: 15,
      vitE: 15,
      vitK: male ? 120 : 90,
      b1: male ? 1.2 : 1.1,
      b2: male ? 1.3 : 1.1,
      b3: male ? 16 : 14,
      b5: 5,
      b6: 1.3,
      b12: 2.4,
      folate: 400,
      choline: male ? 550 : 425,
      sodium: 2300,
      potassium: male ? 3400 : 2600,
      calcium: 1000,
      iron: male ? 8 : 18,
      magnesium: male ? 420 : 320,
      phosphorus: 700,
      zinc: male ? 11 : 8,
      copper: 0.9,
      manganese: male ? 2.3 : 1.8,
      selenium: 55,
      water: 2000, // g of water from all sources (tracked separately too)
    };
  }

  /// Nutrients whose target is a limit (stay under) rather than a goal.
  static const Set<String> limitNutrients = {
    satFat,
    transFat,
    cholesterol,
    sodium,
    sugar,
  };
}
