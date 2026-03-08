import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';

/// Simple reusable card used across settings/login/register screens to
/// provide consistent padding, elevation and rounded corners.
class SectionCard extends StatelessWidget {
  const SectionCard(
      {required this.child,
      super.key,
      this.padding = const EdgeInsets.all(UITokens.space),
      this.elevation = UITokens.cardElevation,
      this.color});
  final Widget child;
  final EdgeInsets padding;
  final double elevation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UITokens.corner)),
      child: Padding(padding: padding, child: child),
    );
  }
}
