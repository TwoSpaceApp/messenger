import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/background_effects_performance_service.dart';

class BackgroundOptimizationNotice extends StatelessWidget {
  const BackgroundOptimizationNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BackgroundEffectsPerformanceService.noticeVisible,
      builder: (context, visible, _) {
        if (!visible) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  padding: const EdgeInsets.fromLTRB(16, 14, 10, 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_motion_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.backgroundOptimizationDisabledTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.backgroundOptimizationDisabledMessage,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                BackgroundEffectsPerformanceService.dismissNotice();
                                context.push(AppStrings.routeCustomization);
                              },
                              child: Text(l10n.backgroundOptimizationOpenSettings),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: BackgroundEffectsPerformanceService.dismissNotice,
                        icon: const Icon(Icons.close),
                        tooltip: l10n.close,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
