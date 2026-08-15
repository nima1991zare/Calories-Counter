import 'package:flutter/material.dart';

import '../data/db.dart';
import '../models/food.dart';
import '../models/nutrients.dart';
import '../theme.dart';

/// Create or edit a custom food.
class FoodEditorScreen extends StatefulWidget {
  final Food? food;

  const FoodEditorScreen({super.key, this.food});

  @override
  State<FoodEditorScreen> createState() => _FoodEditorScreenState();
}

class _FoodEditorScreenState extends State<FoodEditorScreen> {
  final _db = AppDatabase.instance;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _servingName;
  late final TextEditingController _servingGrams;
  final Map<String, TextEditingController> _nutrientControllers = {};

  bool get _isEdit => widget.food != null;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _name = TextEditingController(text: f?.name ?? '');
    _brand = TextEditingController(text: f?.brand ?? '');
    final serving = (f?.servings.isNotEmpty ?? false) ? f!.servings.first : null;
    _servingName = TextEditingController(text: serving?.name ?? '1 serving');
    _servingGrams =
        TextEditingController(text: serving != null ? _fmt(serving.grams) : '100');
    for (final def in Nutrients.all) {
      final value = f?.per100g[def.key];
      // Values are entered per serving; converted on save. When editing we
      // show the per-serving value for the primary serving.
      final grams = serving?.grams ?? 100;
      _nutrientControllers[def.key] = TextEditingController(
        text: value == null || value == 0 ? '' : _fmt(value * grams / 100),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _servingName.dispose();
    _servingGrams.dispose();
    for (final c in _nutrientControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final servingGrams = double.tryParse(_servingGrams.text) ?? 100;
    final per100g = <String, double>{};
    for (final def in Nutrients.all) {
      final raw = _nutrientControllers[def.key]!.text.trim();
      if (raw.isEmpty) continue;
      final perServing = double.tryParse(raw);
      if (perServing == null || perServing == 0) continue;
      per100g[def.key] = perServing * 100 / servingGrams;
    }

    final food = Food(
      id: widget.food?.id,
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      source: widget.food?.source ?? FoodSource.custom,
      barcode: widget.food?.barcode,
      per100g: per100g,
      servings: [
        Serving(_servingName.text.trim().isEmpty
                ? '1 serving'
                : _servingName.text.trim(),
            servingGrams),
        ...?widget.food?.servings.skip(1),
      ],
      favorite: widget.food?.favorite ?? false,
    );

    if (_isEdit) {
      await _db.updateFood(food);
    } else {
      await _db.insertFood(food);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Food' : 'Create Custom Food'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Food name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(labelText: 'Brand (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _servingName,
                    decoration:
                        const InputDecoration(labelText: 'Serving name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _servingGrams,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Weight (g) *'),
                    validator: (v) {
                      final g = double.tryParse(v ?? '');
                      if (g == null || g <= 0) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter nutrient amounts per serving. Leave fields blank when unknown.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            for (final group in NutrientGroup.values) ...[
              const SizedBox(height: 16),
              Text(Nutrients.groupName(group),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final def
                  in Nutrients.all.where((d) => d.group == group))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    controller: _nutrientControllers[def.key],
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: '${def.name} (${def.unit})',
                      isDense: true,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save Food')),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
