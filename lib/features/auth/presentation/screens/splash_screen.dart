import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/constants/app_constants.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({
    super.key,
    this.currentStep,
    this.progress,
  });
  final String? currentStep;
  final double? progress;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _versionLabel;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: version label load result handled within the method
    // ignore: discarded_futures
    _loadVersionLabel();
  }

  Future<void> _loadVersionLabel() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }
      setState(() => _versionLabel = '${info.version}+${info.buildNumber}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _versionLabel =
            '${AppConstants.appVersion}+${AppConstants.buildNumber}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final normalizedProgress = (widget.progress ?? 0).clamp(0.0, 1.0);
    final versionLabel =
        _versionLabel ??
        '${AppConstants.appVersion}+${AppConstants.buildNumber}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UITokens.spaceXLg,
              vertical: UITokens.spaceXLg,
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Hero(
                        tag: 'app_logo',
                        child: AppLogo(),
                      ),
                      const SizedBox(height: UITokens.spaceXL),
                      SizedBox(
                        width: 220,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerPill,
                          ),
                          child: LinearProgressIndicator(
                            value: normalizedProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF46B3FF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Text(
                    l10n?.feedbackVersion(versionLabel) ??
                        'Version: $versionLabel',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
