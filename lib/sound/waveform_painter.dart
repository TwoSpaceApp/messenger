import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  WaveformPainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < samples.length; i++) {
      double x = (i / samples.length) * size.width;
      double height = samples[i] * size.height;
      canvas.drawLine(Offset(x, size.height / 2 - height / 2),
          Offset(x, size.height / 2 + height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}