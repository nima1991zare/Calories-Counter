import 'package:flutter/material.dart';

import '../theme.dart';

class ChartPoint {
  final DateTime date;
  final double value;

  const ChartPoint(this.date, this.value);
}

/// Simple line chart drawn with a CustomPainter (no external dependencies).
class SimpleLineChart extends StatelessWidget {
  final List<ChartPoint> points;
  final String unit;
  final double height;
  final Color color;

  const SimpleLineChart({
    super.key,
    required this.points,
    this.unit = '',
    this.height = 220,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Not enough data yet.\nLog at least two measurements.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(points: points, unit: unit, color: color),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final String unit;
  final Color color;

  _LineChartPainter({
    required this.points,
    required this.unit,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 44.0;
    const bottomPad = 26.0;
    const topPad = 12.0;
    const rightPad = 12.0;
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;

    double minV = points.first.value, maxV = points.first.value;
    for (final p in points) {
      if (p.value < minV) minV = p.value;
      if (p.value > maxV) maxV = p.value;
    }
    if (maxV - minV < 1e-9) {
      maxV += 1;
      minV -= 1;
    }
    final pad = (maxV - minV) * 0.12;
    maxV += pad;
    minV -= pad;

    final minT = points.first.date.millisecondsSinceEpoch.toDouble();
    final maxT = points.last.date.millisecondsSinceEpoch.toDouble();
    final spanT = (maxT - minT) < 1 ? 1 : (maxT - minT);

    Offset toOffset(ChartPoint p) {
      final x = leftPad +
          (p.date.millisecondsSinceEpoch - minT) / spanT * plotW;
      final y = topPad + (1 - (p.value - minV) / (maxV - minV)) * plotH;
      return Offset(x, y);
    }

    // Grid lines + y labels.
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    const labelStyle =
        TextStyle(color: AppColors.textSecondary, fontSize: 10);
    for (int i = 0; i <= 4; i++) {
      final y = topPad + plotH * i / 4;
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
      final value = maxV - (maxV - minV) * i / 4;
      final tp = TextPainter(
        text: TextSpan(text: _fmt(value), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    // X labels: first, middle, last date.
    for (final p in [
      points.first,
      points[points.length ~/ 2],
      points.last
    ]) {
      final o = toOffset(p);
      final tp = TextPainter(
        text: TextSpan(
            text: '${p.date.month}/${p.date.day}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx =
          (o.dx - tp.width / 2).clamp(leftPad, size.width - tp.width);
      tp.paint(canvas, Offset(dx, size.height - bottomPad + 6));
    }

    // Area fill.
    final linePath = Path();
    final areaPath = Path();
    for (int i = 0; i < points.length; i++) {
      final o = toOffset(points[i]);
      if (i == 0) {
        linePath.moveTo(o.dx, o.dy);
        areaPath.moveTo(o.dx, topPad + plotH);
        areaPath.lineTo(o.dx, o.dy);
      } else {
        linePath.lineTo(o.dx, o.dy);
        areaPath.lineTo(o.dx, o.dy);
      }
    }
    areaPath.lineTo(toOffset(points.last).dx, topPad + plotH);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0.02)],
        ).createShader(
            Rect.fromLTWH(leftPad, topPad, plotW, plotH)),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots.
    final dotPaint = Paint()..color = color;
    final dotInner = Paint()..color = AppColors.background;
    for (final p in points) {
      final o = toOffset(p);
      canvas.drawCircle(o, 4, dotPaint);
      canvas.drawCircle(o, 2, dotInner);
    }
  }

  String _fmt(double v) {
    if (v.abs() >= 100) return v.round().toString();
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

/// Bar chart for daily calorie history.
class SimpleBarChart extends StatelessWidget {
  final List<ChartPoint> points;
  final double target;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.points,
    this.target = 0,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No data yet. Start logging foods!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(points: points, target: target),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final double target;

  _BarChartPainter({required this.points, required this.target});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 44.0;
    const bottomPad = 26.0;
    const topPad = 12.0;
    const rightPad = 12.0;
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;

    double maxV = target;
    for (final p in points) {
      if (p.value > maxV) maxV = p.value;
    }
    if (maxV <= 0) maxV = 100;
    maxV *= 1.1;

    const labelStyle =
        TextStyle(color: AppColors.textSecondary, fontSize: 10);
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = topPad + plotH * i / 4;
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
      final value = maxV - maxV * i / 4;
      final tp = TextPainter(
        text: TextSpan(text: value.round().toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    final barW = (plotW / points.length) * 0.62;
    final gap = plotW / points.length;
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final h = (p.value / maxV) * plotH;
      final x = leftPad + gap * i + (gap - barW) / 2;
      final overTarget = target > 0 && p.value > target;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, topPad + plotH - h, barW, h),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = overTarget ? AppColors.danger : AppColors.primary,
      );
    }

    // Target line.
    if (target > 0 && target < maxV) {
      final y = topPad + (1 - target / maxV) * plotH;
      final dashPaint = Paint()
        ..color = AppColors.textSecondary
        ..strokeWidth = 1.5;
      double x = leftPad;
      while (x < size.width - rightPad) {
        canvas.drawLine(Offset(x, y), Offset(x + 6, y), dashPaint);
        x += 12;
      }
    }

    // X labels: first & last dates.
    for (final entry in [
      (0, points.first),
      (points.length - 1, points.last)
    ]) {
      final i = entry.$1;
      final p = entry.$2;
      final x = leftPad + gap * i + gap / 2;
      final tp = TextPainter(
        text: TextSpan(
            text: '${p.date.month}/${p.date.day}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = (x - tp.width / 2).clamp(leftPad, size.width - tp.width);
      tp.paint(canvas, Offset(dx, size.height - bottomPad + 6));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.target != target;
}
