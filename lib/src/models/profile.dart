import 'dart:convert';

enum Sex { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

extension ActivityLevelX on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary (little exercise)';
      case ActivityLevel.light:
        return 'Lightly active (1-3 days/week)';
      case ActivityLevel.moderate:
        return 'Moderately active (3-5 days/week)';
      case ActivityLevel.active:
        return 'Active (6-7 days/week)';
      case ActivityLevel.veryActive:
        return 'Very active (physical job)';
    }
  }

  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }
}

enum GoalType { lose, maintain, gain }

extension GoalTypeX on GoalType {
  String get label {
    switch (this) {
      case GoalType.lose:
        return 'Lose weight';
      case GoalType.maintain:
        return 'Maintain weight';
      case GoalType.gain:
        return 'Gain weight';
    }
  }
}

class UserProfile {
  final String name;
  final Sex sex;
  final int birthYear;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final GoalType goal;

  /// Target weight change in kg per week (positive number).
  final double goalRateKgPerWeek;

  /// Macro ratios as fractions of energy (must sum to ~1.0).
  final double proteinRatio;
  final double carbsRatio;
  final double fatRatio;

  /// Optional manual calorie target override (kcal). 0 = automatic.
  final double customKcalTarget;

  /// Daily water goal in ml.
  final double waterGoalMl;

  /// Whether exercise calories increase the daily energy budget.
  final bool includeExerciseInBudget;

  const UserProfile({
    this.name = '',
    this.sex = Sex.male,
    this.birthYear = 1995,
    this.heightCm = 175,
    this.weightKg = 75,
    this.activity = ActivityLevel.light,
    this.goal = GoalType.maintain,
    this.goalRateKgPerWeek = 0.5,
    this.proteinRatio = 0.30,
    this.carbsRatio = 0.40,
    this.fatRatio = 0.30,
    this.customKcalTarget = 0,
    this.waterGoalMl = 2500,
    this.includeExerciseInBudget = true,
  });

  int get age {
    final now = DateTime.now();
    return (now.year - birthYear).clamp(1, 120);
  }

  /// Mifflin-St Jeor basal metabolic rate.
  double get bmr {
    final s = sex == Sex.male ? 5 : -161;
    return 10 * weightKg + 6.25 * heightCm - 5 * age + s;
  }

  /// Total daily energy expenditure.
  double get tdee => bmr * activity.factor;

  /// Daily calorie target, taking goal into account.
  double get kcalTarget {
    if (customKcalTarget > 0) return customKcalTarget;
    // 1 kg of body weight ~ 7700 kcal.
    final dailyDelta = goalRateKgPerWeek * 7700 / 7;
    switch (goal) {
      case GoalType.lose:
        return (tdee - dailyDelta).clamp(1000, 10000);
      case GoalType.maintain:
        return tdee;
      case GoalType.gain:
        return tdee + dailyDelta;
    }
  }

  double get proteinTargetG => kcalTarget * proteinRatio / 4;
  double get carbsTargetG => kcalTarget * carbsRatio / 4;
  double get fatTargetG => kcalTarget * fatRatio / 9;

  UserProfile copyWith({
    String? name,
    Sex? sex,
    int? birthYear,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activity,
    GoalType? goal,
    double? goalRateKgPerWeek,
    double? proteinRatio,
    double? carbsRatio,
    double? fatRatio,
    double? customKcalTarget,
    double? waterGoalMl,
    bool? includeExerciseInBudget,
  }) {
    return UserProfile(
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activity: activity ?? this.activity,
      goal: goal ?? this.goal,
      goalRateKgPerWeek: goalRateKgPerWeek ?? this.goalRateKgPerWeek,
      proteinRatio: proteinRatio ?? this.proteinRatio,
      carbsRatio: carbsRatio ?? this.carbsRatio,
      fatRatio: fatRatio ?? this.fatRatio,
      customKcalTarget: customKcalTarget ?? this.customKcalTarget,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      includeExerciseInBudget:
          includeExerciseInBudget ?? this.includeExerciseInBudget,
    );
  }

  String toJsonString() => jsonEncode({
        'name': name,
        'sex': sex.name,
        'birthYear': birthYear,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activity': activity.name,
        'goal': goal.name,
        'goalRateKgPerWeek': goalRateKgPerWeek,
        'proteinRatio': proteinRatio,
        'carbsRatio': carbsRatio,
        'fatRatio': fatRatio,
        'customKcalTarget': customKcalTarget,
        'waterGoalMl': waterGoalMl,
        'includeExerciseInBudget': includeExerciseInBudget,
      });

  factory UserProfile.fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return UserProfile(
      name: json['name'] as String? ?? '',
      sex: Sex.values.firstWhere((s) => s.name == json['sex'],
          orElse: () => Sex.male),
      birthYear: json['birthYear'] as int? ?? 1995,
      heightCm: (json['heightCm'] as num? ?? 175).toDouble(),
      weightKg: (json['weightKg'] as num? ?? 75).toDouble(),
      activity: ActivityLevel.values.firstWhere(
          (a) => a.name == json['activity'],
          orElse: () => ActivityLevel.light),
      goal: GoalType.values.firstWhere((g) => g.name == json['goal'],
          orElse: () => GoalType.maintain),
      goalRateKgPerWeek: (json['goalRateKgPerWeek'] as num? ?? 0.5).toDouble(),
      proteinRatio: (json['proteinRatio'] as num? ?? 0.30).toDouble(),
      carbsRatio: (json['carbsRatio'] as num? ?? 0.40).toDouble(),
      fatRatio: (json['fatRatio'] as num? ?? 0.30).toDouble(),
      customKcalTarget: (json['customKcalTarget'] as num? ?? 0).toDouble(),
      waterGoalMl: (json['waterGoalMl'] as num? ?? 2500).toDouble(),
      includeExerciseInBudget:
          json['includeExerciseInBudget'] as bool? ?? true,
    );
  }
}
