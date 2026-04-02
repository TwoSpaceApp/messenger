import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/app_colors.dart';

/// MD3 tonal-surface card with optional glass effect.
///
/// Uses [ShadCard] as the layout shell to stay visually consistent with
/// shadcn buttons and inputs. Falls back to a plain Material card when no
/// blur is required.
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
    final shadTheme = ShadTheme.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tonal surface: blend shadcn card colour with the app glass surface
    final cardBg = Color.alphaBlend(
      shadTheme.colorScheme.card.withValues(alpha: isDark ? 0.82 : 0.92),
      AppColors.glassSurface(context),
    );

    final border = Border.all(
      color: cs.outlineVariant.withValues(alpha: 0.6),
    );
    final shadow = BoxShadow(
      color: AppColors.glassShadow(context),
      blurRadius: 20,
      offset: const Offset(0, 8),
    );

    final Widget card = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: cs.primary.withValues(alpha: 0.08),
        highlightColor: cs.primary.withValues(alpha: 0.04),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
            boxShadow: [shadow],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
