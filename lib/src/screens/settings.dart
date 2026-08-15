import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/db.dart';
import '../models/profile.dart';
import '../state/app_state.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final profile = app.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _sectionTitle('Profile'),
          Card(
            child: Column(
              children: [
                _editTile(
                  context,
                  icon: Icons.person,
                  title: 'Name',
                  value: profile.name.isEmpty ? 'Not set' : profile.name,
                  onTap: () => _editText(context, app, 'Name', profile.name,
                      (v, p) => p.copyWith(name: v)),
                ),
                _pickerTile<Sex>(
                  context,
                  icon: Icons.wc,
                  title: 'Biological sex',
                  value: profile.sex == Sex.male ? 'Male' : 'Female',
                  options: const {Sex.male: 'Male', Sex.female: 'Female'},
                  current: profile.sex,
                  onPicked: (v) => app.saveProfile(profile.copyWith(sex: v)),
                ),
                _editTile(
                  context,
                  icon: Icons.cake,
                  title: 'Birth year',
                  value: '${profile.birthYear}',
                  onTap: () => _editNumber(context, app, 'Birth year',
                      profile.birthYear.toDouble(), (v, p) =>
                          p.copyWith(birthYear: v.round())),
                ),
                _editTile(
                  context,
                  icon: Icons.height,
                  title: 'Height',
                  value: '${profile.heightCm.round()} cm',
                  onTap: () => _editNumber(context, app, 'Height (cm)',
                      profile.heightCm, (v, p) => p.copyWith(heightCm: v)),
                ),
                _editTile(
                  context,
                  icon: Icons.monitor_weight,
                  title: 'Weight',
                  value: '${profile.weightKg.toStringAsFixed(1)} kg',
                  onTap: () => _editNumber(context, app, 'Weight (kg)',
                      profile.weightKg, (v, p) => p.copyWith(weightKg: v)),
                ),
                _pickerTile<ActivityLevel>(
                  context,
                  icon: Icons.directions_run,
                  title: 'Activity level',
                  value: profile.activity.label,
                  options: {
                    for (final a in ActivityLevel.values) a: a.label
                  },
                  current: profile.activity,
                  onPicked: (v) =>
                      app.saveProfile(profile.copyWith(activity: v)),
                ),
              ],
            ),
          ),
          _sectionTitle('Goals & Targets'),
          Card(
            child: Column(
              children: [
                _pickerTile<GoalType>(
                  context,
                  icon: Icons.flag,
                  title: 'Goal',
                  value: profile.goal.label,
                  options: {for (final g in GoalType.values) g: g.label},
                  current: profile.goal,
                  onPicked: (v) => app.saveProfile(profile.copyWith(goal: v)),
                ),
                if (profile.goal != GoalType.maintain)
                  _editTile(
                    context,
                    icon: Icons.speed,
                    title: 'Rate',
                    value:
                        '${profile.goalRateKgPerWeek.toStringAsFixed(1)} kg/week',
                    onTap: () => _editNumber(
                        context,
                        app,
                        'Rate (kg per week)',
                        profile.goalRateKgPerWeek,
                        (v, p) => p.copyWith(goalRateKgPerWeek: v)),
                  ),
                _editTile(
                  context,
                  icon: Icons.local_fire_department,
                  title: 'Calorie target',
                  value: profile.customKcalTarget > 0
                      ? '${profile.customKcalTarget.round()} kcal (manual)'
                      : '${profile.kcalTarget.round()} kcal (automatic)',
                  onTap: () => _editNumber(
                      context,
                      app,
                      'Calorie target (0 = automatic)',
                      profile.customKcalTarget,
                      (v, p) => p.copyWith(customKcalTarget: v)),
                ),
                _editTile(
                  context,
                  icon: Icons.water_drop,
                  title: 'Water goal',
                  value: '${profile.waterGoalMl.round()} ml',
                  onTap: () => _editNumber(context, app, 'Water goal (ml)',
                      profile.waterGoalMl, (v, p) =>
                          p.copyWith(waterGoalMl: v)),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.fitness_center),
                  title: const Text('Exercise adds to budget'),
                  subtitle: const Text(
                      'Burned calories increase your daily target',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  value: profile.includeExerciseInBudget,
                  onChanged: (v) => app.saveProfile(
                      profile.copyWith(includeExerciseInBudget: v)),
                ),
              ],
            ),
          ),
          _sectionTitle('Macro Ratios'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _MacroRatioEditor(app: app),
            ),
          ),
          _sectionTitle('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export data (JSON)'),
                  subtitle: const Text('Copies all data to your clipboard',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  onTap: () async {
                    final data = await AppDatabase.instance.exportAll();
                    await Clipboard.setData(
                        ClipboardData(text: jsonEncode(data)));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('All data copied to clipboard as JSON.')));
                    }
                  },
                ),
              ],
            ),
          ),
          _sectionTitle('About'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'CalCounter 1.0\n\n'
                'A complete nutrition tracker: calories, 35+ micronutrients, '
                'recipes, exercise, water and biometrics.\n\n'
                'Food data: built-in database + Open Food Facts (openfoodfacts.org).',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        child: Text(title,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13)),
      );

  Widget _editTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String value,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _pickerTile<T>(BuildContext context,
      {required IconData icon,
      required String title,
      required String value,
      required Map<T, String> options,
      required T current,
      required ValueChanged<T> onPicked}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
      onTap: () async {
        final picked = await showModalBottomSheet<T>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: RadioGroup<T>(
              groupValue: current,
              onChanged: (v) => Navigator.pop(sheetContext, v),
              child: ListView(
                shrinkWrap: true,
                children: options.entries
                    .map((e) => RadioListTile<T>(
                          title: Text(e.value),
                          value: e.key,
                          activeColor: AppColors.primary,
                        ))
                    .toList(),
              ),
            ),
          ),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }

  Future<void> _editText(
      BuildContext context,
      AppState app,
      String title,
      String initial,
      UserProfile Function(String, UserProfile) apply) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      await app.saveProfile(apply(result, app.profile));
    }
  }

  Future<void> _editNumber(
      BuildContext context,
      AppState app,
      String title,
      double initial,
      UserProfile Function(double, UserProfile) apply) async {
    final controller = TextEditingController(
        text: initial == initial.roundToDouble()
            ? initial.toInt().toString()
            : initial.toStringAsFixed(1));
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(
                  dialogContext, double.tryParse(controller.text)),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      await app.saveProfile(apply(result, app.profile));
    }
  }
}

class _MacroRatioEditor extends StatefulWidget {
  final AppState app;

  const _MacroRatioEditor({required this.app});

  @override
  State<_MacroRatioEditor> createState() => _MacroRatioEditorState();
}

class _MacroRatioEditorState extends State<_MacroRatioEditor> {
  late double _protein;
  late double _carbs;
  late double _fat;

  @override
  void initState() {
    super.initState();
    final p = widget.app.profile;
    _protein = p.proteinRatio;
    _carbs = p.carbsRatio;
    _fat = p.fatRatio;
  }

  void _normalizeAndSave() {
    final total = _protein + _carbs + _fat;
    if (total <= 0) return;
    _protein /= total;
    _carbs /= total;
    _fat /= total;
    widget.app.saveProfile(widget.app.profile.copyWith(
      proteinRatio: _protein,
      carbsRatio: _carbs,
      fatRatio: _fat,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.app.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Protein ${(_protein * 100).round()}% · '
          'Carbs ${(_carbs * 100).round()}% · '
          'Fat ${(_fat * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '≈ ${profile.proteinTargetG.round()}g P / ${profile.carbsTargetG.round()}g C / ${profile.fatTargetG.round()}g F per day',
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        _ratioSlider('Protein', AppColors.protein, _protein, (v) {
          _protein = v;
          _normalizeAndSave();
        }),
        _ratioSlider('Carbs', AppColors.carbs, _carbs, (v) {
          _carbs = v;
          _normalizeAndSave();
        }),
        _ratioSlider('Fat', AppColors.fat, _fat, (v) {
          _fat = v;
          _normalizeAndSave();
        }),
      ],
    );
  }

  Widget _ratioSlider(
      String label, Color color, double value, ValueChanged<double> onEnd) {
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(
            value: value.clamp(0.05, 0.9),
            min: 0.05,
            max: 0.9,
            activeColor: color,
            onChanged: (v) => setState(() {
              if (label == 'Protein') _protein = v;
              if (label == 'Carbs') _carbs = v;
              if (label == 'Fat') _fat = v;
            }),
            onChangeEnd: onEnd,
          ),
        ),
        SizedBox(
          width: 42,
          child: Text('${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
