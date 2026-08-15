import 'package:flutter/material.dart';

import '../data/db.dart';
import '../models/food.dart';
import '../theme.dart';
import 'food_editor.dart';
import 'food_search.dart';
import 'recipe_editor.dart';

/// Manage foods: browse database, custom foods and recipes.
class FoodsTab extends StatefulWidget {
  const FoodsTab({super.key});

  @override
  State<FoodsTab> createState() => _FoodsTabState();
}

class _FoodsTabState extends State<FoodsTab>
    with SingleTickerProviderStateMixin {
  final _db = AppDatabase.instance;
  late final TabController _tabController;
  final _searchController = TextEditingController();

  List<Food> _all = [];
  List<Food> _custom = [];
  List<Food> _recipes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _reload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final q = _searchController.text;
    final results = await Future.wait([
      _db.searchFoods(q),
      _db.searchFoods(q, source: FoodSource.custom),
      _db.searchFoods(q, source: FoodSource.recipe),
    ]);
    if (!mounted) return;
    setState(() {
      _all = results[0];
      _custom = results[1];
      _recipes = results[2];
    });
  }

  Future<void> _openEditor(Food food) async {
    if (food.source == FoodSource.recipe) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeEditorScreen(recipe: food)),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FoodEditorScreen(food: food)),
      );
    }
    _reload();
  }

  Future<void> _showFoodActions(Food food) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(food.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(_sourceLabel(food.source),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                  food.favorite ? Icons.star : Icons.star_border,
                  color: AppColors.carbs),
              title: Text(food.favorite
                  ? 'Remove from favorites'
                  : 'Add to favorites'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _db.setFavorite(food.id!, !food.favorite);
                _reload();
              },
            ),
            if (food.source == FoodSource.custom ||
                food.source == FoodSource.recipe) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openEditor(food);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete, color: AppColors.danger),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete food?'),
                      content: Text(
                          '"${food.name}" and all its diary entries will be removed.'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await _db.deleteFood(food.id!);
                    _reload();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _sourceLabel(FoodSource source) {
    switch (source) {
      case FoodSource.bundled:
        return 'Built-in food database';
      case FoodSource.custom:
        return 'Custom food';
      case FoodSource.recipe:
        return 'Recipe';
      case FoodSource.openFoodFacts:
        return 'Open Food Facts';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foods'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _reload(),
                  decoration: const InputDecoration(
                    hintText: 'Filter foods...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Custom'),
                  Tab(text: 'Recipes'),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'foods-fab',
        onPressed: () async {
          if (_tabController.index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecipeEditorScreen()),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FoodEditorScreen()),
            );
          }
          _reload();
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 2 ? 'New Recipe' : 'New Food'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _list(_all, 'No foods found.'),
          _list(_custom,
              'No custom foods yet.\nTap "New Food" to create one.'),
          _list(_recipes,
              'No recipes yet.\nTap "New Recipe" to combine foods.'),
        ],
      ),
    );
  }

  Widget _list(List<Food> foods, String emptyMessage) {
    if (foods.isEmpty) {
      return Center(
        child: Text(emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: foods.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, i) {
        final food = foods[i];
        return FoodListTile(
          food: food,
          onTap: () => _showFoodActions(food),
          trailing: food.favorite
              ? const Icon(Icons.star, color: AppColors.carbs, size: 20)
              : null,
        );
      },
    );
  }
}
