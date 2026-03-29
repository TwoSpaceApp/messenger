import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/theme_options.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/sentry_service.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/language_switcher.dart';
import 'package:two_space_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class _RegisterStylePreset {
  const _RegisterStylePreset({
    required this.id,
    required this.color,
    required this.fontFamily,
  });

  final String id;
  final int color;
  final String fontFamily;
}

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
  static const List<_RegisterStylePreset> _stylePresets = [
    _RegisterStylePreset(
      id: 'quietGlass',
      color: 0xFF5263FF,
      fontFamily: 'Inter',
    ),
    _RegisterStylePreset(
      id: 'nightSignal',
      color: 0xFF651FFF,
      fontFamily: 'Oswald',
    ),
    _RegisterStylePreset(
      id: 'editorial',
      color: 0xFF5C6B73,
      fontFamily: 'OpenSans',
    ),
    _RegisterStylePreset(
      id: 'solarFlare',
      color: 0xFFFFB300,
      fontFamily: 'Roboto',
    ),
  ];

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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _nicknameFocus = FocusNode();

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
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _nicknameFocus.dispose();
    super.dispose();
  }

  void _focusForStep(int step) {
    if (!mounted) return;
    switch (step) {
      case 0:
        _emailFocus.requestFocus();
        return;
      case 1:
        _nameFocus.requestFocus();
        return;
      default:
        FocusScope.of(context).unfocus();
    }
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
      final nextStep = _step + 1;
      setState(() {
        _step = nextStep;
        _swapBlobs = !_swapBlobs;
        _isCovering = false; // Reveal new content
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusForStep(nextStep);
      });
    } else {
      // Final step, proceed to registration
      setState(() => _isCovering = false);
      await _handleRegistration();
    }
  }

  Future<void> _prevStep() async {
    if (_step > 0) {
      final prevStep = _step - 1;
      setState(() => _isCovering = true);
      setState(() {
        _step = prevStep;
        _swapBlobs = !_swapBlobs;
        _isCovering = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusForStep(prevStep);
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

  String _presetTitle(AppLocalizations l10n, String id) {
    switch (id) {
      case 'quietGlass':
        return l10n.presetQuietGlass;
      case 'nightSignal':
        return l10n.presetNightSignal;
      case 'editorial':
        return l10n.presetEditorial;
      case 'solarFlare':
        return l10n.presetSolarFlare;
      default:
        return l10n.stylePresetsTitle;
    }
  }

  String _presetSubtitle(AppLocalizations l10n, String id) {
    switch (id) {
      case 'quietGlass':
        return l10n.presetQuietGlassSubtitle;
      case 'nightSignal':
        return l10n.presetNightSignalSubtitle;
      case 'editorial':
        return l10n.presetEditorialSubtitle;
      case 'solarFlare':
        return l10n.presetSolarFlareSubtitle;
      default:
        return l10n.themeAppliesEverywhere;
    }
  }

  Future<void> _applyRegisterPreset(_RegisterStylePreset preset) async {
    setState(() {
      _selectedColor = preset.color;
      _selectedFont = preset.fontFamily;
    });
    await SettingsService.updateTheme(
      primaryColorValue: preset.color,
      fontFamily: preset.fontFamily,
    );
  }

  Future<void> _openFontPicker() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.text_fields_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.fontLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.selectFontFamily,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _fontChoices.length,
                    itemBuilder: (context, index) {
                      final font = _fontChoices[index];
                      final selected = font == _selectedFont;
                      return ListTile(
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        title: Text(
                          font,
                          style: TextStyle(fontFamily: font),
                        ),
                        subtitle: Text(
                          'Аа',
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          setState(() => _selectedFont = font);
                          await SettingsService.updateTheme(fontFamily: font);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              child: Container(
                key: ValueKey<int>(_step),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 392),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(
                    alpha: isDark ? 0.36 : 0.68,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
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
          focusNode: _emailFocus,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration:
              _inputDecoration(theme, 'Email', Icons.email_outlined, isDark),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passCtl,
          focusNode: _passwordFocus,
          validator: _validatePassword,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _nextStep(),
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
          focusNode: _nameFocus,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _nicknameFocus.requestFocus(),
          decoration: _inputDecoration(
              theme, l10n.fullNameLabel, Icons.person_outline, isDark),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nicknameCtl,
          focusNode: _nicknameFocus,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateAegisUsername,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _nextStep(),
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
        Text(
          l10n.stylePresetsTitle,
          style: TextStyle(color: theme.hintColor),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 174,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _stylePresets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = _stylePresets[index];
              final selected =
                  _selectedColor == preset.color && _selectedFont == preset.fontFamily;
              final color = Color(preset.color);
              return SizedBox(
                width: 208,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _applyRegisterPreset(preset),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? color.withValues(alpha: 0.95)
                              : theme.colorScheme.outline.withValues(alpha: 0.14),
                          width: selected ? 2 : 1,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.18),
                            theme.colorScheme.surface.withValues(alpha: 0.92),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          color,
                                          color.withValues(alpha: 0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: theme.colorScheme.surface.withValues(alpha: 0.76),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Аа',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontFamily: preset.fontFamily,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _presetTitle(l10n, preset.id),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                _presetSubtitle(l10n, preset.id),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.subtitleText(context),
                                  height: 1.28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.fontLabel, style: TextStyle(color: theme.hintColor)),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _openFontPicker,
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.56),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Аа',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: _selectedFont,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFont,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: _selectedFont,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.selectFontFamily,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.subtitleText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
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
