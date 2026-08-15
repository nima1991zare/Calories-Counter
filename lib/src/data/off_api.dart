import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/food.dart';
import '../models/nutrients.dart';

/// Client for the free Open Food Facts database (no API key required).
class OpenFoodFactsApi {
  static const _searchHost = 'world.openfoodfacts.org';
  static const _userAgent = 'CalCounter/1.0 (Flutter; local calorie tracker)';

  final http.Client _client;

  OpenFoodFactsApi({http.Client? client}) : _client = client ?? http.Client();

  /// Search foods by free-text query.
  Future<List<Food>> search(String query, {int pageSize = 25}) async {
    final uri = Uri.https(_searchHost, '/cgi/search.pl', {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '$pageSize',
      'fields': 'product_name,brands,code,nutriments,serving_quantity',
    });
    final res = await _client
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Open Food Facts search failed (${res.statusCode})');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final products = (json['products'] as List? ?? []);
    return products
        .whereType<Map<String, dynamic>>()
        .map(_productToFood)
        .whereType<Food>()
        .toList();
  }

  /// Look up a product by barcode. Returns null if not found.
  Future<Food?> byBarcode(String barcode) async {
    final uri = Uri.https(_searchHost, '/api/v2/product/$barcode.json', {
      'fields': 'product_name,brands,code,nutriments,serving_quantity',
    });
    final res = await _client
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 20));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Open Food Facts lookup failed (${res.statusCode})');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['status'] == 0) return null;
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) return null;
    return _productToFood(product);
  }

  Food? _productToFood(Map<String, dynamic> product) {
    final name = (product['product_name'] as String? ?? '').trim();
    if (name.isEmpty) return null;
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    double n(String key) {
      final v = nutriments['${key}_100g'] ?? nutriments[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    // Energy: OFF reports kJ under energy_100g and kcal under energy-kcal_100g.
    double kcal = n('energy-kcal');
    if (kcal == 0) {
      final kj = n('energy');
      if (kj > 0) kcal = kj / 4.184;
    }

    final per100g = <String, double>{
      Nutrients.kcal: kcal,
      Nutrients.protein: n('proteins'),
      Nutrients.carbs: n('carbohydrates'),
      Nutrients.fiber: n('fiber'),
      Nutrients.sugar: n('sugars'),
      Nutrients.fat: n('fat'),
      Nutrients.satFat: n('saturated-fat'),
      Nutrients.transFat: n('trans-fat'),
      Nutrients.monoFat: n('monounsaturated-fat'),
      Nutrients.polyFat: n('polyunsaturated-fat'),
      Nutrients.cholesterol: n('cholesterol') * 1000, // g -> mg
      Nutrients.sodium: n('sodium') * 1000, // g -> mg
      Nutrients.potassium: n('potassium') * 1000,
      Nutrients.calcium: n('calcium') * 1000,
      Nutrients.iron: n('iron') * 1000,
      Nutrients.magnesium: n('magnesium') * 1000,
      Nutrients.zinc: n('zinc') * 1000,
      Nutrients.vitA: n('vitamin-a') * 1e6, // g -> µg
      Nutrients.vitC: n('vitamin-c') * 1000,
      Nutrients.vitD: n('vitamin-d') * 1e6,
      Nutrients.vitE: n('vitamin-e') * 1000,
      Nutrients.vitK: n('vitamin-k') * 1e6,
      Nutrients.b1: n('vitamin-b1') * 1000,
      Nutrients.b2: n('vitamin-b2') * 1000,
      Nutrients.b3: n('vitamin-pp') * 1000,
      Nutrients.b6: n('vitamin-b6') * 1000,
      Nutrients.b12: n('vitamin-b12') * 1e6,
      Nutrients.folate: n('folates') * 1e6,
      Nutrients.caffeine: n('caffeine') * 1000,
      Nutrients.alcohol: n('alcohol'),
    }..removeWhere((_, v) => v == 0);

    if (per100g.isEmpty) return null;

    final servings = <Serving>[];
    final servingQty = product['serving_quantity'];
    final servingGrams = servingQty is num
        ? servingQty.toDouble()
        : double.tryParse('$servingQty') ?? 0;
    if (servingGrams > 0) {
      servings.add(Serving('1 serving (${_fmt(servingGrams)} g)', servingGrams));
    }

    return Food(
      name: name,
      brand: (product['brands'] as String? ?? '').split(',').first.trim(),
      source: FoodSource.openFoodFacts,
      barcode: product['code'] as String?,
      per100g: per100g,
      servings: servings,
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
