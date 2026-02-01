import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularTimePainter extends CustomPainter {
  CircularTimePainter({
    /**
     * How much time has already passed
     */
    required this.progress,
    /**
     * Color of the ring
     */
    required this.backgroundColor,
    /**
     * Color of the progress bar
     */
    required this.progressColor,
    /**
     * Indicates if time animation is upwards or downwards
     */
    this.isReversed = false,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final bool isReversed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const double strokeWidth = 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw from top and counter-clockwise
    final sweepAngle = (isReversed ? 2 : -2) * math.pi * progress;
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
