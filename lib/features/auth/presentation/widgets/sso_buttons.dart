import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class SsoButtons extends StatelessWidget {
  const SsoButtons({super.key});

  void _handleSsoLogin(String provider) {
    // Handle SSO login for the given provider
  }

  Widget _buildSsoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          UITokens.authProviderButtonHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.width < 500;
    return isSmallScreen
        ? Column(
            children: [
              _buildSsoButton(
                icon: Icons.login,
                label: l10n.continueWithGoogle,
                onPressed: () => _handleSsoLogin('google'),
              ),
              const SizedBox(height: UITokens.space),
              _buildSsoButton(
                icon: Icons.person,
                label: l10n.continueWithYandex,
                onPressed: () => _handleSsoLogin('yandex'),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildSsoButton(
                  icon: Icons.login,
                  label: l10n.continueWithGoogle,
                  onPressed: () => _handleSsoLogin('google'),
                ),
              ),
              const SizedBox(width: UITokens.space),
              Expanded(
                child: _buildSsoButton(
                  icon: Icons.person,
                  label: l10n.continueWithYandex,
                  onPressed: () => _handleSsoLogin('yandex'),
                ),
              ),
            ],
          );
  }
}
