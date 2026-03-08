import 'package:two_space_app/core/l10n/app_localizations.dart'
    show AppLocalizations;

/// Route path constants for the app.
///
/// UI strings (loading, errors, button labels, etc.) are defined in
/// lib/l10n/app_*.arb and accessed via [AppLocalizations]:
///   AppLocalizations.of(context).loading
///   AppLocalizations.of(context).save
///   — and so on.
class AppStrings {
  AppStrings._();

  // Routes
  static const routeSplash = '/splash';
  static const routeLogin = '/login';
  static const routeHome = '/home';
  static const routeRegister = '/register';
  static const routeForgot = '/forgot';
  static const routeCustomization = '/customization';
  static const routePrivacy = '/privacy';
  static const routeProfile = '/profile';
  static const routeChangeEmail = '/change_email';
  static const routeChat = '/chat';
  static const routeAccountSettings = '/account-settings';
  static const routeFeedback = '/feedback';
}
