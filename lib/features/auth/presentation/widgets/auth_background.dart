import 'dart:math';

import 'package:flutter/material.dart';

/// Full-screen auth scaffold with an animated brand gradient background
/// and a centered MD3 glass-card container for the form.
///
/// The "covering" animation (slide + fade) is used during screen transitions
/// between login ↔ register.
class AuthBackground extends StatefulWidget {
  const AuthBackground({
    required this.child,
    required this.title,
    super.key,
    this.isCovering = false,
    this.swapBlobs = false,
    this.seed = 0,
  });

  final Widget child;
  final String title;
  final bool isCovering;
  final bool swapBlobs;
  final int seed;

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientCtrl;
  late AnimationController _coverCtrl;
  late Animation<double> _coverAnim;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();

    _coverCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _coverAnim = CurvedAnimation(
      parent: _coverCtrl,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isCovering) _coverCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(AuthBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCovering != oldWidget.isCovering) {
      if (widget.isCovering) {
        _coverCtrl.forward(from: 0);
      } else {
        _coverCtrl.reverse(from: 1);
      }
    }
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _coverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Brand gradient ──────────────────────────────────────────────
          _Gradient(isDark: isDark, animation: _gradientCtrl),

          // ── Orbital blobs ───────────────────────────────────────────────
          _Blobs(
            coverAnim: _coverAnim,
            gradientCtrl: _gradientCtrl,
            swapBlobs: widget.swapBlobs,
            primary: cs.primary,
            tertiary: cs.tertiary,
          ),

          // ── Card content ────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: AnimatedBuilder(
                    animation: _coverAnim,
                    builder: (context, child) {
                      final t = _coverAnim.value;
                      return Opacity(
                        opacity: (1.0 - t).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, t * 24),
                          child: child,
                        ),
                      );
                    },
                    child: _AuthCard(
                      cs: cs,
                      isDark: isDark,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────── Internal building-blocks ────────────────────────────────────────────

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.cs,
    required this.isDark,
    required this.child,
  });
  final ColorScheme cs;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        // MD3 tonal surface with slight transparency
        color: cs.surface.withValues(alpha: isDark ? 0.72 : 0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Gradient extends StatelessWidget {
  const _Gradient({required this.isDark, required this.animation});
  final bool isDark;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final hue = 250.0 + sin(t * 2 * pi) * 15;
        final hue2 = 270.0 + cos(t * 2 * pi) * 15;
        final c1 = HSVColor.fromAHSV(
          1,
          hue,
          isDark ? 0.75 : 0.22,
          isDark ? 0.15 : 0.93,
        ).toColor();
        final c2 = HSVColor.fromAHSV(
          1,
          hue2,
          isDark ? 0.65 : 0.18,
          isDark ? 0.1 : 0.97,
        ).toColor();
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c1, c2],
            ),
          ),
        );
      },
    );
  }
}

class _Blobs extends StatelessWidget {
  const _Blobs({
    required this.coverAnim,
    required this.gradientCtrl,
    required this.swapBlobs,
    required this.primary,
    required this.tertiary,
  });
  final Animation<double> coverAnim;
  final AnimationController gradientCtrl;
  final bool swapBlobs;
  final Color primary;
  final Color tertiary;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([coverAnim, gradientCtrl]),
        builder: (context, _) {
          final coverT = coverAnim.value;
          final b1Start = swapBlobs
              ? const Alignment(0.6, -0.7)
              : const Alignment(-0.6, 0.65);
          final b2Start = swapBlobs
              ? const Alignment(-0.6, 0.65)
              : const Alignment(0.6, -0.7);
          final p1 = Alignment.lerp(
            b1Start,
            const Alignment(-0.15, 0.05),
            coverT,
          )!;
          final p2 = Alignment.lerp(
            b2Start,
            const Alignment(0.15, -0.05),
            coverT,
          )!;
          final scale = 1.0 + coverT * 0.55;
          final gt = gradientCtrl.value;
          final c1 = primary.withValues(alpha: 0.25 + sin(gt * 2 * pi) * 0.06);
          final c2 = tertiary.withValues(alpha: 0.22 + cos(gt * 2 * pi) * 0.06);
          return Stack(
            children: [
              Align(
                alignment: p1,
                child: Transform.scale(
                  scale: scale,
                  child: _Blob(size: 310, color: c1),
                ),
              ),
              Align(
                alignment: p2,
                child: Transform.scale(
                  scale: scale * 1.12,
                  child: _Blob(size: 270, color: c2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 80,
            spreadRadius: -8,
          ),
        ],
      ),
    );
  }
}
