import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text('SSO — ${widget.idpId}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.ssoLoginVia(widget.idpId)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.ssoFeatureRequired),
          ],
        ),
      ),
    );
  }
}
