import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';

class SettingsHeroCard extends StatelessWidget {
  const SettingsHeroCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
    this.badges = const <Widget>[],
    this.child,
    this.padding = const EdgeInsets.all(UITokens.spaceLg),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> badges;
  final Widget? child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UITokens.cornerXLg),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.9),
                      theme.colorScheme.tertiary.withValues(alpha: 0.78),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: UITokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: UITokens.spaceXSm),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleText(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: UITokens.spaceMd),
            Wrap(
              spacing: UITokens.spaceSm,
              runSpacing: UITokens.spaceSm,
              children: badges,
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: UITokens.spaceLg),
            child!,
          ],
        ],
      ),
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    required this.title,
    required this.subtitle,
    super.key,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.subtitleText(context),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: UITokens.space),
          trailing!,
        ],
      ],
    );
  }
}

class SettingsPill extends StatelessWidget {
  const SettingsPill({
    required this.label,
    super.key,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.space,
        vertical: UITokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(UITokens.cornerPill),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: UITokens.spaceXSm),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum SettingsStageState { idle, active, complete, error }

class SettingsStageTile extends StatelessWidget {
  const SettingsStageTile({
    required this.title,
    required this.subtitle,
    required this.state,
    super.key,
  });

  final String title;
  final String subtitle;
  final SettingsStageState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActive = state == SettingsStageState.active;
    final bool isComplete = state == SettingsStageState.complete;
    final bool isError = state == SettingsStageState.error;

    final Color accent = isError
        ? theme.colorScheme.error
        : isActive || isComplete
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;

    final Widget icon = isComplete
        ? Icon(Icons.check_rounded, color: accent, size: 18)
        : isError
            ? Icon(Icons.close_rounded, color: accent, size: 18)
            : isActive
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  )
                : Icon(Icons.circle_outlined, color: accent, size: 18);

    return Container(
      padding: const EdgeInsets.all(UITokens.spaceMdSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(UITokens.cornerXLg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: UITokens.space),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: UITokens.spaceXS),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.subtitleText(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
