import 'package:flutter_test/flutter_test.dart';

import 'package:cal_counter/src/models/food.dart';
import 'package:cal_counter/src/models/nutrients.dart';
import 'package:cal_counter/src/models/profile.dart';

void main() {
  group('UserProfile targets', () {
    test('BMR uses Mifflin-St Jeor', () {
      final profile = UserProfile(
        sex: Sex.male,
        birthYear: DateTime.now().year - 30,
        heightCm: 180,
        weightKg: 80,
      );
      // 10*80 + 6.25*180 - 5*30 + 5 = 1780
      expect(profile.bmr, closeTo(1780, 0.01));
    });

    test('kcal target respects goal', () {
      final base = UserProfile(
        sex: Sex.female,
        birthYear: DateTime.now().year - 25,
        heightCm: 165,
        weightKg: 60,
        activity: ActivityLevel.moderate,
      );
      final lose = base.copyWith(goal: GoalType.lose, goalRateKgPerWeek: 0.5);
      final gain = base.copyWith(goal: GoalType.gain, goalRateKgPerWeek: 0.5);
      expect(lose.kcalTarget, lessThan(base.tdee));
      expect(gain.kcalTarget, greaterThan(base.tdee));
      expect(lose.kcalTarget, closeTo(base.tdee - 550, 1));
    });

    test('macro targets sum to calorie target', () {
      const profile = UserProfile();
      final kcalFromMacros = profile.proteinTargetG * 4 +
          profile.carbsTargetG * 4 +
          profile.fatTargetG * 9;
      expect(kcalFromMacros, closeTo(profile.kcalTarget, 1));
    });
  });

  group('Food', () {
    test('nutrientFor scales per grams', () {
      const food = Food(name: 'Test', per100g: {Nutrients.kcal: 200});
      expect(food.nutrientFor(Nutrients.kcal, 50), 100);
      expect(food.nutrientFor(Nutrients.kcal, 150), 300);
    });

    test('serializes to and from db map', () {
      const food = Food(
        name: 'Apple',
        brand: 'Fresh',
        source: FoodSource.bundled,
        per100g: {Nutrients.kcal: 52, Nutrients.carbs: 13.8},
        servings: [Serving('1 medium (182 g)', 182)],
      );
      final restored = Food.fromDbMap({...food.toDbMap(), 'id': 1});
      expect(restored.name, 'Apple');
      expect(restored.per100g[Nutrients.kcal], 52);
      expect(restored.servings.single.grams, 182);
      expect(restored.source, FoodSource.bundled);
    });
  });

  group('Nutrients registry', () {
    test('all keys are unique', () {
      final keys = Nutrients.all.map((n) => n.key).toSet();
      expect(keys.length, Nutrients.all.length);
    });

    test('RDA targets differ by sex where expected', () {
      final male = Nutrients.rdaTargets(male: true);
      final female = Nutrients.rdaTargets(male: false);
      expect(male[Nutrients.iron], lessThan(female[Nutrients.iron]!));
      expect(male[Nutrients.vitA], greaterThan(female[Nutrients.vitA]!));
    });
  });
}
