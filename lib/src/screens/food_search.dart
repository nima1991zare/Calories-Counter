import 'dart:async';

import 'package:flutter/material.dart';

import '../data/db.dart';
import '../data/off_api.dart';
import '../models/entries.dart';
import '../models/food.dart';
import '../models/nutrients.dart';
import '../theme.dart';
import 'food_detail.dart';
import 'food_editor.dart';
import 'scanner.dart';

/// Search foods (local + Open Food Facts) to add to a meal.
class FoodSearchScreen extends StatefulWidget {
  final Meal meal;

  const FoodSearchScreen({super.key, required this.meal});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen>
    with SingleTickerProviderStateMixin {
  final _db = AppDatabase.instance;
  final _off = OpenFoodFactsApi();
  final _searchController = TextEditingController();
  late final TabController _tabController;

  Timer? _debounce;
  String _query = '';

  List<Food> _localResults = [];
  List<Food> _recentFoods = [];
  List<Food> _onlineResults = [];
  bool _onlineLoading = false;
  String? _onlineError;
  bool _onlineSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2 &&
          !_onlineSearched &&
          _query.trim().isNotEmpty) {
        _searchOnline();
      }
      setState(() {});
    });
    _loadLocal();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    final results = await _db.searchFoods(_query);
    if (mounted) setState(() => _localResults = results);
  }

  Future<void> _loadRecent() async {
    final results = await _db.recentFoods();
    if (mounted) setState(() => _recentFoods = results);
  }

  void _onQueryChanged(String value) {
    _query = value;
    _onlineSearched = false;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadLocal();
      if (_tabController.index == 2) _searchOnline();
    });
  }

  Future<void> _searchOnline() async {
    final q = _query.trim();
    if (q.isEmpty) return;
    setState(() {
      _onlineLoading = true;
      _onlineError = null;
      _onlineSearched = true;
    });
    try {
      final results = await _off.search(q);
      if (mounted) {
        setState(() {
          _onlineResults = results;
          _onlineLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _onlineError =
              'Online search failed. Check your internet connection.';
          _onlineLoading = false;
        });
      }
    }
  }

  Future<void> _openFood(Food food) async {
    // Persist online foods locally so diary entries can reference them.
    var resolved = food;
    if (food.id == null) {
      final existing = food.barcode != null
          ? await _db.foodByBarcode(food.barcode!)
          : null;
      resolved = existing ?? await _db.insertFood(food);
    }
    if (!mounted) return;
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetailScreen(food: resolved, meal: widget.meal),
      ),
    );
    if (added == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to ${widget.meal.label}'),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => BarcodeScannerScreen(meal: widget.meal)),
            ),
          ),
          IconButton(
            tooltip: 'Create custom food',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FoodEditorScreen()),
              );
              _loadLocal();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onQueryChanged,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) {
                    if (_tabController.index == 2) _searchOnline();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search foods...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onQueryChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'My Foods'),
                  Tab(text: 'Recent'),
                  Tab(text: 'Online'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _foodList(_localResults,
              emptyMessage: _query.isEmpty
                  ? 'Type to search the food database.'
                  : 'No foods found. Try the Online tab or create a custom food.'),
          _foodList(_recentFoods,
              emptyMessage: 'Foods you log will appear here for quick access.'),
          _onlineTab(),
        ],
      ),
    );
  }

  Widget _onlineTab() {
    if (_onlineLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_onlineError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_onlineError!,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: _searchOnline, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (!_onlineSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, color: AppColors.textSecondary, size: 42),
              const SizedBox(height: 12),
              const Text(
                'Search millions of foods from Open Food Facts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              if (_query.trim().isNotEmpty)
                FilledButton(
                  onPressed: _searchOnline,
                  child: Text('Search "${_query.trim()}" online'),
                ),
            ],
          ),
        ),
      );
    }
    return _foodList(_onlineResults,
        emptyMessage: 'No online results for "${_query.trim()}".');
  }

  Widget _foodList(List<Food> foods, {required String emptyMessage}) {
    if (foods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return ListView.separated(
      itemCount: foods.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final food = foods[index];
        return FoodListTile(food: food, onTap: () => _openFood(food));
      },
    );
  }
}

/// Shared list tile for foods.
class FoodListTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  final Widget? trailing;

  const FoodListTile(
      {super.key, required this.food, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final serving = food.defaultServing;
    final kcal = food.nutrientFor(Nutrients.kcal, serving.grams);
    IconData icon;
    switch (food.source) {
      case FoodSource.custom:
        icon = Icons.person;
      case FoodSource.recipe:
        icon = Icons.soup_kitchen;
      case FoodSource.openFoodFacts:
        icon = Icons.public;
      case FoodSource.bundled:
        icon = Icons.restaurant;
    }
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceLight,
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (food.brand.isNotEmpty) food.brand,
          serving.name,
          'P ${food.nutrientFor(Nutrients.protein, serving.grams).round()} · '
              'C ${food.nutrientFor(Nutrients.carbs, serving.grams).round()} · '
              'F ${food.nutrientFor(Nutrients.fat, serving.grams).round()}',
        ].join('  ·  '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
      ),
      trailing: trailing ??
          Text('${kcal.round()} kcal',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
      onTap: onTap,
    );
  }
}
