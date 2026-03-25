import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  WaveformPainter(
    this.samples, {
    required this.baseColor,
    required this.playedColor,
    required this.progress,
    required this.pulsePhase,
    required this.isPlaying,
    this.strokeWidth = 2.0,
  });
  final List<double> samples;
  final Color baseColor;
  final Color playedColor;
  final double progress;
  final double pulsePhase;
  final bool isPlaying;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) {
      return;
    }

    final safeProgress = progress.clamp(0.0, 1.0);
    final backgroundPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    final barPaint = Paint()..style = PaintingStyle.fill;
    final headPaint = Paint()
      ..color = playedColor.withValues(alpha: isPlaying ? 0.95 : 0.8)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = playedColor.withValues(alpha: isPlaying ? 0.22 : 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final centerY = size.height / 2;
    final spacing = math.max(1.5, strokeWidth * 0.75);
    final barWidth = math.max(2.2, (size.width - spacing * (samples.length - 1)) / samples.length);
    final availableHeight = size.height - 4;
    final pulse = 0.5 + 0.5 * math.sin(pulsePhase * math.pi * 2);

    final backgroundRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    canvas.drawRRect(
      backgroundRRect,
      Paint()..color = Colors.transparent,
    );

    for (var i = 0; i < samples.length; i++) {
      final normalized = samples[i].clamp(0.06, 1.0);
      final barCenter = samples.length == 1 ? 0.5 : i / (samples.length - 1);
      final distanceToHead = (barCenter - safeProgress).abs();
      final activeBoost = isPlaying
          ? math.max(0, 1 - (distanceToHead / 0.09)) * (0.1 + pulse * 0.18)
          : 0;
      final visualLevel = (normalized + activeBoost).clamp(0.10, 1.0);
      final barHeight = math.max(4, availableHeight * visualLevel).toDouble();
      final left = i * (barWidth + spacing);
      final top = centerY - (barHeight / 2);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        Radius.circular(barWidth),
      );

        final isPlayed = barCenter <= safeProgress;
        final color = isPlayed
          ? Color.lerp(playedColor, Colors.white, math.max(0, 0.22 - distanceToHead))!
          : Color.lerp(baseColor, playedColor, math.max(0, 0.1 - distanceToHead) * 1.5)!;
      barPaint.color = color;
      canvas.drawRRect(rect, backgroundPaint..color = baseColor.withValues(alpha: 0.26));
      canvas.drawRRect(rect, barPaint);
    }

    final headX = safeProgress * size.width;
    if (headX > 0 && headX < size.width) {
      canvas.drawCircle(Offset(headX, centerY), size.height * 0.18, glowPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(headX, centerY), width: 3, height: size.height - 6),
          const Radius.circular(999),
        ),
        headPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
