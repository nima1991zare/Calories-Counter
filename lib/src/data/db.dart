import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/entries.dart';
import '../models/food.dart';
import 'seed_foods.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'cal_counter.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE foods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            brand TEXT DEFAULT '',
            source TEXT NOT NULL,
            barcode TEXT,
            nutrients TEXT NOT NULL,
            servings TEXT NOT NULL,
            favorite INTEGER DEFAULT 0,
            recipe_servings REAL DEFAULT 1,
            created_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            meal INTEGER NOT NULL,
            food_id INTEGER NOT NULL,
            grams REAL NOT NULL,
            serving_name TEXT DEFAULT 'g',
            serving_qty REAL DEFAULT 0,
            created_at INTEGER,
            FOREIGN KEY (food_id) REFERENCES foods (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            name TEXT NOT NULL,
            minutes REAL NOT NULL,
            kcal REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE water (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            ml REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE biometrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            value REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE recipe_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipe_id INTEGER NOT NULL,
            food_id INTEGER NOT NULL,
            grams REAL NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_entries_date ON entries (date)');
        await db.execute('CREATE INDEX idx_foods_name ON foods (name)');
        await db.execute('CREATE INDEX idx_foods_barcode ON foods (barcode)');
        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();
    for (final item in seedFoods) {
      final servings = (item['servings'] as List)
          .map((s) => {'name': (s as List)[0], 'grams': s[1]})
          .toList();
      batch.insert('foods', {
        'name': item['name'] as String,
        'brand': '',
        'source': FoodSource.bundled.name,
        'nutrients': jsonEncode(item['nutrients']),
        'servings': jsonEncode(servings),
        'favorite': 0,
        'recipe_servings': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
    await batch.commit(noResult: true);
  }

  // ---------------- Foods ----------------

  Future<List<Food>> searchFoods(String query,
      {FoodSource? source, int limit = 100}) async {
    final db = await database;
    final where = <String>[];
    final args = <Object>[];
    if (query.trim().isNotEmpty) {
      where.add('(name LIKE ? OR brand LIKE ?)');
      args.add('%${query.trim()}%');
      args.add('%${query.trim()}%');
    }
    if (source != null) {
      where.add('source = ?');
      args.add(source.name);
    } else {
      // Exclude Open Food Facts cache rows from generic browsing; they appear
      // when searched online or already logged.
      where.add("source != '${FoodSource.openFoodFacts.name}'");
    }
    final rows = await db.query(
      'foods',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'favorite DESC, name COLLATE NOCASE ASC',
      limit: limit,
    );
    return rows.map(Food.fromDbMap).toList();
  }

  Future<Food?> foodById(int id) async {
    final db = await database;
    final rows = await db.query('foods', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Food.fromDbMap(rows.first);
  }

  Future<Food?> foodByBarcode(String barcode) async {
    final db = await database;
    final rows =
        await db.query('foods', where: 'barcode = ?', whereArgs: [barcode]);
    if (rows.isEmpty) return null;
    return Food.fromDbMap(rows.first);
  }

  Future<Food> insertFood(Food food) async {
    final db = await database;
    final map = food.toDbMap();
    map['created_at'] = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('foods', map);
    return food.copyWith(id: id);
  }

  Future<void> updateFood(Food food) async {
    final db = await database;
    await db
        .update('foods', food.toDbMap(), where: 'id = ?', whereArgs: [food.id]);
  }

  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
    await db.delete('entries', where: 'food_id = ?', whereArgs: [id]);
    await db.delete('recipe_items', where: 'recipe_id = ?', whereArgs: [id]);
  }

  Future<void> setFavorite(int foodId, bool favorite) async {
    final db = await database;
    await db.update('foods', {'favorite': favorite ? 1 : 0},
        where: 'id = ?', whereArgs: [foodId]);
  }

  /// Recently logged foods for quick re-adding.
  Future<List<Food>> recentFoods({int limit = 25}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT f.* FROM foods f
      INNER JOIN (
        SELECT food_id, MAX(created_at) AS latest
        FROM entries GROUP BY food_id
      ) e ON e.food_id = f.id
      ORDER BY e.latest DESC
      LIMIT ?
    ''', [limit]);
    return rows.map(Food.fromDbMap).toList();
  }

  // ---------------- Recipes ----------------

  Future<List<RecipeItem>> recipeItems(int recipeId) async {
    final db = await database;
    final rows = await db
        .query('recipe_items', where: 'recipe_id = ?', whereArgs: [recipeId]);
    return rows.map(RecipeItem.fromDbMap).toList();
  }

  Future<void> replaceRecipeItems(int recipeId, List<RecipeItem> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('recipe_items',
          where: 'recipe_id = ?', whereArgs: [recipeId]);
      for (final item in items) {
        await txn.insert('recipe_items', item.toDbMap());
      }
    });
  }

  // ---------------- Diary entries ----------------

  Future<List<LoggedFood>> entriesForDate(String date) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT e.id AS e_id, e.date, e.meal, e.food_id, e.grams,
             e.serving_name, e.serving_qty, f.*
      FROM entries e
      INNER JOIN foods f ON f.id = e.food_id
      WHERE e.date = ?
      ORDER BY e.meal ASC, e.created_at ASC
    ''', [date]);
    return rows.map((row) {
      final entry = DiaryEntry(
        id: row['e_id'] as int?,
        date: row['date'] as String,
        meal: Meal.values[(row['meal'] as int?) ?? 0],
        foodId: row['food_id'] as int,
        grams: (row['grams'] as num).toDouble(),
        servingName: row['serving_name'] as String? ?? 'g',
        servingQty: (row['serving_qty'] as num? ?? 0).toDouble(),
      );
      return LoggedFood(entry, Food.fromDbMap(row));
    }).toList();
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return db.insert('entries', entry.toDbMap());
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final db = await database;
    final map = entry.toDbMap()..remove('created_at');
    await db.update('entries', map, where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Total kcal consumed per day for the last [days] days (for trends).
  Future<Map<String, double>> kcalByDate(int days) async {
    final db = await database;
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceStr =
        '${since.year.toString().padLeft(4, '0')}-${since.month.toString().padLeft(2, '0')}-${since.day.toString().padLeft(2, '0')}';
    final rows = await db.rawQuery('''
      SELECT e.date, e.grams, f.nutrients
      FROM entries e
      INNER JOIN foods f ON f.id = e.food_id
      WHERE e.date >= ?
      ORDER BY e.date ASC
    ''', [sinceStr]);
    final totals = <String, double>{};
    for (final row in rows) {
      final nutrients =
          jsonDecode(row['nutrients'] as String? ?? '{}') as Map<String, dynamic>;
      final kcal100 = (nutrients['kcal'] as num? ?? 0).toDouble();
      final grams = (row['grams'] as num).toDouble();
      final date = row['date'] as String;
      totals[date] = (totals[date] ?? 0) + kcal100 * grams / 100.0;
    }
    return totals;
  }

  // ---------------- Exercises ----------------

  Future<List<ExerciseEntry>> exercisesForDate(String date) async {
    final db = await database;
    final rows =
        await db.query('exercises', where: 'date = ?', whereArgs: [date]);
    return rows.map(ExerciseEntry.fromDbMap).toList();
  }

  Future<int> insertExercise(ExerciseEntry e) async {
    final db = await database;
    return db.insert('exercises', e.toDbMap());
  }

  Future<void> deleteExercise(int id) async {
    final db = await database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Water ----------------

  Future<double> waterForDate(String date) async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT SUM(ml) AS total FROM water WHERE date = ?', [date]);
    return (rows.first['total'] as num? ?? 0).toDouble();
  }

  Future<void> addWater(String date, double ml) async {
    final db = await database;
    await db.insert('water', {'date': date, 'ml': ml});
  }

  Future<void> clearWater(String date) async {
    final db = await database;
    await db.delete('water', where: 'date = ?', whereArgs: [date]);
  }

  // ---------------- Biometrics ----------------

  Future<List<BiometricEntry>> biometricsForDate(String date) async {
    final db = await database;
    final rows =
        await db.query('biometrics', where: 'date = ?', whereArgs: [date]);
    return rows.map(BiometricEntry.fromDbMap).toList();
  }

  Future<List<BiometricEntry>> biometricHistory(String type,
      {int limit = 365}) async {
    final db = await database;
    final rows = await db.query(
      'biometrics',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date ASC',
      limit: limit,
    );
    return rows.map(BiometricEntry.fromDbMap).toList();
  }

  Future<int> insertBiometric(BiometricEntry e) async {
    final db = await database;
    return db.insert('biometrics', e.toDbMap());
  }

  Future<void> deleteBiometric(int id) async {
    final db = await database;
    await db.delete('biometrics', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Export ----------------

  Future<Map<String, dynamic>> exportAll() async {
    final db = await database;
    return {
      'foods': await db.query('foods'),
      'entries': await db.query('entries'),
      'exercises': await db.query('exercises'),
      'water': await db.query('water'),
      'biometrics': await db.query('biometrics'),
      'recipe_items': await db.query('recipe_items'),
    };
  }
}
