import 'package:flutter/material.dart';
import 'dart:math';

class AuthBackground extends StatefulWidget {
  final Widget child;
  final String title;
  final bool isCovering; // State to trigger "cover" animation
  final int seed; 

  const AuthBackground({
    super.key,
    required this.child,
    required this.title,
    this.isCovering = false,
    this.seed = 0,
  });

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _coverController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
       duration: const Duration(seconds: 20),
       vsync: this,
    )..repeat();

    _coverController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    if (widget.isCovering) {
      _coverController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AuthBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCovering != oldWidget.isCovering) {
      if (widget.isCovering) {
        _coverController.forward(from: 0.0);
      } else {
        _coverController.reverse(from: 1.0);
      }
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
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
                        const Color(0xFF2B1055),
                        const Color(0xFF000000),
                      ]
                    : [
                        const Color(0xFFE0C3FC),
                        const Color(0xFF8EC5FC),
                        const Color(0xFFF7F4FF),
                      ],
              ),
            ),
          ),
          
          // Animated Blobs (Only move when covering)
          AnimatedBuilder(
            animation: _coverController,
            builder: (context, _) {
              final coverT = Curves.easeInOutCubic.transform(_coverController.value);

              // Static starting positions
              final b1Start = const Alignment(-0.6, 0.6);
              final b2Start = const Alignment(0.6, -0.6);

              // Target positions (center)
              final b1End = const Alignment(-0.2, 0);
              final b2End = const Alignment(0.2, 0);

              final p1 = Alignment.lerp(b1Start, b1End, coverT)!;
              final p2 = Alignment.lerp(b2Start, b2End, coverT)!;

              final scale = 1.0 + (coverT * 0.5);

              return Stack(
                children: [
                  Align(
                    alignment: p1,
                    child: Transform.scale(
                      scale: scale,
                      child: _buildBlob(300, 0, isDark),
                    ),
                  ),
                  Align(
                    alignment: p2,
                    child: Transform.scale(
                      scale: scale * 1.1,
                      child: _buildBlob(260, 0.5, isDark),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: widget.isCovering ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.6), 
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, double phaseOffset, bool isDark) {
     return AnimatedBuilder(
       animation: _gradientController,
       builder: (context, child) {
         final t = (_gradientController.value + phaseOffset) % 1.0;
         
         final hue1 = 260.0 + sin(t * 2 * pi) * 20; 
         final hue2 = 280.0 + cos(t * 2 * pi) * 20; 

         final c1 = HSVColor.fromAHSV(0.3, hue1, 0.6, 0.9).toColor();
         final c2 = HSVColor.fromAHSV(0.3, hue2, 0.6, 0.9).toColor();

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
                color: c1.withOpacity(0.2), 
                blurRadius: 60, 
                spreadRadius: -10, 
              ),
            ],
          ),
        );
       },
     );
  }
}
