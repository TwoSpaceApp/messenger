import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/features/auth/data/services/biometric_auth_service.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final biometricService = BiometricAuthService();
  bool _loading = true;
  bool _saving = false;
  bool _deviceAuthAvailable = false;
  bool _lockEnabled = false;
  String? _feedback;
  List<_AuthMethodChipData> _availableMethods = const [];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final methods = await biometricService.getAvailableBiometrics();
    final available = await biometricService.canAuthenticate();
    final storedEnabled = await biometricService.isBiometricEnabled();
    final settingsEnabled = SettingsService.biometricsNotifier.value;
    if (!mounted) {
      return;
    }

    setState(() {
      _deviceAuthAvailable = available;
      _lockEnabled = storedEnabled || settingsEnabled;
      _availableMethods = _buildMethodChips(methods, available);
      _loading = false;
    });
  }

  Future<void> _toggleLock(bool value) async {
    if (_saving) {
      return;
    }

    if (!value) {
      setState(() {
        _saving = true;
        _feedback = null;
      });
      await biometricService.setBiometricEnabled(false);
      await SettingsService.setBiometricsEnabled(false);
      if (!mounted) {
        return;
      }
      setState(() {
        _lockEnabled = false;
        _saving = false;
      });
      return;
    }

    setState(() {
      _saving = true;
      _feedback = null;
    });
    final l10n = AppLocalizations.of(context)!;
    final authenticated = await biometricService.authenticate(
      localizedReason: l10n.unlockApp,
    );
    if (!mounted) {
      return;
    }
    if (!authenticated) {
      setState(() {
        _saving = false;
        _feedback = l10n.lockScreenFailedMessage;
      });
      return;
    }

    await biometricService.setBiometricEnabled(true);
    await SettingsService.setBiometricsEnabled(true);
    if (!mounted) {
      return;
    }

    setState(() {
      _lockEnabled = true;
      _saving = false;
      _feedback = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.biometricEnabledLabel)),
    );
  }

  List<_AuthMethodChipData> _buildMethodChips(List<dynamic> methods, bool available) {
    final chips = <_AuthMethodChipData>[];
    final hasFace = methods.any((method) => method.toString().contains('face'));
    final hasFingerprint = methods.any(
      (method) => method.toString().contains('fingerprint'),
    );
    final hasStrongBiometric = methods.any(
      (method) =>
          method.toString().contains('strong') ||
          method.toString().contains('iris'),
    );

    if (hasFace) {
      chips.add(
        const _AuthMethodChipData(
          icon: Icons.face_retouching_natural_rounded,
          labelKey: _AuthMethodLabel.face,
        ),
      );
    }
    if (hasFingerprint) {
      chips.add(
        const _AuthMethodChipData(
          icon: Icons.fingerprint_rounded,
          labelKey: _AuthMethodLabel.fingerprint,
        ),
      );
    }
    if (hasStrongBiometric && !hasFace && !hasFingerprint) {
      chips.add(
        const _AuthMethodChipData(
          icon: Icons.verified_user_rounded,
          labelKey: _AuthMethodLabel.biometric,
        ),
      );
    }
    if (available) {
      chips.add(
        const _AuthMethodChipData(
          icon: Icons.password_rounded,
          labelKey: _AuthMethodLabel.passcode,
        ),
      );
    }
    return chips;
  }

  String _methodLabel(AppLocalizations l10n, _AuthMethodLabel label) {
    return switch (label) {
      _AuthMethodLabel.face => l10n.authMethodFaceId,
      _AuthMethodLabel.fingerprint => l10n.authMethodFingerprint,
      _AuthMethodLabel.biometric => l10n.authMethodBiometric,
      _AuthMethodLabel.passcode => l10n.authMethodDevicePasscode,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final content = SafeArea(
      top: !widget.embedded,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UITokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.embedded) ...[
              SectionPageHeader(
                title: l10n.biometricSetupTitle,
                subtitle: l10n.biometricAuthSubtitle,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: UITokens.spaceMd),
            ],
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(UITokens.spaceMd),
                child: _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: UITokens.spaceLg,
                          ),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.authMethodsLabel,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: UITokens.spaceXS),
                          Text(
                            l10n.biometricAuthSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: UITokens.spaceMd),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.82,
                              ),
                              borderRadius: BorderRadius.circular(
                                UITokens.cornerXL,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                            ),
                            child: SwitchListTile.adaptive(
                              value: _lockEnabled,
                              onChanged: _deviceAuthAvailable && !_saving
                                  ? _toggleLock
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: UITokens.spaceMd,
                                vertical: UITokens.space2XS,
                              ),
                              secondary: Icon(
                                _lockEnabled
                                    ? Icons.verified_user_rounded
                                    : Icons.lock_outline_rounded,
                              ),
                              title: Text(l10n.biometricsEnable),
                              subtitle: Text(l10n.biometricAuthSubtitle),
                            ),
                          ),
                          if (_availableMethods.isNotEmpty) ...[
                            const SizedBox(height: UITokens.spaceMd),
                            Wrap(
                              spacing: UITokens.spaceSm,
                              runSpacing: UITokens.spaceSm,
                              children: _availableMethods
                                  .map(
                                    (method) => Chip(
                                      avatar: Icon(method.icon, size: 18),
                                      label: Text(
                                        _methodLabel(l10n, method.labelKey),
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ],
                          if (_feedback != null) ...[
                            const SizedBox(height: UITokens.spaceMd),
                            InlineNoticeCard(
                              icon: Icons.info_outline_rounded,
                              title: l10n.lockScreenFailedTitle,
                              message: _feedback!,
                            ),
                          ],
                          if (!_deviceAuthAvailable) ...[
                            const SizedBox(height: UITokens.spaceMd),
                            InlineNoticeCard(
                              icon: Icons.phonelink_lock_rounded,
                              title: l10n.biometricsEnable,
                              message: l10n.deviceAuthUnavailableMessage,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: UITokens.spaceXLg),

            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(UITokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutSecurityLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: UITokens.spaceSm),
                    Text(
                      l10n.aboutSecurityContent,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final body = widget.embedded
        ? content
        : ScreenBackground(child: content);

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.biometricSetupTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: body,
    );
  }
}

enum _AuthMethodLabel { face, fingerprint, biometric, passcode }

class _AuthMethodChipData {
  const _AuthMethodChipData({required this.icon, required this.labelKey});

  final IconData icon;
  final _AuthMethodLabel labelKey;
}
