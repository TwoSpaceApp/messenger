import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: deferred settings load
    // ignore: discarded_futures
    SettingsService.loadDeferredSettings();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, UITokens.spaceSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = ListView(
      padding: const EdgeInsets.all(UITokens.space),
      children: [
        if (widget.embedded) ...[
          SectionPageHeader(
            title: l10n.privacyTitle,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: UITokens.space),
        ],
        _buildSectionTitle(context, l10n.contactDataSection),
        InlineNoticeCard(
          icon: Icons.info_outline_rounded,
          badge: l10n.featureInDevelopmentLabel,
          title: l10n.contactDataSection,
          message: l10n.featureInDevelopmentMessage(l10n.contactDataSection),
        ),
        const SizedBox(height: UITokens.space),
        _buildSectionTitle(context, l10n.securitySection),
        InlineNoticeCard(
          icon: Icons.devices_rounded,
          badge: l10n.featureInDevelopmentLabel,
          title: l10n.activeSessionsLabel,
          message: l10n.featureInDevelopmentMessage(l10n.activeSessionsLabel),
        ),
        const SizedBox(height: UITokens.spaceSm),
        InlineNoticeCard(
          icon: Icons.security_rounded,
          badge: l10n.featureInDevelopmentLabel,
          title: l10n.twoFactorLabel,
          message: l10n.featureInDevelopmentMessage(l10n.twoFactorLabel),
        ),
        const SizedBox(height: UITokens.spaceSm),
        ValueListenableBuilder<int>(
          valueListenable: SettingsService.sessionTimeoutDaysNotifier,
          builder: (c, days, _) {
            return Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UITokens.cornerSm),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.lock_clock),
                    title: Text(l10n.sessionExpiry),
                    subtitle: Text(l10n.sessionExpirySubtitle(days)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                            final width = MediaQuery.of(context).size.width;
                            final horizontalInset = (width * 0.08).clamp(
                              12.0,
                              28.0,
                            );
                            final controller = TextEditingController(
                              text: days.toString(),
                            );
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: horizontalInset,
                                  vertical: 24,
                                ),
                                title: Text(l10n.sessionExpiryDaysTitle),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.sessionExpiryDaysContent),
                                    const SizedBox(height: UITokens.spaceSm),
                                    TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: l10n.daysLabel,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final v =
                                          int.tryParse(
                                            controller.text.trim(),
                                          ) ??
                                          -1;
                                      if (v < 7 || v > 365) {
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.enterDaysError),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.of(ctx).pop(true);
                                    },
                                    child: Text(l10n.save),
                                  ),
                                ],
                              ),
                            );
                            if (ok ?? false) {
                              final v =
                                  int.tryParse(controller.text.trim()) ?? days;
                              final newV = v.clamp(7, 365);
                              final messenger = ScaffoldMessenger.of(context);
                              await SettingsService.setSessionTimeoutDays(newV);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.sessionExpirySet(newV)),
                                ),
                              );
                            }
                          },
                  ),
                ),
                const SizedBox(height: UITokens.space),
              ],
            );
          },
        ),
      ],
    );

    final content = Material(color: Colors.transparent, child: list);

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ScreenBackground(child: content),
    );
  }
}
