import 'package:flutter/material.dart';
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
    final activeStep = _presentableStep(currentStep, l10n);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 4),
              const Hero(
                tag: 'app_logo',
                child: AppLogo(),
              ),
              const SizedBox(height: 24),
              Text(
                l10n?.startupTitle ?? 'Preparing TwoSpace',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n?.startupSubtitle ??
                    'Checking the secure session and opening your chats.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n?.initializing ?? 'Initializing...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activeStep,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.startupFooter ??
                          'The launch screen is only shown during app startup.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
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
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(normalizedProgress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  static String _presentableStep(String? step, AppLocalizations? l10n) {
    switch (step) {
      case 'Environment Loading':
        return l10n?.startupStepEnvironment ?? 'Loading configuration';
      case 'Sentry Error Tracking':
        return l10n?.startupStepDiagnostics ?? 'Starting diagnostics';
      case 'Environment Validation':
        return l10n?.startupStepValidation ?? 'Validating environment';
      case 'Settings Service':
        return l10n?.startupStepSettings ?? 'Loading settings';
      case 'Aegis Session Restoration':
        return l10n?.startupStepSession ?? 'Restoring secure session';
      default:
        return l10n?.startupStepLaunch ?? 'Starting app';
    }
  }
}
