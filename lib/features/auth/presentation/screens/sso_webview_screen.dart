import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

class SsoWebviewScreen extends StatefulWidget {
  const SsoWebviewScreen({required this.idpId, super.key});
  final String idpId;

  @override
  State<SsoWebviewScreen> createState() => _SsoWebviewScreenState();
}

class _SsoWebviewScreenState extends State<SsoWebviewScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.ssoLoginVia(widget.idpId))),
      body: ScreenBackground(
        child: AppEmptyState(
          icon: Icons.web,
          title: l10n.ssoLoginVia(widget.idpId),
          message: l10n.ssoFeatureRequired,
        ),
      ),
    );
  }
}
