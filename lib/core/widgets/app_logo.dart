import 'package:flutter/material.dart';
import 'package:two_space_app/core/widgets/gradient_text.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({super.key, this.large = true});
  final bool large;

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.large ? 40.0 : 24.0;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final startA = isDark
            ? colorScheme.primary
            : Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.25)!;
        final endA = isDark
            ? colorScheme.tertiary
            : Color.lerp(colorScheme.secondary, colorScheme.primary, 0.4)!;
        final startB = isDark
            ? Color.lerp(colorScheme.primary, colorScheme.secondary, 0.55)!
            : Color.lerp(colorScheme.primaryContainer, colorScheme.primary, 0.65)!;
        final endB = isDark
            ? Color.lerp(colorScheme.tertiary, colorScheme.secondary, 0.45)!
            : Color.lerp(colorScheme.secondaryContainer, colorScheme.secondary, 0.7)!;
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(startA, startB, t)!,
            Color.lerp(endA, endB, t)!,
          ],
        );

        return GradientText(
          'TwoSpace',
          gradient: gradient,
          style: textStyle.copyWith(
            color: colorScheme.onSurface,
            shadows: [
              Shadow(
                blurRadius: 16,
                color: colorScheme.surface.withValues(alpha: isDark ? 0.16 : 0.22),
              ),
            ],
          ),
        );
      },
    );
  }
}
