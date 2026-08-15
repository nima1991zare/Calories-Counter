import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/nutrients.dart';
import '../state/app_state.dart';
import '../state/diary_state.dart';
import '../theme.dart';
import '../widgets/rings.dart';

/// Cronometer-style full nutrient breakdown for the selected day.
class NutritionReportScreen extends StatelessWidget {
  const NutritionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diary = context.watch<DiaryState>();
    final app = context.watch<AppState>();
    final totals = diary.nutrientTotals;
    final targets = app.nutrientTargets;

    final dateLabel = diary.isToday
        ? 'Today'
        : DateFormat('EEEE, MMM d').format(diary.date);

    return Scaffold(
      appBar: AppBar(title: Text('Nutrition · $dateLabel')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Energy Summary',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  NutrientBar(
                    label: 'Energy',
                    value: totals[Nutrients.kcal] ?? 0,
                    target: targets[Nutrients.kcal] ?? 0,
                    unit: 'kcal',
                  ),
                  NutrientBar(
                    label: 'Protein',
                    value: totals[Nutrients.protein] ?? 0,
                    target: targets[Nutrients.protein] ?? 0,
                    unit: 'g',
                    color: AppColors.protein,
                  ),
                  NutrientBar(
                    label: 'Carbohydrates',
                    value: totals[Nutrients.carbs] ?? 0,
                    target: targets[Nutrients.carbs] ?? 0,
                    unit: 'g',
                    color: AppColors.carbs,
                  ),
                  NutrientBar(
                    label: 'Fat',
                    value: totals[Nutrients.fat] ?? 0,
                    target: targets[Nutrients.fat] ?? 0,
                    unit: 'g',
                    color: AppColors.fat,
                  ),
                ],
              ),
            ),
          ),
          for (final group in [
            NutrientGroup.carbohydrates,
            NutrientGroup.lipids,
            NutrientGroup.vitamins,
            NutrientGroup.minerals,
            NutrientGroup.general,
          ])
            _groupCard(group, totals, targets),
        ],
      ),
    );
  }

  Widget _groupCard(NutrientGroup group, Map<String, double> totals,
      Map<String, double> targets) {
    final defs = Nutrients.all
        .where((d) =>
            d.group == group &&
            d.key != Nutrients.kcal &&
            d.key != Nutrients.protein &&
            d.key != Nutrients.carbs &&
            d.key != Nutrients.fat)
        .toList();
    if (defs.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Nutrients.groupName(group),
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            for (final def in defs)
              NutrientBar(
                label: def.name,
                value: totals[def.key] ?? 0,
                target: targets[def.key] ?? 0,
                unit: def.unit,
                color: Nutrients.limitNutrients.contains(def.key)
                    ? AppColors.carbs
                    : AppColors.primary,
                isLimit: Nutrients.limitNutrients.contains(def.key),
              ),
            if (group == NutrientGroup.general)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Targets are based on adult RDA/AI values and your profile. '
                  'Nutrients without data in logged foods show as 0.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
