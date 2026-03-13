import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/theme_options.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/sentry_service.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/language_switcher.dart';
import 'package:two_space_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

/// Modern RegisterScreen including Customization Step
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static final RegExp _aegisUsernamePattern =
      RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.-]{2,31}$');

  late final _avatarAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    lowerBound: 0.9,
  )..value = 1.0;

  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _nicknameCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // String? _avatarPath;
  Uint8List? _avatarBytes;

  // 0: Credentials, 1: Profile Info, 2: Avatar, 3: Customization
  int _step = 0;

  bool _loading = false;
  bool _obscurePassword = true;
  bool _isCovering = true; // Start hidden for entrance animation
  bool _swapBlobs = false;

  // Customization State
  late int _selectedColor;
  late String _selectedFont;

  final List<Map<String, dynamic>> _colorChoices = ThemeOptions.colors;

  final List<String> _fontChoices = ThemeOptions.fonts;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Reveal animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isCovering = false);
    });
    // Initialize with current or default settings
    _selectedColor = SettingsService.themeNotifier.value.primaryColorValue;
    _selectedFont = SettingsService.themeNotifier.value.fontFamily;
  }

  @override
  void dispose() {
    _avatarAnimController.dispose();
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    _nicknameCtl.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _errorMessage = null);
    // Validation first
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
    } else if (_step == 1) {
      if (_nameCtl.text.isEmpty || _nicknameCtl.text.isEmpty) {
        _showError(l10n.fillAllFields);
        return;
      }
      final usernameError = _validateAegisUsername(_nicknameCtl.text.trim());
      if (usernameError != null) {
        _showError(usernameError);
        return;
      }
    }

    // Start Transition Animation
    setState(() => _isCovering = true);

    // Change Content
    if (_step < 3) {
      setState(() {
        _step++;
        _swapBlobs = !_swapBlobs;
        _isCovering = false; // Reveal new content
      });
    } else {
      // Final step, proceed to registration
      setState(() => _isCovering = false);
      await _handleRegistration();
    }
  }

  Future<void> _prevStep() async {
    if (_step > 0) {
      setState(() => _isCovering = true);
      setState(() {
        _step--;
        _swapBlobs = !_swapBlobs;
        _isCovering = false;
      });
    } else {
      // Navigate back to Login with animation
      setState(() => _isCovering = true);
      if (mounted) context.go('/login');
    }
  }

  int _getPasswordStrength(String password) {
    if (password.length < 6) return 0;
    var strength = 1;
    if (password.length >= 8) strength++;
    if (RegExp('[0-9]').hasMatch(password)) strength++;
    if (RegExp('[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  String _getPasswordStrengthLabel(int strength, AppLocalizations l10n) {
    switch (strength) {
      case 0:
      case 1:
        return l10n.passwordStrengthWeak;
      case 2:
        return l10n.passwordStrengthMedium;
      case 3:
        return l10n.passwordStrengthGood;
      default:
        return l10n.passwordStrengthStrong;
    }
  }

  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  Future<void> _handleRegistration() async {
    setState(() => _loading = true);
    try {
      SentryService.addBreadcrumb('Начало регистрации', category: 'auth');

      final notifier = ref.read(authProvider.notifier);

      // Apply customization settings before registering/logging in
      await SettingsService.updateTheme(
        primaryColorValue: _selectedColor,
        fontFamily: _selectedFont,
      );

      await notifier.register(
        _nicknameCtl.text.trim(),
        _emailCtl.text.trim(),
        _passCtl.text.trim(),
        displayName: _nameCtl.text.trim(),
        avatarBytes: _avatarBytes,
      );

      SentryService.addBreadcrumb('Регистрация успешна', category: 'auth');

      if (!mounted) return;

      // Navigate to Welcome Screen instead of direct Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(
            name: _nameCtl.text.trim(),
            description: _nicknameCtl.text.trim(),
            // Pass avatar logic if available, currently just bytes in _avatarBytes
            // Ideally we upload it first, but for now passing null to use Initials
          ),
        ),
      );
    } catch (e, stackTrace) {
      SentryService.captureException(
        e,
        stackTrace: stackTrace,
        hint: {'screen': 'register', 'step': _step},
      );

      if (mounted) {
        setState(
            () => _errorMessage = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Legacy method, kept if needed for other flows but we use inline error now
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.validationEnterEmail;
    if (!value.contains('@')) return l10n.validationInvalidEmail;
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.validationEnterPassword;
    if (value.length < 6) return l10n.validationPasswordTooShort;
    return null;
  }

  String? _validateAegisUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Choose an Aegis username.';
    }
    if (!_aegisUsernamePattern.hasMatch(trimmed)) {
      return 'Username must be 3-32 chars and use Latin letters, digits, ., _ or -.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AuthBackground(
      title: l10n.registerTitle,
      seed: _step + 1,
      isCovering: _isCovering,
      swapBlobs: _swapBlobs,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Переключатель языка — правый верхний угол
            const Align(
              alignment: Alignment.topRight,
              child: LanguageSwitcherButton(),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: AppLogo(large: false),
            ),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 20, color: theme.colorScheme.error),
                      onPressed: () => setState(() => _errorMessage = null),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),

            // Step Indicator
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepDot(0, theme),
                  _buildStepLine(0, theme),
                  _buildStepDot(1, theme),
                  _buildStepLine(1, theme),
                  _buildStepDot(2, theme),
                  _buildStepLine(2, theme),
                  _buildStepDot(3, theme),
                ],
              ),
            ),

            // Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey<int>(_step),
                child: _buildCurrentStep(theme, isDark),
              ),
            ),

            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                TextButton(
                  onPressed: (_loading || _isCovering) ? null : _prevStep,
                  child: Text(
                    _step == 0 ? l10n.backToLogin : l10n.back,
                    style: TextStyle(
                      color:
                          isDark ? Colors.white70 : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: (_loading || _isCovering) ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _step == 3 ? l10n.finishButton : l10n.next,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme, bool isDark) {
    switch (_step) {
      case 0:
        return _buildStep0(theme, isDark);
      case 1:
        return _buildStep1(theme, isDark);
      case 2:
        return _buildStep2(theme, isDark);
      case 3:
        return _buildStep3(theme, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep0(ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          controller: _emailCtl,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration:
              _inputDecoration(theme, 'Email', Icons.email_outlined, isDark),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passCtl,
          validator: _validatePassword,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
                  theme, l10n.passwordLabel, Icons.lock_outline, isDark)
              .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_passCtl.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _getPasswordStrength(_passCtl.text) / 4,
                      minHeight: 4,
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPasswordStrengthColor(
                            _getPasswordStrength(_passCtl.text)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getPasswordStrengthLabel(
                      _getPasswordStrength(_passCtl.text), l10n),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getPasswordStrengthColor(
                        _getPasswordStrength(_passCtl.text)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStep1(ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          controller: _nameCtl,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: _inputDecoration(
              theme, l10n.fullNameLabel, Icons.person_outline, isDark),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nicknameCtl,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateAegisUsername,
          decoration: _inputDecoration(
              theme, l10n.nicknameAtLabel, Icons.alternate_email, isDark),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Aegis username: 3-32 chars, Latin letters, digits, ., _ or -',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _avatarAnimController.reverse(),
          onTapUp: (_) => _avatarAnimController.forward(),
          onTapCancel: () => _avatarAnimController.forward(),
          onTap: () async {
            try {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.image,
                withData: true,
              );
              if (res != null && res.files.isNotEmpty) {
                final file = res.files.single;
                setState(() {
                  // _avatarPath = file.path;
                  _avatarBytes = file.bytes;
                });
              }
            } catch (e) {
              _showError(l10n.filePickError(e.toString()));
            }
          },
          child: ScaleTransition(
            scale: _avatarAnimController,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white10 : theme.colorScheme.surface,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: _avatarBytes != null ? 4 : 2,
                ),
                boxShadow: _avatarBytes != null
                    ? [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
                image: _avatarBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_avatarBytes!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _avatarBytes == null
                  ? Icon(Icons.add_a_photo_outlined,
                      size: 40, color: theme.colorScheme.primary)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _avatarBytes != null ? l10n.photoLooksGreat : l10n.uploadPhotoPrompt,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.helpFriendsFind,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            l10n.setupInterfaceTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Color Picker
        Text(l10n.colorThemeLabel, style: TextStyle(color: theme.hintColor)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colorChoices.map((choice) {
            final colorValue = choice['value'] as int;
            final isSelected = _selectedColor == colorValue;

            return GestureDetector(
              onTap: () async {
                setState(() => _selectedColor = colorValue);
                await SettingsService.updateTheme(
                    primaryColorValue: colorValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: isDark ? Colors.white : Colors.black, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Color(colorValue).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Font Picker
        Text(l10n.fontLabel, style: TextStyle(color: theme.hintColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFont,
              isExpanded: true,
              dropdownColor: theme.colorScheme.surface,
              items: _fontChoices.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedFont = v);
                  SettingsService.updateTheme(fontFamily: v);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      ThemeData theme, String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: theme.colorScheme.surface.withAlpha(50),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildStepDot(int index, ThemeData theme) {
    final isActive = _step >= index;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? theme.colorScheme.primary
            : theme.disabledColor.withValues(alpha: 0.2),
      ),
      child: Center(
        child: isActive
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int index, ThemeData theme) {
    final isActive = _step > index;
    return Container(
      width: 24, // Slightly shorter to fit 4 steps
      height: 2,
      color: isActive
          ? theme.colorScheme.primary
          : theme.disabledColor.withValues(alpha: 0.2),
    );
  }
}
