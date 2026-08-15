/// Bundled food database. Nutrient values are per 100 g (approximate USDA data).
library;

Map<String, Object> _f(
  String name,
  Map<String, double> n, {
  List<List<Object>> servings = const [],
}) =>
    {'name': name, 'nutrients': n, 'servings': servings};

/// Each item: {name, nutrients: {key: per100g}, servings: [[label, grams]]}.
final List<Map<String, Object>> seedFoods = [
  // ---------------- Fruits ----------------
  _f('Apple', {
    'kcal': 52, 'protein': 0.3, 'carbs': 13.8, 'fiber': 2.4, 'sugar': 10.4,
    'fat': 0.2, 'sodium': 1, 'potassium': 107, 'calcium': 6, 'iron': 0.1,
    'magnesium': 5, 'vit_c': 4.6, 'vit_k': 2.2, 'folate': 3, 'water': 85.6,
  }, servings: [['1 medium (182 g)', 182], ['1 small (149 g)', 149]]),
  _f('Banana', {
    'kcal': 89, 'protein': 1.1, 'carbs': 22.8, 'fiber': 2.6, 'sugar': 12.2,
    'fat': 0.3, 'sodium': 1, 'potassium': 358, 'calcium': 5, 'iron': 0.3,
    'magnesium': 27, 'vit_c': 8.7, 'b6': 0.37, 'folate': 20, 'water': 74.9,
  }, servings: [['1 medium (118 g)', 118], ['1 large (136 g)', 136]]),
  _f('Orange', {
    'kcal': 47, 'protein': 0.9, 'carbs': 11.8, 'fiber': 2.4, 'sugar': 9.4,
    'fat': 0.1, 'sodium': 0, 'potassium': 181, 'calcium': 40, 'iron': 0.1,
    'vit_c': 53.2, 'folate': 30, 'b1': 0.09, 'water': 86.8,
  }, servings: [['1 medium (131 g)', 131]]),
  _f('Strawberries', {
    'kcal': 32, 'protein': 0.7, 'carbs': 7.7, 'fiber': 2.0, 'sugar': 4.9,
    'fat': 0.3, 'sodium': 1, 'potassium': 153, 'calcium': 16, 'iron': 0.4,
    'magnesium': 13, 'vit_c': 58.8, 'folate': 24, 'manganese': 0.39, 'water': 90.9,
  }, servings: [['1 cup, halves (152 g)', 152]]),
  _f('Blueberries', {
    'kcal': 57, 'protein': 0.7, 'carbs': 14.5, 'fiber': 2.4, 'sugar': 10.0,
    'fat': 0.3, 'sodium': 1, 'potassium': 77, 'calcium': 6, 'iron': 0.3,
    'vit_c': 9.7, 'vit_k': 19.3, 'manganese': 0.34, 'water': 84.2,
  }, servings: [['1 cup (148 g)', 148]]),
  _f('Grapes', {
    'kcal': 69, 'protein': 0.7, 'carbs': 18.1, 'fiber': 0.9, 'sugar': 15.5,
    'fat': 0.2, 'sodium': 2, 'potassium': 191, 'calcium': 10, 'iron': 0.4,
    'vit_c': 3.2, 'vit_k': 14.6, 'water': 80.5,
  }, servings: [['1 cup (151 g)', 151]]),
  _f('Watermelon', {
    'kcal': 30, 'protein': 0.6, 'carbs': 7.6, 'fiber': 0.4, 'sugar': 6.2,
    'fat': 0.2, 'sodium': 1, 'potassium': 112, 'vit_c': 8.1, 'vit_a': 28,
    'water': 91.5,
  }, servings: [['1 cup, diced (152 g)', 152], ['1 wedge (286 g)', 286]]),
  _f('Avocado', {
    'kcal': 160, 'protein': 2.0, 'carbs': 8.5, 'fiber': 6.7, 'sugar': 0.7,
    'fat': 14.7, 'sat_fat': 2.1, 'mono_fat': 9.8, 'poly_fat': 1.8,
    'sodium': 7, 'potassium': 485, 'calcium': 12, 'iron': 0.6, 'magnesium': 29,
    'vit_c': 10.0, 'vit_e': 2.1, 'vit_k': 21.0, 'folate': 81, 'b5': 1.39,
    'water': 73.2,
  }, servings: [['1/2 fruit (100 g)', 100], ['1 whole (201 g)', 201]]),
  _f('Mango', {
    'kcal': 60, 'protein': 0.8, 'carbs': 15.0, 'fiber': 1.6, 'sugar': 13.7,
    'fat': 0.4, 'sodium': 1, 'potassium': 168, 'vit_a': 54, 'vit_c': 36.4,
    'folate': 43, 'water': 83.5,
  }, servings: [['1 cup, pieces (165 g)', 165]]),
  _f('Pineapple', {
    'kcal': 50, 'protein': 0.5, 'carbs': 13.1, 'fiber': 1.4, 'sugar': 9.9,
    'fat': 0.1, 'sodium': 1, 'potassium': 109, 'vit_c': 47.8, 'manganese': 0.93,
    'water': 86.0,
  }, servings: [['1 cup, chunks (165 g)', 165]]),
  _f('Dates (Medjool)', {
    'kcal': 277, 'protein': 1.8, 'carbs': 75.0, 'fiber': 6.7, 'sugar': 66.5,
    'fat': 0.2, 'sodium': 1, 'potassium': 696, 'calcium': 64, 'iron': 0.9,
    'magnesium': 54, 'b6': 0.25, 'water': 21.3,
  }, servings: [['1 date (24 g)', 24]]),
  _f('Raisins', {
    'kcal': 299, 'protein': 3.1, 'carbs': 79.2, 'fiber': 3.7, 'sugar': 59.2,
    'fat': 0.5, 'sodium': 11, 'potassium': 749, 'calcium': 50, 'iron': 1.9,
    'water': 15.4,
  }, servings: [['1 small box (43 g)', 43], ['1/4 cup (41 g)', 41]]),

  // ---------------- Vegetables ----------------
  _f('Broccoli, raw', {
    'kcal': 34, 'protein': 2.8, 'carbs': 6.6, 'fiber': 2.6, 'sugar': 1.7,
    'fat': 0.4, 'sodium': 33, 'potassium': 316, 'calcium': 47, 'iron': 0.7,
    'magnesium': 21, 'phosphorus': 66, 'vit_a': 31, 'vit_c': 89.2,
    'vit_k': 101.6, 'folate': 63, 'water': 89.3,
  }, servings: [['1 cup, chopped (91 g)', 91]]),
  _f('Spinach, raw', {
    'kcal': 23, 'protein': 2.9, 'carbs': 3.6, 'fiber': 2.2, 'sugar': 0.4,
    'fat': 0.4, 'sodium': 79, 'potassium': 558, 'calcium': 99, 'iron': 2.7,
    'magnesium': 79, 'vit_a': 469, 'vit_c': 28.1, 'vit_k': 482.9,
    'folate': 194, 'vit_e': 2.0, 'water': 91.4,
  }, servings: [['1 cup (30 g)', 30], ['1 bunch (340 g)', 340]]),
  _f('Carrot, raw', {
    'kcal': 41, 'protein': 0.9, 'carbs': 9.6, 'fiber': 2.8, 'sugar': 4.7,
    'fat': 0.2, 'sodium': 69, 'potassium': 320, 'calcium': 33, 'iron': 0.3,
    'vit_a': 835, 'vit_c': 5.9, 'vit_k': 13.2, 'b6': 0.14, 'water': 88.3,
  }, servings: [['1 medium (61 g)', 61], ['1 cup, chopped (128 g)', 128]]),
  _f('Tomato, raw', {
    'kcal': 18, 'protein': 0.9, 'carbs': 3.9, 'fiber': 1.2, 'sugar': 2.6,
    'fat': 0.2, 'sodium': 5, 'potassium': 237, 'calcium': 10, 'iron': 0.3,
    'vit_a': 42, 'vit_c': 13.7, 'vit_k': 7.9, 'folate': 15, 'water': 94.5,
  }, servings: [['1 medium (123 g)', 123]]),
  _f('Cucumber, with peel', {
    'kcal': 15, 'protein': 0.7, 'carbs': 3.6, 'fiber': 0.5, 'sugar': 1.7,
    'fat': 0.1, 'sodium': 2, 'potassium': 147, 'calcium': 16, 'vit_c': 2.8,
    'vit_k': 16.4, 'water': 95.2,
  }, servings: [['1/2 cup slices (52 g)', 52], ['1 cucumber (301 g)', 301]]),
  _f('Bell Pepper, red', {
    'kcal': 31, 'protein': 1.0, 'carbs': 6.0, 'fiber': 2.1, 'sugar': 4.2,
    'fat': 0.3, 'sodium': 4, 'potassium': 211, 'vit_a': 157, 'vit_c': 127.7,
    'vit_e': 1.6, 'b6': 0.29, 'folate': 46, 'water': 92.2,
  }, servings: [['1 medium (119 g)', 119]]),
  _f('Onion, raw', {
    'kcal': 40, 'protein': 1.1, 'carbs': 9.3, 'fiber': 1.7, 'sugar': 4.2,
    'fat': 0.1, 'sodium': 4, 'potassium': 146, 'calcium': 23, 'vit_c': 7.4,
    'folate': 19, 'water': 89.1,
  }, servings: [['1 medium (110 g)', 110]]),
  _f('Potato, baked, with skin', {
    'kcal': 93, 'protein': 2.5, 'carbs': 21.2, 'fiber': 2.2, 'sugar': 1.2,
    'fat': 0.1, 'sodium': 10, 'potassium': 535, 'calcium': 15, 'iron': 1.1,
    'magnesium': 28, 'phosphorus': 70, 'vit_c': 9.6, 'b6': 0.31, 'water': 74.9,
  }, servings: [['1 medium (173 g)', 173]]),
  _f('Sweet Potato, baked', {
    'kcal': 90, 'protein': 2.0, 'carbs': 20.7, 'fiber': 3.3, 'sugar': 6.5,
    'fat': 0.2, 'sodium': 36, 'potassium': 475, 'calcium': 38, 'iron': 0.7,
    'magnesium': 27, 'vit_a': 961, 'vit_c': 19.6, 'b6': 0.29, 'water': 75.8,
  }, servings: [['1 medium (114 g)', 114]]),
  _f('Lettuce, romaine', {
    'kcal': 17, 'protein': 1.2, 'carbs': 3.3, 'fiber': 2.1, 'sugar': 1.2,
    'fat': 0.3, 'sodium': 8, 'potassium': 247, 'calcium': 33, 'iron': 1.0,
    'vit_a': 436, 'vit_c': 4.0, 'vit_k': 102.5, 'folate': 136, 'water': 94.6,
  }, servings: [['2 cups shredded (94 g)', 94]]),
  _f('Cauliflower, raw', {
    'kcal': 25, 'protein': 1.9, 'carbs': 5.0, 'fiber': 2.0, 'sugar': 1.9,
    'fat': 0.3, 'sodium': 30, 'potassium': 299, 'calcium': 22, 'vit_c': 48.2,
    'vit_k': 15.5, 'folate': 57, 'water': 92.1,
  }, servings: [['1 cup, chopped (107 g)', 107]]),
  _f('Mushrooms, white, raw', {
    'kcal': 22, 'protein': 3.1, 'carbs': 3.3, 'fiber': 1.0, 'sugar': 2.0,
    'fat': 0.3, 'sodium': 5, 'potassium': 318, 'phosphorus': 86, 'selenium': 9.3,
    'b2': 0.40, 'b3': 3.6, 'b5': 1.5, 'copper': 0.32, 'water': 92.5,
  }, servings: [['1 cup, sliced (70 g)', 70]]),
  _f('Corn, sweet, cooked', {
    'kcal': 96, 'protein': 3.4, 'carbs': 21.0, 'fiber': 2.4, 'sugar': 4.5,
    'fat': 1.5, 'sodium': 1, 'potassium': 218, 'magnesium': 26,
    'phosphorus': 77, 'folate': 23, 'water': 73.4,
  }, servings: [['1 ear (103 g)', 103], ['1 cup (149 g)', 149]]),
  _f('Green Beans, cooked', {
    'kcal': 35, 'protein': 1.9, 'carbs': 7.9, 'fiber': 3.2, 'sugar': 3.6,
    'fat': 0.3, 'sodium': 1, 'potassium': 146, 'calcium': 44, 'iron': 0.7,
    'vit_a': 35, 'vit_c': 9.7, 'vit_k': 47.9, 'folate': 33, 'water': 89.2,
  }, servings: [['1 cup (125 g)', 125]]),

  // ---------------- Grains & Breads ----------------
  _f('White Rice, cooked', {
    'kcal': 130, 'protein': 2.7, 'carbs': 28.2, 'fiber': 0.4, 'sugar': 0.1,
    'fat': 0.3, 'sodium': 1, 'potassium': 35, 'calcium': 10, 'iron': 1.2,
    'magnesium': 12, 'folate': 58, 'water': 68.4,
  }, servings: [['1 cup (158 g)', 158]]),
  _f('Brown Rice, cooked', {
    'kcal': 123, 'protein': 2.7, 'carbs': 25.6, 'fiber': 1.6, 'sugar': 0.2,
    'fat': 1.0, 'sodium': 4, 'potassium': 86, 'magnesium': 39,
    'phosphorus': 103, 'manganese': 0.97, 'selenium': 5.8, 'water': 70.3,
  }, servings: [['1 cup (195 g)', 195]]),
  _f('Oats, rolled, dry', {
    'kcal': 389, 'protein': 16.9, 'carbs': 66.3, 'fiber': 10.6, 'sugar': 0.99,
    'fat': 6.9, 'sat_fat': 1.2, 'sodium': 2, 'potassium': 429, 'calcium': 54,
    'iron': 4.7, 'magnesium': 177, 'phosphorus': 523, 'zinc': 4.0,
    'manganese': 4.9, 'b1': 0.76, 'folate': 56, 'water': 8.2,
  }, servings: [['1/2 cup (40 g)', 40], ['1 cup (81 g)', 81]]),
  _f('Whole Wheat Bread', {
    'kcal': 247, 'protein': 13.0, 'carbs': 41.3, 'fiber': 6.8, 'sugar': 5.6,
    'fat': 3.4, 'sat_fat': 0.7, 'sodium': 450, 'potassium': 250,
    'calcium': 161, 'iron': 2.5, 'magnesium': 76, 'zinc': 1.8,
    'b1': 0.39, 'b3': 4.4, 'folate': 42, 'water': 38.6,
  }, servings: [['1 slice (32 g)', 32]]),
  _f('White Bread', {
    'kcal': 265, 'protein': 9.0, 'carbs': 49.0, 'fiber': 2.7, 'sugar': 5.7,
    'fat': 3.2, 'sat_fat': 0.7, 'sodium': 491, 'potassium': 115,
    'calcium': 144, 'iron': 3.6, 'b1': 0.53, 'b2': 0.23, 'b3': 4.8,
    'folate': 111, 'water': 36.4,
  }, servings: [['1 slice (29 g)', 29]]),
  _f('Pasta, cooked', {
    'kcal': 158, 'protein': 5.8, 'carbs': 30.9, 'fiber': 1.8, 'sugar': 0.6,
    'fat': 0.9, 'sodium': 1, 'potassium': 44, 'iron': 1.3, 'folate': 74,
    'selenium': 26.4, 'water': 62.1,
  }, servings: [['1 cup (140 g)', 140]]),
  _f('Quinoa, cooked', {
    'kcal': 120, 'protein': 4.4, 'carbs': 21.3, 'fiber': 2.8, 'sugar': 0.9,
    'fat': 1.9, 'sodium': 7, 'potassium': 172, 'magnesium': 64,
    'phosphorus': 152, 'iron': 1.5, 'zinc': 1.1, 'folate': 42,
    'manganese': 0.63, 'water': 71.6,
  }, servings: [['1 cup (185 g)', 185]]),
  _f('Tortilla, flour', {
    'kcal': 297, 'protein': 8.0, 'carbs': 49.4, 'fiber': 3.5, 'sugar': 3.5,
    'fat': 7.4, 'sat_fat': 1.8, 'sodium': 736, 'potassium': 125,
    'calcium': 129, 'iron': 3.6, 'water': 30.3,
  }, servings: [['1 tortilla, 8" (49 g)', 49]]),
  _f('Bagel, plain', {
    'kcal': 257, 'protein': 10.0, 'carbs': 50.5, 'fiber': 2.1, 'sugar': 6.2,
    'fat': 1.7, 'sodium': 439, 'potassium': 90, 'calcium': 79, 'iron': 3.5,
    'b1': 0.54, 'b3': 4.9, 'folate': 137, 'water': 36.0,
  }, servings: [['1 bagel (99 g)', 99]]),
  _f('Cereal, corn flakes', {
    'kcal': 357, 'protein': 7.5, 'carbs': 84.1, 'fiber': 3.3, 'sugar': 9.5,
    'fat': 0.4, 'sodium': 729, 'potassium': 168, 'iron': 28.9,
    'b1': 1.3, 'b2': 1.5, 'b3': 17.9, 'b6': 1.8, 'b12': 5.4,
    'folate': 667, 'water': 3.5,
  }, servings: [['1 cup (28 g)', 28]]),

  // ---------------- Protein: meat, fish, eggs ----------------
  _f('Chicken Breast, cooked', {
    'kcal': 165, 'protein': 31.0, 'carbs': 0, 'fat': 3.6, 'sat_fat': 1.0,
    'mono_fat': 1.2, 'poly_fat': 0.8, 'cholesterol': 85, 'sodium': 74,
    'potassium': 256, 'phosphorus': 228, 'magnesium': 29, 'zinc': 1.0,
    'selenium': 27.6, 'b3': 13.7, 'b6': 0.60, 'b5': 0.98, 'b12': 0.3,
    'water': 65.0,
  }, servings: [['1 breast (172 g)', 172], ['3 oz (85 g)', 85]]),
  _f('Chicken Thigh, cooked', {
    'kcal': 209, 'protein': 26.0, 'carbs': 0, 'fat': 10.9, 'sat_fat': 3.0,
    'mono_fat': 4.2, 'cholesterol': 133, 'sodium': 88, 'potassium': 230,
    'phosphorus': 180, 'zinc': 2.4, 'selenium': 23.8, 'b3': 6.4, 'b6': 0.36,
    'b12': 0.6, 'water': 61.9,
  }, servings: [['1 thigh (111 g)', 111], ['3 oz (85 g)', 85]]),
  _f('Ground Beef, 85% lean, cooked', {
    'kcal': 250, 'protein': 25.9, 'carbs': 0, 'fat': 15.4, 'sat_fat': 6.0,
    'mono_fat': 6.7, 'trans_fat': 1.0, 'cholesterol': 88, 'sodium': 79,
    'potassium': 318, 'phosphorus': 198, 'zinc': 6.2, 'iron': 2.6,
    'selenium': 21.8, 'b3': 5.4, 'b6': 0.36, 'b12': 2.6, 'water': 58.0,
  }, servings: [['3 oz (85 g)', 85], ['1/4 lb (113 g)', 113]]),
  _f('Beef Steak, sirloin, cooked', {
    'kcal': 206, 'protein': 30.9, 'carbs': 0, 'fat': 8.2, 'sat_fat': 3.1,
    'cholesterol': 89, 'sodium': 66, 'potassium': 350, 'phosphorus': 235,
    'zinc': 5.7, 'iron': 1.9, 'selenium': 32.5, 'b3': 7.6, 'b6': 0.64,
    'b12': 1.6, 'water': 60.0,
  }, servings: [['3 oz (85 g)', 85], ['6 oz (170 g)', 170]]),
  _f('Pork Chop, cooked', {
    'kcal': 231, 'protein': 25.7, 'carbs': 0, 'fat': 13.5, 'sat_fat': 4.8,
    'cholesterol': 78, 'sodium': 62, 'potassium': 361, 'phosphorus': 208,
    'zinc': 2.0, 'b1': 0.66, 'b3': 6.9, 'b6': 0.61, 'b12': 0.6,
    'selenium': 40.0, 'water': 59.5,
  }, servings: [['1 chop (145 g)', 145], ['3 oz (85 g)', 85]]),
  _f('Salmon, Atlantic, cooked', {
    'kcal': 206, 'protein': 22.1, 'carbs': 0, 'fat': 12.4, 'sat_fat': 2.5,
    'mono_fat': 3.8, 'poly_fat': 3.9, 'cholesterol': 63, 'sodium': 61,
    'potassium': 384, 'phosphorus': 252, 'magnesium': 30, 'selenium': 41.4,
    'vit_d': 13.1, 'b3': 8.6, 'b6': 0.6, 'b12': 2.8, 'water': 64.8,
  }, servings: [['1 fillet (178 g)', 178], ['3 oz (85 g)', 85]]),
  _f('Tuna, canned in water', {
    'kcal': 116, 'protein': 25.5, 'carbs': 0, 'fat': 0.8, 'sat_fat': 0.2,
    'cholesterol': 30, 'sodium': 247, 'potassium': 237, 'phosphorus': 217,
    'magnesium': 27, 'selenium': 80.4, 'vit_d': 1.7, 'b3': 13.3, 'b6': 0.35,
    'b12': 2.5, 'water': 74.5,
  }, servings: [['1 can, drained (165 g)', 165], ['3 oz (85 g)', 85]]),
  _f('Shrimp, cooked', {
    'kcal': 99, 'protein': 23.9, 'carbs': 0.2, 'fat': 0.3, 'cholesterol': 189,
    'sodium': 111, 'potassium': 259, 'phosphorus': 244, 'zinc': 1.6,
    'selenium': 42.8, 'b12': 1.4, 'choline': 135, 'water': 75.0,
  }, servings: [['3 oz (85 g)', 85]]),
  _f('Egg, whole, cooked', {
    'kcal': 155, 'protein': 12.6, 'carbs': 1.1, 'sugar': 1.1, 'fat': 10.6,
    'sat_fat': 3.3, 'mono_fat': 4.1, 'cholesterol': 373, 'sodium': 124,
    'potassium': 126, 'calcium': 50, 'iron': 1.2, 'phosphorus': 172,
    'zinc': 1.0, 'selenium': 30.8, 'vit_a': 149, 'vit_d': 2.2, 'b2': 0.5,
    'b12': 1.1, 'folate': 44, 'choline': 294, 'water': 74.6,
  }, servings: [['1 large (50 g)', 50], ['2 large (100 g)', 100]]),
  _f('Egg White', {
    'kcal': 52, 'protein': 10.9, 'carbs': 0.7, 'fat': 0.2, 'sodium': 166,
    'potassium': 163, 'selenium': 20.0, 'b2': 0.44, 'water': 87.6,
  }, servings: [['1 large egg white (33 g)', 33]]),
  _f('Turkey Breast, cooked', {
    'kcal': 147, 'protein': 30.1, 'carbs': 0, 'fat': 2.1, 'sat_fat': 0.6,
    'cholesterol': 80, 'sodium': 99, 'potassium': 249, 'phosphorus': 223,
    'zinc': 1.7, 'selenium': 30.2, 'b3': 11.8, 'b6': 0.81, 'b12': 0.4,
    'water': 66.3,
  }, servings: [['3 oz (85 g)', 85]]),
  _f('Bacon, cooked', {
    'kcal': 541, 'protein': 37.0, 'carbs': 1.4, 'fat': 41.8, 'sat_fat': 14.0,
    'mono_fat': 18.5, 'cholesterol': 110, 'sodium': 1717, 'potassium': 565,
    'phosphorus': 533, 'zinc': 3.5, 'b1': 0.4, 'b3': 11.1, 'b12': 1.2,
    'selenium': 62.0, 'water': 12.3,
  }, servings: [['1 slice (8 g)', 8], ['3 slices (24 g)', 24]]),

  // ---------------- Dairy ----------------
  _f('Milk, whole (3.25%)', {
    'kcal': 61, 'protein': 3.2, 'carbs': 4.8, 'sugar': 5.1, 'fat': 3.3,
    'sat_fat': 1.9, 'cholesterol': 10, 'sodium': 43, 'potassium': 132,
    'calcium': 113, 'phosphorus': 84, 'magnesium': 10, 'vit_a': 46,
    'vit_d': 1.3, 'b2': 0.17, 'b12': 0.45, 'water': 88.1,
  }, servings: [['1 cup (244 g)', 244]]),
  _f('Milk, skim', {
    'kcal': 34, 'protein': 3.4, 'carbs': 5.0, 'sugar': 5.1, 'fat': 0.1,
    'cholesterol': 2, 'sodium': 42, 'potassium': 156, 'calcium': 122,
    'phosphorus': 101, 'vit_a': 61, 'vit_d': 1.2, 'b2': 0.18, 'b12': 0.47,
    'water': 90.8,
  }, servings: [['1 cup (245 g)', 245]]),
  _f('Greek Yogurt, plain, nonfat', {
    'kcal': 59, 'protein': 10.2, 'carbs': 3.6, 'sugar': 3.2, 'fat': 0.4,
    'sat_fat': 0.1, 'cholesterol': 5, 'sodium': 36, 'potassium': 141,
    'calcium': 110, 'phosphorus': 135, 'b2': 0.28, 'b12': 0.75,
    'selenium': 9.7, 'water': 85.1,
  }, servings: [['1 container (170 g)', 170], ['1 cup (245 g)', 245]]),
  _f('Cheddar Cheese', {
    'kcal': 403, 'protein': 24.9, 'carbs': 1.3, 'sugar': 0.5, 'fat': 33.1,
    'sat_fat': 21.1, 'mono_fat': 9.4, 'cholesterol': 105, 'sodium': 621,
    'potassium': 98, 'calcium': 721, 'phosphorus': 512, 'zinc': 3.1,
    'vit_a': 265, 'b12': 0.83, 'selenium': 13.9, 'water': 36.8,
  }, servings: [['1 slice (28 g)', 28], ['1 cup, shredded (113 g)', 113]]),
  _f('Mozzarella Cheese', {
    'kcal': 300, 'protein': 22.2, 'carbs': 2.2, 'sugar': 1.0, 'fat': 22.4,
    'sat_fat': 13.2, 'cholesterol': 79, 'sodium': 627, 'calcium': 505,
    'phosphorus': 354, 'zinc': 2.9, 'vit_a': 179, 'b12': 2.3, 'water': 50.0,
  }, servings: [['1 oz (28 g)', 28]]),
  _f('Cottage Cheese, 2%', {
    'kcal': 84, 'protein': 11.0, 'carbs': 4.3, 'sugar': 4.1, 'fat': 2.3,
    'sat_fat': 1.4, 'cholesterol': 12, 'sodium': 321, 'potassium': 84,
    'calcium': 91, 'phosphorus': 151, 'selenium': 9.9, 'b12': 0.47,
    'water': 80.7,
  }, servings: [['1/2 cup (113 g)', 113]]),
  _f('Butter', {
    'kcal': 717, 'protein': 0.9, 'carbs': 0.1, 'fat': 81.1, 'sat_fat': 51.4,
    'mono_fat': 21.0, 'trans_fat': 3.3, 'cholesterol': 215, 'sodium': 11,
    'vit_a': 684, 'vit_e': 2.3, 'water': 16.2,
  }, servings: [['1 tbsp (14 g)', 14], ['1 pat (5 g)', 5]]),
  _f('Ice Cream, vanilla', {
    'kcal': 207, 'protein': 3.5, 'carbs': 23.6, 'sugar': 21.2, 'fat': 11.0,
    'sat_fat': 6.8, 'cholesterol': 44, 'sodium': 80, 'potassium': 199,
    'calcium': 128, 'phosphorus': 105, 'vit_a': 118, 'water': 61.0,
  }, servings: [['1/2 cup (66 g)', 66]]),

  // ---------------- Legumes, nuts, seeds ----------------
  _f('Lentils, cooked', {
    'kcal': 116, 'protein': 9.0, 'carbs': 20.1, 'fiber': 7.9, 'sugar': 1.8,
    'fat': 0.4, 'sodium': 2, 'potassium': 369, 'calcium': 19, 'iron': 3.3,
    'magnesium': 36, 'phosphorus': 180, 'zinc': 1.3, 'folate': 181,
    'b1': 0.17, 'manganese': 0.49, 'water': 69.6,
  }, servings: [['1 cup (198 g)', 198]]),
  _f('Chickpeas, cooked', {
    'kcal': 164, 'protein': 8.9, 'carbs': 27.4, 'fiber': 7.6, 'sugar': 4.8,
    'fat': 2.6, 'sodium': 7, 'potassium': 291, 'calcium': 49, 'iron': 2.9,
    'magnesium': 48, 'phosphorus': 168, 'zinc': 1.5, 'folate': 172,
    'manganese': 1.03, 'water': 60.2,
  }, servings: [['1 cup (164 g)', 164]]),
  _f('Black Beans, cooked', {
    'kcal': 132, 'protein': 8.9, 'carbs': 23.7, 'fiber': 8.7, 'sugar': 0.3,
    'fat': 0.5, 'sodium': 1, 'potassium': 355, 'calcium': 27, 'iron': 2.1,
    'magnesium': 70, 'phosphorus': 140, 'zinc': 1.1, 'folate': 149,
    'b1': 0.24, 'water': 65.7,
  }, servings: [['1 cup (172 g)', 172]]),
  _f('Tofu, firm', {
    'kcal': 144, 'protein': 17.3, 'carbs': 2.8, 'fiber': 2.3, 'fat': 8.7,
    'sat_fat': 1.3, 'sodium': 14, 'potassium': 237, 'calcium': 683,
    'iron': 2.7, 'magnesium': 58, 'phosphorus': 190, 'zinc': 1.6,
    'selenium': 17.3, 'manganese': 1.18, 'water': 69.8,
  }, servings: [['1/2 block (163 g)', 163], ['3 oz (85 g)', 85]]),
  _f('Almonds', {
    'kcal': 579, 'protein': 21.2, 'carbs': 21.6, 'fiber': 12.5, 'sugar': 4.4,
    'fat': 49.9, 'sat_fat': 3.8, 'mono_fat': 31.6, 'poly_fat': 12.3,
    'sodium': 1, 'potassium': 733, 'calcium': 269, 'iron': 3.7,
    'magnesium': 270, 'phosphorus': 481, 'zinc': 3.1, 'vit_e': 25.6,
    'b2': 1.14, 'manganese': 2.18, 'water': 4.4,
  }, servings: [['1 oz, 23 nuts (28 g)', 28], ['1/4 cup (36 g)', 36]]),
  _f('Walnuts', {
    'kcal': 654, 'protein': 15.2, 'carbs': 13.7, 'fiber': 6.7, 'sugar': 2.6,
    'fat': 65.2, 'sat_fat': 6.1, 'mono_fat': 8.9, 'poly_fat': 47.2,
    'sodium': 2, 'potassium': 441, 'calcium': 98, 'iron': 2.9,
    'magnesium': 158, 'phosphorus': 346, 'zinc': 3.1, 'copper': 1.59,
    'manganese': 3.41, 'folate': 98, 'water': 4.1,
  }, servings: [['1 oz, 14 halves (28 g)', 28]]),
  _f('Peanut Butter', {
    'kcal': 588, 'protein': 25.1, 'carbs': 19.6, 'fiber': 6.0, 'sugar': 9.2,
    'fat': 50.4, 'sat_fat': 10.3, 'mono_fat': 25.4, 'poly_fat': 12.3,
    'sodium': 476, 'potassium': 649, 'calcium': 43, 'iron': 1.9,
    'magnesium': 154, 'phosphorus': 358, 'zinc': 2.5, 'vit_e': 9.1,
    'b3': 13.1, 'folate': 87, 'water': 1.8,
  }, servings: [['2 tbsp (32 g)', 32], ['1 tbsp (16 g)', 16]]),
  _f('Chia Seeds', {
    'kcal': 486, 'protein': 16.5, 'carbs': 42.1, 'fiber': 34.4, 'fat': 30.7,
    'sat_fat': 3.3, 'poly_fat': 23.7, 'sodium': 16, 'potassium': 407,
    'calcium': 631, 'iron': 7.7, 'magnesium': 335, 'phosphorus': 860,
    'zinc': 4.6, 'b3': 8.8, 'selenium': 55.2, 'manganese': 2.72, 'water': 5.8,
  }, servings: [['1 tbsp (12 g)', 12], ['1 oz (28 g)', 28]]),
  _f('Sunflower Seeds', {
    'kcal': 584, 'protein': 20.8, 'carbs': 20.0, 'fiber': 8.6, 'sugar': 2.6,
    'fat': 51.5, 'sat_fat': 4.5, 'mono_fat': 18.5, 'poly_fat': 23.1,
    'sodium': 9, 'potassium': 645, 'calcium': 78, 'iron': 5.3,
    'magnesium': 325, 'phosphorus': 660, 'zinc': 5.0, 'vit_e': 35.2,
    'folate': 227, 'selenium': 53.0, 'water': 4.7,
  }, servings: [['1 oz (28 g)', 28]]),

  // ---------------- Oils & condiments ----------------
  _f('Olive Oil', {
    'kcal': 884, 'protein': 0, 'carbs': 0, 'fat': 100, 'sat_fat': 13.8,
    'mono_fat': 73.0, 'poly_fat': 10.5, 'vit_e': 14.4, 'vit_k': 60.2,
    'water': 0,
  }, servings: [['1 tbsp (14 g)', 14], ['1 tsp (4.5 g)', 4.5]]),
  _f('Mayonnaise', {
    'kcal': 680, 'protein': 1.0, 'carbs': 0.6, 'fat': 74.8, 'sat_fat': 11.7,
    'cholesterol': 42, 'sodium': 635, 'vit_e': 3.3, 'vit_k': 163.0,
    'water': 21.7,
  }, servings: [['1 tbsp (13.8 g)', 13.8]]),
  _f('Ketchup', {
    'kcal': 101, 'protein': 1.0, 'carbs': 27.4, 'fiber': 0.3, 'sugar': 21.3,
    'fat': 0.1, 'sodium': 907, 'potassium': 281, 'vit_a': 26, 'vit_c': 4.1,
    'water': 68.5,
  }, servings: [['1 tbsp (17 g)', 17]]),
  _f('Honey', {
    'kcal': 304, 'protein': 0.3, 'carbs': 82.4, 'sugar': 82.1, 'fat': 0,
    'sodium': 4, 'potassium': 52, 'water': 17.1,
  }, servings: [['1 tbsp (21 g)', 21]]),
  _f('Sugar, white', {
    'kcal': 387, 'protein': 0, 'carbs': 100, 'sugar': 99.8, 'fat': 0,
    'water': 0,
  }, servings: [['1 tsp (4.2 g)', 4.2], ['1 tbsp (12.5 g)', 12.5]]),

  // ---------------- Snacks / prepared ----------------
  _f('Pizza, cheese', {
    'kcal': 266, 'protein': 11.4, 'carbs': 33.3, 'fiber': 2.3, 'sugar': 3.6,
    'fat': 9.7, 'sat_fat': 4.5, 'cholesterol': 17, 'sodium': 598,
    'potassium': 172, 'calcium': 188, 'iron': 2.5, 'water': 43.0,
  }, servings: [['1 slice (107 g)', 107]]),
  _f('Hamburger, fast food', {
    'kcal': 254, 'protein': 12.3, 'carbs': 30.3, 'fiber': 1.1, 'sugar': 6.0,
    'fat': 9.8, 'sat_fat': 3.5, 'trans_fat': 0.5, 'cholesterol': 28,
    'sodium': 497, 'potassium': 197, 'calcium': 126, 'iron': 2.7,
    'water': 45.6,
  }, servings: [['1 burger (110 g)', 110]]),
  _f('French Fries', {
    'kcal': 312, 'protein': 3.4, 'carbs': 41.4, 'fiber': 3.8, 'sugar': 0.3,
    'fat': 15.0, 'sat_fat': 2.3, 'sodium': 210, 'potassium': 579,
    'magnesium': 35, 'vit_c': 9.7, 'b6': 0.36, 'water': 38.6,
  }, servings: [['1 medium serving (117 g)', 117]]),
  _f('Potato Chips', {
    'kcal': 536, 'protein': 7.0, 'carbs': 52.9, 'fiber': 4.8, 'sugar': 0.4,
    'fat': 34.6, 'sat_fat': 4.1, 'sodium': 525, 'potassium': 1196,
    'magnesium': 67, 'vit_c': 18.6, 'vit_e': 4.6, 'water': 1.9,
  }, servings: [['1 oz (28 g)', 28], ['1 small bag (42.5 g)', 42.5]]),
  _f('Chocolate, dark 70-85%', {
    'kcal': 598, 'protein': 7.8, 'carbs': 45.9, 'fiber': 10.9, 'sugar': 24.0,
    'fat': 42.6, 'sat_fat': 24.5, 'mono_fat': 12.8, 'sodium': 20,
    'potassium': 715, 'calcium': 73, 'iron': 11.9, 'magnesium': 228,
    'zinc': 3.3, 'copper': 1.77, 'manganese': 1.95, 'caffeine': 80,
    'water': 1.4,
  }, servings: [['1 square (10 g)', 10], ['1 bar (101 g)', 101]]),
  _f('Granola Bar', {
    'kcal': 471, 'protein': 10.1, 'carbs': 64.4, 'fiber': 5.4, 'sugar': 29.0,
    'fat': 19.8, 'sat_fat': 5.7, 'sodium': 79, 'potassium': 336,
    'calcium': 61, 'iron': 2.8, 'magnesium': 88, 'water': 6.1,
  }, servings: [['1 bar (24 g)', 24]]),
  _f('Protein Powder, whey', {
    'kcal': 400, 'protein': 80.0, 'carbs': 8.0, 'sugar': 4.0, 'fat': 6.0,
    'sat_fat': 3.0, 'cholesterol': 200, 'sodium': 500, 'potassium': 600,
    'calcium': 500, 'iron': 2.0, 'water': 4.0,
  }, servings: [['1 scoop (30 g)', 30]]),

  // ---------------- Beverages ----------------
  _f('Coffee, black', {
    'kcal': 1, 'protein': 0.1, 'carbs': 0, 'fat': 0, 'sodium': 2,
    'potassium': 49, 'magnesium': 3, 'caffeine': 40, 'water': 99.4,
  }, servings: [['1 cup (237 g)', 237]]),
  _f('Orange Juice', {
    'kcal': 45, 'protein': 0.7, 'carbs': 10.4, 'sugar': 8.4, 'fat': 0.2,
    'sodium': 1, 'potassium': 200, 'calcium': 11, 'vit_c': 50.0,
    'folate': 30, 'b1': 0.09, 'water': 88.3,
  }, servings: [['1 cup (248 g)', 248]]),
  _f('Cola', {
    'kcal': 42, 'protein': 0, 'carbs': 10.6, 'sugar': 10.6, 'fat': 0,
    'sodium': 4, 'caffeine': 8, 'water': 89.4,
  }, servings: [['1 can (355 g)', 355], ['1 bottle (500 g)', 500]]),
  _f('Beer, regular', {
    'kcal': 43, 'protein': 0.5, 'carbs': 3.6, 'sugar': 0, 'fat': 0,
    'alcohol': 3.9, 'sodium': 4, 'potassium': 27, 'magnesium': 6,
    'water': 91.9,
  }, servings: [['1 can (356 g)', 356]]),
  _f('Wine, red', {
    'kcal': 85, 'protein': 0.1, 'carbs': 2.6, 'sugar': 0.6, 'fat': 0,
    'alcohol': 10.6, 'sodium': 4, 'potassium': 127, 'water': 86.5,
  }, servings: [['1 glass (147 g)', 147]]),
];
