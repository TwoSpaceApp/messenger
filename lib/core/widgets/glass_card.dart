import 'package:flutter/material.dart';

/// Simple glass-style card that applies a backdrop blur and translucent background.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withValues(alpha: 0.72);
    final Widget card = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
                color:
                    Theme.of(context).dividerColor.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
