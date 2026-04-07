import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

String chatCreationFriendlyError(Object error) {
  return error.toString().replaceFirst(RegExp('^Exception: '), '');
}

String normalizePublicAlias(String value) {
  return value.trim().replaceFirst(RegExp('^@+'), '').replaceAll(' ', '-');
}

InputDecoration chatCreationInputDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
  String? hint,
  String? helper,
}) {
  final theme = Theme.of(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    labelStyle: TextStyle(color: AppColors.subtitleText(context)),
    hintStyle: TextStyle(color: AppColors.hintText(context)),
    helperStyle: theme.textTheme.bodySmall?.copyWith(
      color: AppColors.subtitleText(context),
    ),
    prefixIcon: Icon(icon, color: AppColors.subtitleText(context)),
    filled: true,
    fillColor: theme.colorScheme.surface.withValues(alpha: 0.46),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.cornerXLg),
      borderSide: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.16),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.cornerXLg),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.4),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.cornerXLg),
    ),
  );
}

class ChatCreationScaffold extends StatelessWidget {
  const ChatCreationScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= UITokens.tabletBreakpoint
                  ? UITokens.compactFormMaxWidth
                  : double.infinity;
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      UITokens.spaceMd,
                      UITokens.spaceSm,
                      UITokens.spaceMd,
                      UITokens.bottomBarClearance,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(UITokens.spaceLg),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(
                                    UITokens.cornerLg,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  icon,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: UITokens.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: UITokens.spaceXsSm),
                                    Text(
                                      subtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.subtitleText(
                                              context,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceMd),
                        child,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class ChatCreationErrorBanner extends StatelessWidget {
  const ChatCreationErrorBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UITokens.spaceMdSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UITokens.cornerXLg),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: UITokens.spaceSmMd),
          Expanded(
            child: Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
