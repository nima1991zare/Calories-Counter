import 'package:flutter/foundation.dart';

import '../data/db.dart';
import '../models/entries.dart';
import '../models/nutrients.dart';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// State for the currently selected diary day.
class DiaryState extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  DateTime _date = DateTime.now();
  List<LoggedFood> _entries = [];
  List<ExerciseEntry> _exercises = [];
  double _waterMl = 0;
  List<BiometricEntry> _biometrics = [];
  bool _loading = true;

  DateTime get date => _date;
  String get dateStr => dateKey(_date);
  List<LoggedFood> get entries => _entries;
  List<ExerciseEntry> get exercises => _exercises;
  double get waterMl => _waterMl;
  List<BiometricEntry> get biometrics => _biometrics;
  bool get loading => _loading;

  bool get isToday => dateKey(DateTime.now()) == dateStr;

  Future<void> init() => refresh();

  Future<void> setDate(DateTime date) async {
    _date = date;
    await refresh();
  }

  Future<void> shiftDate(int days) =>
      setDate(_date.add(Duration(days: days)));

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    final d = dateStr;
    final results = await Future.wait([
      _db.entriesForDate(d),
      _db.exercisesForDate(d),
      _db.waterForDate(d),
      _db.biometricsForDate(d),
    ]);
    _entries = results[0] as List<LoggedFood>;
    _exercises = results[1] as List<ExerciseEntry>;
    _waterMl = results[2] as double;
    _biometrics = results[3] as List<BiometricEntry>;
    _loading = false;
    notifyListeners();
  }

  // ---------------- Aggregations ----------------

  List<LoggedFood> entriesForMeal(Meal meal) =>
      _entries.where((e) => e.entry.meal == meal).toList();

  double mealKcal(Meal meal) => entriesForMeal(meal)
      .fold(0.0, (sum, e) => sum + e.nutrient(Nutrients.kcal));

  /// Total consumed amount for a nutrient key today.
  double consumed(String key) =>
      _entries.fold(0.0, (sum, e) => sum + e.nutrient(key));

  double get kcalConsumed => consumed(Nutrients.kcal);
  double get proteinConsumed => consumed(Nutrients.protein);
  double get carbsConsumed => consumed(Nutrients.carbs);
  double get fatConsumed => consumed(Nutrients.fat);

  double get kcalBurned =>
      _exercises.fold(0.0, (sum, e) => sum + e.kcal);

  /// All nutrient totals for the day.
  Map<String, double> get nutrientTotals {
    final totals = <String, double>{};
    for (final logged in _entries) {
      for (final def in Nutrients.all) {
        final v = logged.nutrient(def.key);
        if (v != 0) totals[def.key] = (totals[def.key] ?? 0) + v;
      }
    }
    return totals;
  }

  // ---------------- Mutations ----------------

  Future<void> addEntry(DiaryEntry entry) async {
    await _db.insertEntry(entry);
    await refresh();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _db.updateEntry(entry);
    await refresh();
  }

  Future<void> removeEntry(int id) async {
    await _db.deleteEntry(id);
    await refresh();
  }

  Future<void> addExercise(ExerciseEntry e) async {
    await _db.insertExercise(e);
    await refresh();
  }

  Future<void> removeExercise(int id) async {
    await _db.deleteExercise(id);
    await refresh();
  }

  Future<void> addWater(double ml) async {
    await _db.addWater(dateStr, ml);
    await refresh();
  }

  Future<void> resetWater() async {
    await _db.clearWater(dateStr);
    await refresh();
  }

  Future<void> addBiometric(String type, double value) async {
    await _db.insertBiometric(
        BiometricEntry(date: dateStr, type: type, value: value));
    await refresh();
  }

  Future<void> removeBiometric(int id) async {
    await _db.deleteBiometric(id);
    await refresh();
  }
}
