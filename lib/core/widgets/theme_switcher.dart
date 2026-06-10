import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.themeModeNotifier,
      builder: (context, themeMode, child) {
        final currentMode = themeMode;
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;

        String currentLabel;
        switch (currentMode) {
          case ThemeMode.system:
            currentLabel = l10n.themeSystem;
          case ThemeMode.light:
            currentLabel = l10n.themeLight;
          case ThemeMode.dark:
            currentLabel = l10n.themeDark;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showThemePicker(context, currentMode),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, ThemeMode currentMode) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Fire-and-forget; sheet result handled via callbacks
    // ignore: discarded_futures
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.settingsThemeSelection,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _ThemeOption(
                mode: ThemeMode.system,
                label: l10n.themeSystem,
                icon: Icons.brightness_auto,
                isSelected: currentMode == ThemeMode.system,
                onTap: () {
                  // Fire-and-forget; theme change handled reactively
                  // ignore: discarded_futures
                  SettingsService.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              _ThemeOption(
                mode: ThemeMode.light,
                label: l10n.themeLight,
                icon: Icons.light_mode,
                isSelected: currentMode == ThemeMode.light,
                onTap: () {
                  // Fire-and-forget; theme change handled reactively
                  // ignore: discarded_futures
                  SettingsService.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              _ThemeOption(
                mode: ThemeMode.dark,
                label: l10n.themeDark,
                icon: Icons.dark_mode,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () {
                  // Fire-and-forget; theme change handled reactively
                  // ignore: discarded_futures
                  SettingsService.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {

  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final ThemeMode mode;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
