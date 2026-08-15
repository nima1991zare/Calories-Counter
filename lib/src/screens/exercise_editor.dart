import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/entries.dart';
import '../state/app_state.dart';
import '../state/diary_state.dart';
import '../theme.dart';

class _Activity {
  final String name;
  final double met;
  final IconData icon;

  const _Activity(this.name, this.met, this.icon);
}

const List<_Activity> _activities = [
  _Activity('Walking (moderate)', 3.5, Icons.directions_walk),
  _Activity('Walking (brisk)', 4.5, Icons.directions_walk),
  _Activity('Running (8 km/h)', 8.0, Icons.directions_run),
  _Activity('Running (11 km/h)', 11.0, Icons.directions_run),
  _Activity('Cycling (moderate)', 7.5, Icons.directions_bike),
  _Activity('Swimming', 8.0, Icons.pool),
  _Activity('Weight training', 3.5, Icons.fitness_center),
  _Activity('HIIT / Circuit', 8.0, Icons.timer),
  _Activity('Yoga', 2.5, Icons.self_improvement),
  _Activity('Hiking', 6.0, Icons.terrain),
  _Activity('Dancing', 5.5, Icons.music_note),
  _Activity('Basketball', 6.5, Icons.sports_basketball),
  _Activity('Soccer', 7.0, Icons.sports_soccer),
  _Activity('Tennis', 7.3, Icons.sports_tennis),
  _Activity('Rowing', 7.0, Icons.rowing),
  _Activity('Elliptical', 5.0, Icons.fitness_center),
  _Activity('Jump rope', 11.0, Icons.timer),
  _Activity('Pilates', 3.0, Icons.self_improvement),
  _Activity('Housework', 3.3, Icons.cleaning_services),
  _Activity('Gardening', 3.8, Icons.yard),
];

/// Log an exercise; calories are estimated from METs and body weight,
/// or entered manually.
class ExerciseEditorScreen extends StatefulWidget {
  const ExerciseEditorScreen({super.key});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  _Activity? _selected;
  final _minutesController = TextEditingController(text: '30');
  final _kcalController = TextEditingController();
  final _nameController = TextEditingController();
  bool _manual = false;

  @override
  void dispose() {
    _minutesController.dispose();
    _kcalController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  double get _minutes => double.tryParse(_minutesController.text) ?? 0;

  double _estimatedKcal(double weightKg) {
    if (_selected == null) return 0;
    // kcal = MET * 3.5 * kg / 200 * minutes
    return _selected!.met * 3.5 * weightKg / 200 * _minutes;
  }

  Future<void> _save() async {
    final diary = context.read<DiaryState>();
    final app = context.read<AppState>();

    if (_manual) {
      final kcal = double.tryParse(_kcalController.text) ?? 0;
      final name = _nameController.text.trim();
      if (kcal <= 0 || name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Enter an exercise name and calories burned.')));
        return;
      }
      await diary.addExercise(ExerciseEntry(
        date: diary.dateStr,
        name: name,
        minutes: _minutes,
        kcal: kcal,
      ));
    } else {
      if (_selected == null || _minutes <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Pick an activity and duration.')));
        return;
      }
      await diary.addExercise(ExerciseEntry(
        date: diary.dateStr,
        name: _selected!.name,
        minutes: _minutes,
        kcal: _estimatedKcal(app.profile.weightKg),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final estimate = _estimatedKcal(app.profile.weightKg);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Pick activity')),
              ButtonSegment(value: true, label: Text('Manual entry')),
            ],
            selected: {_manual},
            onSelectionChanged: (s) => setState(() => _manual = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
          ),
          const SizedBox(height: 16),
          if (_manual) ...[
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(labelText: 'Exercise name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kcalController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Calories burned (kcal)'),
            ),
          ] else ...[
            if (_selected != null)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(_selected!.icon, color: AppColors.exercise),
                  title: Text(_selected!.name),
                  trailing: Text(
                    '~${estimate.round()} kcal',
                    style: const TextStyle(
                        color: AppColors.exercise,
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activities
                  .map(
                    (a) => ChoiceChip(
                      avatar: Icon(a.icon,
                          size: 16,
                          color: _selected == a
                              ? Colors.black
                              : AppColors.textSecondary),
                      label: Text(a.name, style: const TextStyle(fontSize: 12)),
                      selected: _selected == a,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                          color: _selected == a
                              ? Colors.black
                              : AppColors.textPrimary),
                      onSelected: (_) => setState(() => _selected = a),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save Exercise')),
        ],
      ),
    );
  }
}
