import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/widgets/section_card.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.label = 'Загрузка…',
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: compact ? 22 : 28,
          height: compact ? 22 : 28,
          child: const CircularProgressIndicator(strokeWidth: 2.4),
        ),
        SizedBox(height: compact ? 10 : 14),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );

    if (compact) {
      return Center(child: content);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UITokens.spaceXLg),
        child: SectionCard(
          padding: const EdgeInsets.all(UITokens.spaceMd),
          radius: UITokens.cornerXL,
          child: content,
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UITokens.spaceXLg),
        child: SectionCard(
          padding: const EdgeInsets.symmetric(
            horizontal: UITokens.spaceMd,
            vertical: UITokens.spaceLg,
          ),
          radius: UITokens.cornerXL,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 42,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                ShadButton(
                  onPressed: onAction,
                  leading: const Icon(Icons.arrow_forward_rounded),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UITokens.spaceXLg),
        child: SectionCard(
          padding: const EdgeInsets.symmetric(
            horizontal: UITokens.spaceMd,
            vertical: UITokens.spaceLg,
          ),
          radius: UITokens.cornerXL,
          borderColor: errorColor.withValues(alpha: 0.28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 42, color: errorColor),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                ShadButton.outline(
                  onPressed: onAction,
                  leading: const Icon(Icons.refresh_rounded),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
