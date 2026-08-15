import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/db.dart';
import '../models/entries.dart';
import '../state/app_state.dart';
import '../state/diary_state.dart';
import '../theme.dart';
import '../widgets/charts.dart';

/// Log and review biometric measurements (weight, body fat, etc.).
class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key});

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  final _db = AppDatabase.instance;
  BiometricType _type = BiometricType.all.first;
  List<BiometricEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _db.biometricHistory(_type.key);
    if (mounted) setState(() => _history = history);
  }

  Future<void> _addMeasurement() async {
    final controller = TextEditingController();
    final diary = context.read<DiaryState>();
    final app = context.read<AppState>();

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add ${_type.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: '${_type.name} (${_type.unit})'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, double.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value <= 0) return;

    await diary.addBiometric(_type.key, value);
    // Keep profile weight in sync so calorie targets stay accurate.
    if (_type.key == 'weight') {
      await app.saveProfile(app.profile.copyWith(weightKg: value));
    }
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final points = _history
        .map((e) => ChartPoint(DateTime.parse(e.date), e.value))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Biometrics')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'biometrics-fab',
        onPressed: _addMeasurement,
        icon: const Icon(Icons.add),
        label: Text('Add ${_type.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<BiometricType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Measurement'),
              dropdownColor: AppColors.surfaceLight,
              items: BiometricType.all
                  .map((t) => DropdownMenuItem(
                      value: t, child: Text('${t.name} (${t.unit})')))
                  .toList(),
              onChanged: (t) {
                setState(() => _type = t!);
                _loadHistory();
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_type.name} history',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  SimpleLineChart(points: points, unit: _type.unit),
                ],
              ),
            ),
          ),
          for (final e in _history.reversed)
            ListTile(
              dense: true,
              leading: const Icon(Icons.monitor_weight_outlined,
                  size: 20, color: AppColors.textSecondary),
              title: Text('${e.value} ${_type.unit}'),
              subtitle: Text(
                  DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(e.date)),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.danger),
                onPressed: () async {
                  await _db.deleteBiometric(e.id!);
                  _loadHistory();
                },
              ),
            ),
        ],
      ),
    );
  }
}
