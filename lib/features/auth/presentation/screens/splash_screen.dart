import 'package:flutter/material.dart';
import 'package:two_space_app/core/constants/app_constants.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';

class SplashScreen extends StatelessWidget {
  final String? currentStep;
  final double? progress;

  const SplashScreen({
    super.key,
    this.currentStep,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final normalizedProgress = (progress ?? 0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const Hero(
                tag: 'app_logo',
                child: AppLogo(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: normalizedProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF46B3FF),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n?.feedbackVersion(
                      '${AppConstants.appVersion}+${AppConstants.buildNumber}',
                    ) ??
                    'Version: ${AppConstants.appVersion}+${AppConstants.buildNumber}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
