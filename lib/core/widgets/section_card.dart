import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';

/// MD3 tonal surface card used across settings / auth / profile screens.
///
/// Replaces the old Material elevation model with M3 `surfaceContainer`
/// fill + subtle `outlineVariant` border.  No elevation → no shadow
/// "step" artefacts on scrollable lists.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(UITokens.space),
    this.color,
    this.radius = UITokens.cornerLg,
    this.borderColor,
    this.onTap,

    /// Ignored — kept for legacy call-sites.
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double radius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = color ?? cs.surfaceContainer;
    final border = Border.all(
      color: borderColor ?? cs.outlineVariant.withValues(alpha: 0.7),
      width: 0.9,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: cs.primary.withValues(alpha: 0.06),
        highlightColor: cs.primary.withValues(alpha: 0.03),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
