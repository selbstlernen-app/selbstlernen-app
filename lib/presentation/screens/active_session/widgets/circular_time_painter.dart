import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularTimePainter extends CustomPainter {
  CircularTimePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;
    final double strokeWidth = 12.0;

    // Background circle
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw from top, counter-clockwise
    final double sweepAngle = -2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularTimePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
