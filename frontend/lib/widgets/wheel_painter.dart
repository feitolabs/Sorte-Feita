import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../../models/wheel_model.dart';

class WheelPainter extends CustomPainter {
  final List<WheelOption> options;
  final bool differentWeights;
  final double rotationAngle; // Current rotation in radians

  WheelPainter({
    required this.options,
    required this.differentWeights,
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final totalWeight = options.fold<double>(
      0.0,
      (sum, opt) => sum + (differentWeights ? opt.weight : 1.0),
    );

    if (totalWeight <= 0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    double currentAngle = 0.0;

    // Outer border
    final borderPaint = Paint()
      ..color = AppColors.nevoa
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (int i = 0; i < options.length; i++) {
      final opt = options[i];
      final weight = differentWeights ? opt.weight : 1.0;
      final sweepAngle = (weight / totalWeight) * 2 * pi;

      // Slice background
      final slicePaint = Paint()
        ..color = opt.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        slicePaint,
      );

      // Slice separator line
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final edgeX = center.dx + radius * cos(currentAngle);
      final edgeY = center.dy + radius * sin(currentAngle);
      canvas.drawLine(center, Offset(edgeX, edgeY), linePaint);

      // Text label inside slice
      final midAngle = currentAngle + sweepAngle / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(midAngle);

      final textSpan = TextSpan(
        text: opt.label,
        style: TextStyle(
          color: _isDarkColor(opt.color) ? Colors.white : AppColors.petroleo,
          fontSize: options.length > 8 ? 13 : 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'Bricolage Grotesque',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: radius * 0.65);

      textPainter.paint(canvas, Offset(radius * 0.28, -textPainter.height / 2));
      canvas.restore();

      currentAngle += sweepAngle;
    }

    // Draw outer circle border
    canvas.drawCircle(center, radius, borderPaint);

    // Center Hub (concentric circles like in prototype)
    final hubRadius = radius * 0.22;
    final hubOuterPaint = Paint()
      ..color = AppColors.areia
      ..style = PaintingStyle.fill;
    final hubBorderPaint = Paint()
      ..color = AppColors.petroleo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    final hubCenterPaint = Paint()
      ..color = AppColors.petroleo
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, hubRadius, hubOuterPaint);
    canvas.drawCircle(center, hubRadius, hubBorderPaint);
    canvas.drawCircle(center, hubRadius * 0.35, hubCenterPaint);

    canvas.restore();
  }

  bool _isDarkColor(Color c) {
    return (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) < 140;
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.options != options ||
        oldDelegate.differentWeights != differentWeights;
  }
}

