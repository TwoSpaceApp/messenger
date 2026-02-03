import 'package:flutter/material.dart';
import 'dart:math';

class ScreenBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const ScreenBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<ScreenBackground> createState() => _ScreenBackgroundState();
}

class _ScreenBackgroundState extends State<ScreenBackground> with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
       duration: const Duration(seconds: 20),
       vsync: this,
    );
    if (widget.animate) {
      _gradientController.repeat();
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Static Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0B0320),
                      const Color(0xFF150A25),
                      const Color(0xFF000000),
                    ]
                  : [
                      const Color(0xFFE0C3FC),
                      const Color(0xFFF7F4FF),
                    ],
            ),
          ),
        ),
        
        // Blobs
        if (widget.animate)
        Stack(
          children: [
            Align(
              alignment: const Alignment(-0.8, -0.6),
              child: _buildBlob(300, 0, isDark),
            ),
            Align(
              alignment: const Alignment(0.8, 0.4),
              child: _buildBlob(260, 0.5, isDark),
            ),
          ],
        ),

        // Content
        widget.child,
      ],
    );
  }

  Widget _buildBlob(double size, double phaseOffset, bool isDark) {
     return AnimatedBuilder(
       animation: _gradientController,
       builder: (context, child) {
         final t = (_gradientController.value + phaseOffset) % 1.0;
         
         final hue1 = 260.0 + sin(t * 2 * pi) * 20; 
         final hue2 = 280.0 + cos(t * 2 * pi) * 20; 

         final c1 = HSVColor.fromAHSV(0.15, hue1, 0.6, 0.9).toColor();
         final c2 = HSVColor.fromAHSV(0.15, hue2, 0.6, 0.9).toColor();

         return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c1, c2], 
            ),
            boxShadow: [
              BoxShadow(
                color: c1.withValues(alpha: 0.1), 
                blurRadius: 80, 
                spreadRadius: 20, 
              ),
            ],
          ),
        );
       },
     );
  }
}
