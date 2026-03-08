import 'package:flutter/material.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_email_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_phone_screen.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/auth/presentation/screens/tfa_setup_screen.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _hideFromSearch = false;
  bool _hideLastSeen = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    try {
      // AppwriteService not available, skip loading prefs
      if (mounted) {
        setState(() {
        _hideFromSearch = false;
        _hideLastSeen = false;
      });
      }
    } catch (_) {}
  }

  Future<void> _toggle(bool v) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // AppwriteService not available, skip server update
      if (!mounted) return;
      setState(() => _hideFromSearch = v);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.updatePrivacyError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLastSeen(bool v) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // AppwriteService not available, skip server update
      if (!mounted) return;
      setState(() => _hideLastSeen = v);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.updateSettingError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(padding: const EdgeInsets.all(12), children: [
          SwitchListTile(title: Text(l10n.hideFromSearch), subtitle: Text(l10n.hideFromSearchSubtitle), value: _hideFromSearch, onChanged: _loading ? null : _toggle),
        const SizedBox(height: 6),
          SwitchListTile(title: Text(l10n.hideLastSeen), subtitle: Text(l10n.hideLastSeenSubtitle), value: _hideLastSeen, onChanged: _loading ? null : _toggleLastSeen),
        const SizedBox(height: 12),
        // Session persistence setting (silent re-login)
        ValueListenableBuilder<int>(
          valueListenable: SettingsService.sessionTimeoutDaysNotifier,
          builder: (c, days, _) {
            return Column(children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: const Icon(Icons.lock_clock),
                    title: Text(l10n.sessionExpiry),
                    subtitle: Text(l10n.sessionExpirySubtitle(days)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _loading
                      ? null
                      : () async {
                          final controller = TextEditingController(text: days.toString());
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                title: Text(l10n.sessionExpiryDaysTitle),
                                content: Column(mainAxisSize: MainAxisSize.min, children: [
                                  Text(l10n.sessionExpiryDaysContent),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                    decoration: InputDecoration(labelText: l10n.daysLabel),
                                ),
                              ]),
                              actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
                                TextButton(
                                    onPressed: () {
                                      final v = int.tryParse(controller.text.trim()) ?? -1;
                                      if (v < 7 || v > 365) {
                                        // show inline error
                                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.enterDaysError)));
                                        return;
                                      }
                                      Navigator.of(ctx).pop(true);
                                    },
                                      child: Text(l10n.save)),
                              ],
                            ),
                          );
                            if (ok == true) {
                              final v = int.tryParse(controller.text.trim()) ?? days;
                              final newV = v.clamp(7, 365);
                              final messenger = ScaffoldMessenger.of(context);
                              await SettingsService.setSessionTimeoutDays(newV);
                                messenger.showSnackBar(SnackBar(content: Text(l10n.sessionExpirySet(newV))));
                            }
                        },
                ),
              ),
              const SizedBox(height: 12),
            ]);
          },
        ),
        Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.email),
              title: Text(l10n.changeEmailLabel),
              subtitle: Text(l10n.changeEmailSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangeEmailScreen()));
            },
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.security),
              title: Text(l10n.twoFactorLabel),
              subtitle: Text(l10n.twoFactorPrivacySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // Navigate to TFA setup screen
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TfaSetupScreen()));
            },
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.phone),
              title: Text(l10n.changePhoneLabel),
              subtitle: Text(l10n.changePhoneSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePhoneScreen()));
            },
          ),
        ),
      ]),
    );
  }
}

