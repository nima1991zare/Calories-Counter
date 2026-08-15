import 'package:flutter/material.dart';

import '../data/db.dart';
import '../models/entries.dart';
import '../models/food.dart';
import '../models/nutrients.dart';
import '../theme.dart';
import 'food_search.dart';

class _Ingredient {
  final Food food;
  double grams;

  _Ingredient(this.food, this.grams);
}

/// Create or edit a recipe made from other foods.
class RecipeEditorScreen extends StatefulWidget {
  final Food? recipe;

  const RecipeEditorScreen({super.key, this.recipe});

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  final _db = AppDatabase.instance;
  late final TextEditingController _name;
  late final TextEditingController _servingsCount;
  final List<_Ingredient> _ingredients = [];
  bool _loading = true;

  bool get _isEdit => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.recipe?.name ?? '');
    _servingsCount = TextEditingController(
        text: widget.recipe != null
            ? _fmt(widget.recipe!.recipeServings)
            : '1');
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (widget.recipe?.id != null) {
      final items = await _db.recipeItems(widget.recipe!.id!);
      for (final item in items) {
        final food = await _db.foodById(item.foodId);
        if (food != null) _ingredients.add(_Ingredient(food, item.grams));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _servingsCount.dispose();
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  double get _totalGrams =>
      _ingredients.fold(0.0, (sum, i) => sum + i.grams);

  /// Combined nutrients of the whole recipe, per 100 g of finished recipe.
  Map<String, double> get _per100g {
    final total = <String, double>{};
    for (final ing in _ingredients) {
      for (final def in Nutrients.all) {
        final v = ing.food.nutrientFor(def.key, ing.grams);
        if (v != 0) total[def.key] = (total[def.key] ?? 0) + v;
      }
    }
    final grams = _totalGrams;
    if (grams <= 0) return {};
    return total.map((k, v) => MapEntry(k, v * 100 / grams));
  }

  Future<void> _addIngredient() async {
    final food = await Navigator.push<Food>(
      context,
      MaterialPageRoute(builder: (_) => const _IngredientPicker()),
    );
    if (food == null || !mounted) return;
    final grams = await _askGrams(food);
    if (grams != null && grams > 0) {
      setState(() => _ingredients.add(_Ingredient(food, grams)));
    }
  }

  Future<double?> _askGrams(Food food, {double? initial}) async {
    final controller =
        TextEditingController(text: initial != null ? _fmt(initial) : '100');
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(food.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (g)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
                dialogContext, double.tryParse(controller.text)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Give your recipe a name.')));
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one ingredient.')));
      return;
    }
    final servingsCount =
        (double.tryParse(_servingsCount.text) ?? 1).clamp(0.1, 1000.0);
    final servingGrams = _totalGrams / servingsCount;

    var recipe = Food(
      id: widget.recipe?.id,
      name: _name.text.trim(),
      source: FoodSource.recipe,
      per100g: _per100g,
      servings: [
        Serving('1 serving (${servingGrams.round()} g)', servingGrams),
        Serving('whole recipe (${_totalGrams.round()} g)', _totalGrams),
      ],
      recipeServings: servingsCount,
      favorite: widget.recipe?.favorite ?? false,
    );

    if (_isEdit) {
      await _db.updateFood(recipe);
    } else {
      recipe = await _db.insertFood(recipe);
    }
    await _db.replaceRecipeItems(
      recipe.id!,
      _ingredients
          .map((i) => RecipeItem(
              recipeId: recipe.id!, foodId: i.food.id!, grams: i.grams))
          .toList(),
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final per100 = _per100g;
    final totalKcal = (per100[Nutrients.kcal] ?? 0) * _totalGrams / 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Recipe' : 'Create Recipe'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(labelText: 'Recipe name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _servingsCount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      labelText: 'Number of servings this recipe makes'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Ingredients',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (_ingredients.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No ingredients yet. Tap "Add" to build your recipe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                for (int i = 0; i < _ingredients.length; i++)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(_ingredients[i].food.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${_ingredients[i].grams.round()} g · '
                        '${_ingredients[i].food.nutrientFor(Nutrients.kcal, _ingredients[i].grams).round()} kcal',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      onTap: () async {
                        final grams = await _askGrams(_ingredients[i].food,
                            initial: _ingredients[i].grams);
                        if (grams != null && grams > 0) {
                          setState(() => _ingredients[i].grams = grams);
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger),
                        onPressed: () =>
                            setState(() => _ingredients.removeAt(i)),
                      ),
                    ),
                  ),
                if (_ingredients.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recipe totals',
                              style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            '${_totalGrams.round()} g total · ${totalKcal.round()} kcal\n'
                            'P ${((per100[Nutrients.protein] ?? 0) * _totalGrams / 100).round()} g · '
                            'C ${((per100[Nutrients.carbs] ?? 0) * _totalGrams / 100).round()} g · '
                            'F ${((per100[Nutrients.fat] ?? 0) * _totalGrams / 100).round()} g',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}

/// Simplified food picker used when adding recipe ingredients.
class _IngredientPicker extends StatefulWidget {
  const _IngredientPicker();

  @override
  State<_IngredientPicker> createState() => _IngredientPickerState();
}

class _IngredientPickerState extends State<_IngredientPicker> {
  final _db = AppDatabase.instance;
  List<Food> _results = [];

  @override
  void initState() {
    super.initState();
    _search('');
  }

  Future<void> _search(String query) async {
    final results = await _db.searchFoods(query);
    if (mounted) {
      setState(() =>
          _results = results.where((f) => f.source != FoodSource.recipe).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Ingredient')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (context, i) => FoodListTile(
                food: _results[i],
                onTap: () => Navigator.pop(context, _results[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
