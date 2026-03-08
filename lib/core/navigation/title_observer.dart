import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class TitleObserver extends NavigatorObserver {
  void _updateTitle(Route<dynamic>? route) {
    if (route == null || route.settings.name == null) return;
    
    final context = navigator?.context;
    if (context == null) return;
    
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    String suffix = '';
    final name = route.settings.name!;
    
    if (name == AppStrings.routeLogin) {
      suffix = l10n.loginTitle;
    } else if (name == AppStrings.routeRegister) {
      suffix = l10n.registerTitle;
    } else if (name == AppStrings.routeHome) {
      suffix = l10n.chatsTitle;
    } else if (name == AppStrings.routeCustomization) {
      suffix = l10n.customizationLabel;
    } else if (name == AppStrings.routeProfile) {
      suffix = l10n.profileTitle;
    } else if (name == AppStrings.routeAccountSettings) {
      suffix = l10n.accountSettingsTitle;
    } else if (name.startsWith(AppStrings.routeChat)) {
      suffix = 'Chat'; // Can be improved later if we pass chat title
    } else if (name == AppStrings.routeFeedback) {
      suffix = 'Feedback';
    }
    
    final newTitle = suffix.isNotEmpty ? 'TwoSpace - $suffix' : 'TwoSpace';
    
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: newTitle,
        primaryColor: Theme.of(context).primaryColor.toARGB32(),
      ),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateTitle(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateTitle(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateTitle(newRoute);
  }
}
