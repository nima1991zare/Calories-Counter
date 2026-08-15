import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Circular progress ring showing consumed vs target calories.
class CalorieRing extends StatelessWidget {
  final double consumed;
  final double target;
  final double burned;
  final double size;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.target,
    this.burned = 0,
    this.size = 168,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = target - consumed;
    final over = remaining < 0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: target <= 0 ? 0 : (consumed / target).clamp(0.0, 1.0),
              over: over,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remaining.abs().round().toString(),
                style: TextStyle(
                  fontSize: size * 0.19,
                  fontWeight: FontWeight.w800,
                  color: over ? AppColors.danger : AppColors.primary,
                ),
              ),
              Text(
                over ? 'kcal over' : 'kcal left',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool over;

  _RingPainter({required this.progress, required this.over});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 12.0;

    final bg = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    if (progress > 0) {
      final fg = Paint()
        ..color = over ? AppColors.danger : AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fg,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.over != over;
}

/// Horizontal progress bar with a label, used for macros and nutrients.
class NutrientBar extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;
  final bool isLimit;

  const NutrientBar({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    this.color = AppColors.primary,
    this.isLimit = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    final overLimit = isLimit && target > 0 && value > target;
    final barColor = overLimit ? AppColors.danger : color;
    final pctLabel = target <= 0 ? '' : '${(value / target * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textPrimary)),
              ),
              Text(
                '${_fmt(value)} / ${_fmt(target)} $unit',
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  pctLabel,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: overLimit ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v >= 100) return v.round().toString();
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
