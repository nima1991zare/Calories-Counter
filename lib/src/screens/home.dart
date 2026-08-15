import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/entries.dart';
import '../state/diary_state.dart';
import '../theme.dart';
import 'biometrics.dart';
import 'diary.dart';
import 'exercise_editor.dart';
import 'food_search.dart';
import 'foods_tab.dart';
import 'scanner.dart';
import 'settings.dart';
import 'trends.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DiaryScreen(),
      FoodsTab(),
      TrendsScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => showAddSheet(context),
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Diary'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Foods'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Trends'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}

/// Bottom sheet with quick-add actions, used from the Diary FAB.
Future<void> showAddSheet(BuildContext context, {Meal? meal}) async {
  final diary = context.read<DiaryState>();
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.restaurant, color: AppColors.primary),
            title: const Text('Add Food'),
            subtitle: const Text('Search foods, custom foods & recipes',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FoodSearchScreen(meal: meal ?? _suggestMeal()),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            title: const Text('Scan Barcode'),
            subtitle: const Text('Look up packaged foods instantly',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BarcodeScannerScreen(meal: meal ?? _suggestMeal()),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center,
                color: AppColors.exercise),
            title: const Text('Add Exercise'),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExerciseEditorScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.water_drop, color: AppColors.water),
            title: const Text('Add Water'),
            onTap: () async {
              Navigator.pop(sheetContext);
              await showWaterSheet(context, diary);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.monitor_weight, color: AppColors.carbs),
            title: const Text('Add Biometric'),
            subtitle: const Text('Weight, body fat, blood pressure...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BiometricsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

Meal _suggestMeal() {
  final hour = DateTime.now().hour;
  if (hour < 11) return Meal.breakfast;
  if (hour < 15) return Meal.lunch;
  if (hour < 21) return Meal.dinner;
  return Meal.snacks;
}

Future<void> showWaterSheet(BuildContext context, DiaryState diary) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Water',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [250.0, 350.0, 500.0, 750.0, 1000.0]
                  .map(
                    (ml) => ActionChip(
                      avatar: const Icon(Icons.water_drop,
                          size: 18, color: AppColors.water),
                      label: Text('${ml.round()} ml'),
                      backgroundColor: AppColors.surfaceLight,
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await diary.addWater(ml);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('Reset today\'s water'),
              onPressed: () async {
                Navigator.pop(sheetContext);
                await diary.resetWater();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
