import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../state/app_state.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nameController = TextEditingController();
  Sex _sex = Sex.male;
  int _birthYear = DateTime.now().year - 30;
  double _heightCm = 175;
  double _weightKg = 75;
  ActivityLevel _activity = ActivityLevel.light;
  GoalType _goal = GoalType.maintain;
  double _rate = 0.5;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  UserProfile get _draft => UserProfile(
        name: _nameController.text.trim(),
        sex: _sex,
        birthYear: _birthYear,
        heightCm: _heightCm,
        weightKg: _weightKg,
        activity: _activity,
        goal: _goal,
        goalRateKgPerWeek: _goal == GoalType.maintain ? 0 : _rate,
      );

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final appState = context.read<AppState>();
    await appState.saveProfile(_draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.local_fire_department,
                color: AppColors.primary, size: 56),
            const SizedBox(height: 8),
            const Text(
              'CalCounter',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            const Text('Track everything you eat.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _aboutYouPage(),
                  _bodyPage(),
                  _goalPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_page > 0)
                    OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_page == 2 ? 'Start Tracking' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _aboutYouPage() {
    return _sectionCard(
      title: 'About you',
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Your name (optional)'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        const Text('Biological sex',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        SegmentedButton<Sex>(
          segments: const [
            ButtonSegment(value: Sex.male, label: Text('Male')),
            ButtonSegment(value: Sex.female, label: Text('Female')),
          ],
          selected: {_sex},
          onSelectionChanged: (s) => setState(() => _sex = s.first),
        ),
        const SizedBox(height: 20),
        _sliderTile(
          label: 'Birth year',
          value: _birthYear.toDouble(),
          min: 1930,
          max: DateTime.now().year.toDouble() - 10,
          display: '$_birthYear',
          onChanged: (v) => setState(() => _birthYear = v.round()),
        ),
      ],
    );
  }

  Widget _bodyPage() {
    return _sectionCard(
      title: 'Your body',
      children: [
        _sliderTile(
          label: 'Height',
          value: _heightCm,
          min: 120,
          max: 220,
          display: '${_heightCm.round()} cm',
          onChanged: (v) => setState(() => _heightCm = v),
        ),
        _sliderTile(
          label: 'Weight',
          value: _weightKg,
          min: 30,
          max: 250,
          display: '${_weightKg.toStringAsFixed(1)} kg',
          onChanged: (v) => setState(() => _weightKg = v),
        ),
        const SizedBox(height: 12),
        const Text('Activity level',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        RadioGroup<ActivityLevel>(
          groupValue: _activity,
          onChanged: (v) => setState(() => _activity = v!),
          child: Column(
            children: ActivityLevel.values
                .map(
                  (a) => RadioListTile<ActivityLevel>(
                    title:
                        Text(a.label, style: const TextStyle(fontSize: 14.5)),
                    value: a,
                    activeColor: AppColors.primary,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _goalPage() {
    final draft = _draft;
    return _sectionCard(
      title: 'Your goal',
      children: [
        SegmentedButton<GoalType>(
          segments: const [
            ButtonSegment(value: GoalType.lose, label: Text('Lose')),
            ButtonSegment(value: GoalType.maintain, label: Text('Maintain')),
            ButtonSegment(value: GoalType.gain, label: Text('Gain')),
          ],
          selected: {_goal},
          onSelectionChanged: (s) => setState(() => _goal = s.first),
        ),
        const SizedBox(height: 16),
        if (_goal != GoalType.maintain)
          _sliderTile(
            label: _goal == GoalType.lose
                ? 'Weight loss per week'
                : 'Weight gain per week',
            value: _rate,
            min: 0.1,
            max: 1.5,
            display: '${_rate.toStringAsFixed(1)} kg/week',
            onChanged: (v) =>
                setState(() => _rate = (v * 10).round() / 10),
          ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your daily targets',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                _targetRow('Calories',
                    '${draft.kcalTarget.round()} kcal', AppColors.primary),
                _targetRow('Protein',
                    '${draft.proteinTargetG.round()} g', AppColors.protein),
                _targetRow(
                    'Carbs', '${draft.carbsTargetG.round()} g', AppColors.carbs),
                _targetRow('Fat', '${draft.fatTargetG.round()} g', AppColors.fat),
                const SizedBox(height: 8),
                Text(
                  'BMR ${draft.bmr.round()} kcal · TDEE ${draft.tdee.round()} kcal\nYou can fine-tune everything later in Settings.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _targetRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _sliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(color: AppColors.textSecondary))),
            Text(display,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
