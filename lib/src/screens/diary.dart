import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/entries.dart';
import '../models/nutrients.dart';
import '../state/app_state.dart';
import '../state/diary_state.dart';
import '../theme.dart';
import '../widgets/rings.dart';
import 'exercise_editor.dart';
import 'food_detail.dart';
import 'food_search.dart';
import 'home.dart';
import 'nutrition_report.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diary = context.watch<DiaryState>();
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: AppColors.primary, size: 26),
            const SizedBox(width: 8),
            Text(app.profile.name.isEmpty
                ? 'Diary'
                : '${app.profile.name}\'s Diary'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Nutrition report',
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NutritionReportScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: diary.refresh,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _DateNavigator(diary: diary),
            _SummaryCard(diary: diary, app: app),
            _WaterCard(diary: diary, app: app),
            for (final meal in Meal.values) _MealCard(diary: diary, meal: meal),
            _ExerciseCard(diary: diary),
          ],
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  final DiaryState diary;

  const _DateNavigator({required this.diary});

  @override
  Widget build(BuildContext context) {
    final label = diary.isToday
        ? 'Today'
        : DateFormat('EEE, MMM d').format(diary.date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () => diary.shiftDate(-1),
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: diary.date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) await diary.setDate(picked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 30),
            onPressed: () => diary.shiftDate(1),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DiaryState diary;
  final AppState app;

  const _SummaryCard({required this.diary, required this.app});

  @override
  Widget build(BuildContext context) {
    final profile = app.profile;
    final burned = profile.includeExerciseInBudget ? diary.kcalBurned : 0.0;
    final target = profile.kcalTarget + burned;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CalorieRing(
                  consumed: diary.kcalConsumed,
                  target: target,
                  burned: diary.kcalBurned,
                  size: 150,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statRow(Icons.flag_outlined, 'Budget',
                          '${target.round()} kcal'),
                      const SizedBox(height: 10),
                      _statRow(Icons.restaurant, 'Food',
                          '${diary.kcalConsumed.round()} kcal'),
                      const SizedBox(height: 10),
                      _statRow(Icons.fitness_center, 'Exercise',
                          '${diary.kcalBurned.round()} kcal'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            NutrientBar(
              label: 'Protein',
              value: diary.proteinConsumed,
              target: profile.proteinTargetG,
              unit: 'g',
              color: AppColors.protein,
            ),
            NutrientBar(
              label: 'Carbs',
              value: diary.carbsConsumed,
              target: profile.carbsTargetG,
              unit: 'g',
              color: AppColors.carbs,
            ),
            NutrientBar(
              label: 'Fat',
              value: diary.fatConsumed,
              target: profile.fatTargetG,
              unit: 'g',
              color: AppColors.fat,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.assessment_outlined, size: 18),
                label: const Text('Full Nutrition Report'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NutritionReportScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _WaterCard extends StatelessWidget {
  final DiaryState diary;
  final AppState app;

  const _WaterCard({required this.diary, required this.app});

  @override
  Widget build(BuildContext context) {
    final goal = app.profile.waterGoalMl;
    final pct = goal <= 0 ? 0.0 : (diary.waterMl / goal).clamp(0.0, 1.0);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showWaterSheet(context, diary),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.water_drop, color: AppColors.water, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                            child: Text('Water',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700))),
                        Text(
                          '${diary.waterMl.round()} / ${goal.round()} ml',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.water),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.add_circle_outline, color: AppColors.water),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final DiaryState diary;
  final Meal meal;

  const _MealCard({required this.diary, required this.meal});

  @override
  Widget build(BuildContext context) {
    final items = diary.entriesForMeal(meal);
    final kcal = diary.mealKcal(meal);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(meal.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15.5)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kcal > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text('${kcal.round()} kcal',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.primary, size: 26),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FoodSearchScreen(meal: meal)),
                  ),
                ),
              ],
            ),
          ),
          if (items.isNotEmpty) const Divider(height: 1),
          for (final logged in items)
            Dismissible(
              key: ValueKey('entry-${logged.entry.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: AppColors.danger,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => diary.removeEntry(logged.entry.id!),
              child: ListTile(
                dense: true,
                title: Text(logged.food.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  [
                    logged.amountLabel,
                    if (logged.food.brand.isNotEmpty) logged.food.brand,
                    'P ${logged.nutrient(Nutrients.protein).round()} · '
                        'C ${logged.nutrient(Nutrients.carbs).round()} · '
                        'F ${logged.nutrient(Nutrients.fat).round()}',
                  ].join('  ·  '),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                    '${logged.nutrient(Nutrients.kcal).round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodDetailScreen(
                      food: logged.food,
                      meal: logged.entry.meal,
                      existingEntry: logged.entry,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final DiaryState diary;

  const _ExerciseCard({required this.diary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Exercise',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (diary.kcalBurned > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text('-${diary.kcalBurned.round()} kcal',
                        style: const TextStyle(
                            color: AppColors.exercise,
                            fontWeight: FontWeight.w700)),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.exercise, size: 26),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ExerciseEditorScreen()),
                  ),
                ),
              ],
            ),
          ),
          if (diary.exercises.isNotEmpty) const Divider(height: 1),
          for (final e in diary.exercises)
            Dismissible(
              key: ValueKey('exercise-${e.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: AppColors.danger,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => diary.removeExercise(e.id!),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.fitness_center,
                    color: AppColors.exercise, size: 20),
                title: Text(e.name),
                subtitle: Text('${e.minutes.round()} min',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11.5)),
                trailing: Text('-${e.kcal.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
