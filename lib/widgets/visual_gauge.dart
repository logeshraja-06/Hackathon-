import 'dart:math';
import 'package:flutter/material.dart';

class VisualGauge extends StatelessWidget {
  final String label;
  final double value;
  final double minVal;
  final double maxVal;
  final double optimalMin;
  final double optimalMax;

  const VisualGauge({
    Key? key,
    required this.label,
    required this.value,
    this.minVal = 0,
    this.maxVal = 100,
    required this.optimalMin,
    required this.optimalMax,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 50,
          child: CustomPaint(
            painter: _GaugePainter(
              value: value,
              minVal: minVal,
              maxVal: maxVal,
              optimalMin: optimalMin,
              optimalMax: optimalMax,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 14, color: Color(0xFF2E7D32))),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double minVal;
  final double maxVal;
  final double optimalMin;
  final double optimalMax;

  _GaugePainter({
    required this.value,
    required this.minVal,
    required this.maxVal,
    required this.optimalMin,
    required this.optimalMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Background track (Gray/Red/Green zones can be complex, simplifying to gray for MVP)
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Draw semi-circle track
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    // Determine color based on optimal range
    Color valueColor = Colors.orange; // Default warning
    if (value >= optimalMin && value <= optimalMax) {
      valueColor = Colors.green; // Good
    } else if (value < optimalMin) {
      valueColor = Colors.redAccent; // Too low
    } else if (value > optimalMax) {
      valueColor = Colors.blueAccent; // Too high
    }

    // Value Arc
    final valPaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    double normalizedValue = (value - minVal) / (maxVal - minVal);
    normalizedValue = normalizedValue.clamp(0.0, 1.0);
    double sweepAngle = normalizedValue * pi;

    canvas.drawArc(rect, pi, sweepAngle, false, valPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
