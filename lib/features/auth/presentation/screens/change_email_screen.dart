import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  static final DevLogger _logger = DevLogger('ChangeEmailScreen');
  
  final AegisAuthService _authService = AegisAuthService();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  
  bool _loading = false;
  bool _loadingCurrent = true;
  String? _currentEmail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: email load result handled within the method
    // ignore: discarded_futures
    _loadCurrentEmail();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentEmail() async {
    try {
      _logger.debug('Loading current email from profile');
      await _authService.ensureSession();
      final response = await _authService.getOwnProfile();
      
      if (!mounted) return;
      
      if (!response.success || response.profile == null) {
        setState(() {
          _loadingCurrent = false;
          _errorMessage = response.message ?? 'Failed to load profile';
        });
        return;
      }
      
      final email = response.profile!.email?.trim() ?? '';
      setState(() {
        _currentEmail = email.isEmpty ? null : email;
        _loadingCurrent = false;
        _errorMessage = null;
      });
      _logger.debug('Current email loaded: $_currentEmail');
    } catch (e) {
      if (!mounted) return;
      _logger.error('Failed to load current email: $e');
      setState(() {
        _loadingCurrent = false;
        _errorMessage = UserFacingError.format(e);
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final newEmail = _emailCtrl.text.trim();
    final password = _pwdCtrl.text;
    
    // Validate inputs
    if (newEmail.isEmpty) {
      setState(() => _errorMessage = l10n.emailRequired);
      return;
    }
    
    if (!_isValidEmail(newEmail)) {
      setState(() => _errorMessage = l10n.emailInvalid);
      return;
    }
    
    if (password.isEmpty) {
      setState(() => _errorMessage = l10n.passwordRequired);
      return;
    }
    
    if (newEmail == _currentEmail) {
      setState(() => _errorMessage = l10n.emailUnchanged);
      return;
    }
    
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    try {
      _logger.info('Attempting to change email to: $newEmail');
      
      // TODO(dev): This requires server-side support for email change via protocol.
      // For now, we show an informative message about what the backend needs to support.
      
      // Once the server supports it, the call would be:
      // await _authService.changeEmail(newEmail: newEmail, password: password);
      
      // Temporary: show what would be sent
      _logger.debug('Email change would require: newEmail=$newEmail with password verification');
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = l10n.changeEmailNotYetSupported;
        _loading = false;
      });
      
      // Show an informative error to the user
      if (!mounted) return;
      _showErrorDialog(
        title: l10n.changeEmailTitle,
        message: l10n.changeEmailNotAvailable,
      );
      
    } catch (e) {
      if (!mounted) return;
      _logger.error('Email change failed: $e');
      setState(() {
        _errorMessage = UserFacingError.format(e);
        _loading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    // Simple email validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  void _showErrorDialog({required String title, required String message}) {
    final l10n = AppLocalizations.of(context)!;
    // Fire-and-forget: dialog is self-contained
    // ignore: discarded_futures
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_loadingCurrent) {
      return const Scaffold(
        body: ScreenBackground(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: UITokens.sectionContentMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(UITokens.spaceMd),
          child: ValueListenableBuilder<bool>(
            valueListenable: SettingsService.paleVioletNotifier,
            builder: (c, pale, _) {
              final theme = Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UITokens.cornerSm),
                  ),
                  filled: pale,
                  fillColor: pale ? const Color(0xFFF6F0FF) : null,
                ),
              );
              return Theme(
                data: theme,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.embedded) ...[
                        SectionPageHeader(
                          title: l10n.changeEmailTitle,
                          subtitle: l10n.changeEmailDescription,
                          leading: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceMd),
                      ],
                      Text(l10n.changeEmailDescription),
                      const SizedBox(height: UITokens.space),
                      
                      // Show current email
                      if (_currentEmail != null) ...[
                        Container(
                          padding: const EdgeInsets.all(UITokens.spaceSm),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(UITokens.cornerSm),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.currentPrefix,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentEmail ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: UITokens.space),
                      ],
                      
                      // Error state
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(UITokens.spaceSm),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(UITokens.cornerSm),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: UITokens.space),
                      ],
                      
                      // Status message - feature not yet ready
                      InlineNoticeCard(
                        icon: Icons.info_rounded,
                        badge: l10n.featureInDevelopmentLabel,
                        title: l10n.changeEmailTitle,
                        message: l10n.changeEmailRequiresServerSupport,
                      ),
                      const SizedBox(height: UITokens.space),
                      
                      // New email field
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: l10n.newEmailLabel,
                          hintText: l10n.emailHintExample,
                        ),
                      ),
                      const SizedBox(height: UITokens.space),
                      
                      // Password field for verification
                      TextField(
                        controller: _pwdCtrl,
                        obscureText: true,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          labelText: l10n.currentPasswordLabel,
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceMdLg),
                      
                      // Submit button
                      ElevatedButton(
                        onPressed: (_loading || _loadingCurrent) ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: UITokens.borderThick,
                                ),
                              )
                            : Text(l10n.changeEmailButton),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    final body = widget.embedded ? content : ScreenBackground(child: content);

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
    );
  }
}
