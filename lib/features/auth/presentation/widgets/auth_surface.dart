import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';

/// Full-screen shell for auth-adjacent pages that don't use the animated
/// AuthBackground (e.g. WelcomeScreen, OtpScreen, TfaSetupScreen).
///
/// Uses a MD3 tonal gradient background and a [ShadCard] form container.
class AuthSurface extends StatelessWidget {
  const AuthSurface({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.maxWidth = UITokens.sheetContentMaxWidth,
    this.padding = const EdgeInsets.all(UITokens.spaceXLg),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surface, cs.surfaceContainerHighest, cs.surface],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ShadCard(
                padding: const EdgeInsets.all(UITokens.spaceXLg),
                radius: const BorderRadius.all(
                  Radius.circular(UITokens.corner2XLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: UITokens.space4XL,
                        height: UITokens.space4XL,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerMd,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: cs.onPrimaryContainer,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceMdSm),
                    ],
                    if ((title ?? '').isNotEmpty)
                      Text(
                        title!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    if ((subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: UITokens.spaceXSm),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if ((title ?? '').isNotEmpty || (subtitle ?? '').isNotEmpty)
                      const SizedBox(height: UITokens.spaceLg),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
