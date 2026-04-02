import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_surface.dart';
// import 'dart:async';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:two_space_app/core/config/environment.dart';
// import 'package:two_space_app/features/auth/data/services/auth_service.dart';

class SsoWebviewScreen extends StatefulWidget {
  // e.g. 'google' or 'yandex'
  const SsoWebviewScreen({required this.idpId, super.key});
  final String idpId;

  @override
  State<SsoWebviewScreen> createState() => _SsoWebviewScreenState();
}

class _SsoWebviewScreenState extends State<SsoWebviewScreen> {
  // WebViewController not available, using placeholder

  void _close() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text('SSO — ${widget.idpId}')),
      body: AuthSurface(
        icon: Icons.language_rounded,
        title: l10n.ssoLoginVia(widget.idpId),
        subtitle: l10n.ssoFeatureRequired,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Center(
              child: ShadBadge.secondary(
                child: Text(widget.idpId.toUpperCase()),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ssoFeatureRequired,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ShadButton.outline(
              onPressed: _close,
              width: double.infinity,
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
