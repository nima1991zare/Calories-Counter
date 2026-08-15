import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/db.dart';
import '../models/entries.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import 'biometrics.dart';

/// Charts for calories over time and biometric trends.
class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final _db = AppDatabase.instance;
  int _days = 14;
  Map<String, double> _kcalByDate = {};
  List<BiometricEntry> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final kcal = await _db.kcalByDate(_days);
    final weight = await _db.biometricHistory('weight');
    if (!mounted) return;
    setState(() {
      _kcalByDate = kcal;
      _weightHistory = weight;
    });
  }

  List<ChartPoint> get _kcalPoints {
    final points = <ChartPoint>[];
    final now = DateTime.now();
    for (int i = _days - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      points.add(ChartPoint(d, _kcalByDate[key] ?? 0));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final weightPoints = _weightHistory
        .map((e) => ChartPoint(DateTime.parse(e.date), e.value))
        .toList();

    final kcalValues =
        _kcalPoints.where((p) => p.value > 0).map((p) => p.value).toList();
    final avgKcal = kcalValues.isEmpty
        ? 0.0
        : kcalValues.reduce((a, b) => a + b) / kcalValues.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: RefreshIndicator(
        onRefresh: _reload,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Calories consumed',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        SegmentedButton<int>(
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                          segments: const [
                            ButtonSegment(value: 7, label: Text('7d')),
                            ButtonSegment(value: 14, label: Text('14d')),
                            ButtonSegment(value: 30, label: Text('30d')),
                          ],
                          selected: {_days},
                          onSelectionChanged: (s) {
                            setState(() => _days = s.first);
                            _reload();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SimpleBarChart(
                      points: _kcalPoints,
                      target: app.profile.kcalTarget,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Average on logged days: ${avgKcal.round()} kcal · '
                      'Target: ${app.profile.kcalTarget.round()} kcal',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Weight',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Log'),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BiometricsScreen()),
                            );
                            _reload();
                          },
                        ),
                      ],
                    ),
                    SimpleLineChart(points: weightPoints, unit: 'kg'),
                    if (weightPoints.length >= 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _weightSummary(weightPoints),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.5),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.monitor_heart, color: AppColors.primary),
                title: const Text('All biometrics'),
                subtitle: const Text(
                    'Body fat, blood pressure, sleep and more',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BiometricsScreen()),
                  );
                  _reload();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weightSummary(List<ChartPoint> points) {
    final delta = points.last.value - points.first.value;
    final sign = delta >= 0 ? '+' : '';
    return 'Latest: ${points.last.value.toStringAsFixed(1)} kg · '
        'Change: $sign${delta.toStringAsFixed(1)} kg over ${points.length} entries';
  }
}
