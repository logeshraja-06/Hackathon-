import 'dart:math';
import 'package:flutter/material.dart';

class TrendSparkline extends StatelessWidget {
  final List<double> data;
  final Color lineColor;

  const TrendSparkline({
    Key? key,
    required this.data,
    this.lineColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    return CustomPaint(
      painter: _SparklinePainter(data: data, lineColor: lineColor),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _SparklinePainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final double minVal = data.reduce(min);
    final double maxVal = data.reduce(max);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final double dx = size.width / (data.length - 1);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final double normalizedY = (data[i] - minVal) / range;
      final double x = i * dx;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
