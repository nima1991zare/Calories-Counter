import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/entries.dart';
import '../models/food.dart';
import '../models/nutrients.dart';
import '../state/app_state.dart';
import '../state/diary_state.dart';
import '../theme.dart';

/// Food details with serving selection; adds or updates a diary entry.
class FoodDetailScreen extends StatefulWidget {
  final Food food;
  final Meal meal;
  final DiaryEntry? existingEntry;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.meal,
    this.existingEntry,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late Meal _meal;
  late Serving _serving;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _meal = widget.existingEntry?.meal ?? widget.meal;
    final servings = widget.food.allServings;
    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      _serving = servings.firstWhere(
        (s) => s.name == e.servingName,
        orElse: () => const Serving('1 g', 1),
      );
      final qty = e.servingQty > 0 ? e.servingQty : e.grams / _serving.grams;
      _qtyController = TextEditingController(text: _fmtQty(qty));
    } else {
      _serving = widget.food.defaultServing;
      _qtyController = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  double get _qty => double.tryParse(_qtyController.text) ?? 0;
  double get _grams => _qty * _serving.grams;

  static String _fmtQty(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2);

  Future<void> _save() async {
    if (_grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter an amount greater than zero.')));
      return;
    }
    final diary = context.read<DiaryState>();
    if (widget.existingEntry != null) {
      await diary.updateEntry(widget.existingEntry!.copyWith(
        meal: _meal,
        grams: _grams,
        servingName: _serving.name,
        servingQty: _qty,
      ));
    } else {
      await diary.addEntry(DiaryEntry(
        date: diary.dateStr,
        meal: _meal,
        foodId: widget.food.id!,
        grams: _grams,
        servingName: _serving.name,
        servingQty: _qty,
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final app = context.watch<AppState>();
    final targets = app.nutrientTargets;
    final isEdit = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          if (food.brand.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(food.brand,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(labelText: 'Qty'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<Serving>(
                          initialValue: _serving,
                          decoration:
                              const InputDecoration(labelText: 'Serving'),
                          dropdownColor: AppColors.surfaceLight,
                          items: food.allServings
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s.name)))
                              .toList(),
                          onChanged: (s) => setState(() => _serving = s!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Meal>(
                    initialValue: _meal,
                    decoration: const InputDecoration(labelText: 'Meal'),
                    dropdownColor: AppColors.surfaceLight,
                    items: Meal.values
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m.label)))
                        .toList(),
                    onChanged: (m) => setState(() => _meal = m!),
                  ),
                  const SizedBox(height: 8),
                  Text('Total: ${_grams.round()} g',
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          _macroSummary(food),
          _nutritionFacts(food, targets),
        ],
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: Icon(isEdit ? Icons.check : Icons.add),
            label: Text(isEdit
                ? 'Update Entry'
                : 'Add to ${_meal.label} · ${food.nutrientFor(Nutrients.kcal, _grams).round()} kcal'),
            onPressed: _save,
          ),
        ),
      ),
    );
  }

  Widget _macroSummary(Food food) {
    Widget stat(String label, double value, String unit, Color color) {
      return Expanded(
        child: Column(
          children: [
            Text('${value.round()}$unit',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            stat('Calories', food.nutrientFor(Nutrients.kcal, _grams), '',
                AppColors.primary),
            stat('Protein', food.nutrientFor(Nutrients.protein, _grams), 'g',
                AppColors.protein),
            stat('Carbs', food.nutrientFor(Nutrients.carbs, _grams), 'g',
                AppColors.carbs),
            stat('Fat', food.nutrientFor(Nutrients.fat, _grams), 'g',
                AppColors.fat),
          ],
        ),
      ),
    );
  }

  Widget _nutritionFacts(Food food, Map<String, double> targets) {
    final groups = <NutrientGroup, List<NutrientDef>>{};
    for (final def in Nutrients.all) {
      final value = food.nutrientFor(def.key, _grams);
      if (value != 0) {
        groups.putIfAbsent(def.group, () => []).add(def);
      }
    }
    if (groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No detailed nutrition data available for this food.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nutrition Facts',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            for (final group in NutrientGroup.values)
              if (groups.containsKey(group)) ...[
                const SizedBox(height: 12),
                Text(Nutrients.groupName(group),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const SizedBox(height: 4),
                for (final def in groups[group]!)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(def.name,
                                style: const TextStyle(fontSize: 13.5))),
                        Text(
                          '${_fmtValue(food.nutrientFor(def.key, _grams))} ${def.unit}',
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 52,
                          child: Text(
                            _pctOfTarget(
                                def.key, food.nutrientFor(def.key, _grams), targets),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  String _pctOfTarget(String key, double value, Map<String, double> targets) {
    final target = targets[key];
    if (target == null || target <= 0) return '';
    return '${(value / target * 100).round()}%';
  }

  String _fmtValue(double v) {
    if (v >= 100) return v.round().toString();
    if (v >= 10) return v.toStringAsFixed(1);
    return v.toStringAsFixed(2);
  }
}
