import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  String? _currentPhone;

  @override
  void initState() {
    super.initState();
    _loadCurrentPhone();
  }

  Future<void> _loadCurrentPhone() async {
    try {
      // Backend phone management is not available yet.
      if (!mounted) return;
      setState(() => _currentPhone = null);
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneCtrl.text.trim();
    _pwdCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Backend phone management is not available yet.
      if (!mounted) return;
      await showFeatureInDevelopmentDialog(
        context,
        feature: l10n.changePhoneTitle,
      );
      // navState.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.changePhoneError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = ScreenBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<bool>(
          valueListenable: SettingsService.paleVioletNotifier,
          builder: (c, pale, _) {
            final theme = Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: pale,
                fillColor: pale ? const Color(0xFFF6F0FF) : null,
              ),
            );
            return Theme(
              data: theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.embedded) ...[
                    SectionPageHeader(
                      title: l10n.changePhoneTitle,
                      subtitle: l10n.changePhoneDescription,
                      leading: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(l10n.changePhoneDescription),
                  const SizedBox(height: 12),
                  InlineNoticeCard(
                    icon: Icons.construction_rounded,
                    badge: l10n.featureInDevelopmentLabel,
                    title: l10n.changePhoneTitle,
                    message: l10n.featureInDevelopmentMessage(
                      l10n.changePhoneTitle,
                    ),
                  ),
                  if (_currentPhone != null) ...[
                    const SizedBox(height: 8),
                    Text(l10n.currentPrefix,
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(_currentPhone ?? '',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration:
                          InputDecoration(labelText: l10n.newPhoneLabel)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _pwdCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: l10n.currentPasswordOptional)),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.changePhoneButton),
                  ),
                ],
              ),
            );
          },
        ),
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.changePhoneTitle)),
      body: body,
    );
  }
}
