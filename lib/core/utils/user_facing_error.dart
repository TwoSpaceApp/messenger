import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/error_handler_service.dart';

class UserFacingError {
  UserFacingError._();

  static const String _autoLoginErrorPrefix =
      'auth.register.auto_login_failed::';

  /// Форматировать ошибку для отображения пользователю
  /// Использует новый ErrorHandlerService для лучшей категоризации
  static String format(Object error, [AppLocalizations? l10n]) {
    final structured = ErrorHandlerService.handle(error, context: 'UserFacingError.format');

    if (l10n != null) {
      return ErrorHandlerService.getUserMessage(structured, l10n);
    }

    // Используем очищенное сообщение из StructuredError
    final message = structured.message;

    // Проверяем специфичные коды ошибок
    return _mapSpecificErrors(message, l10n) ?? message;
  }

  /// Маппировать специфичные коды ошибок на локализованные сообщения
  static String? _mapSpecificErrors(String normalized, AppLocalizations? l10n) {
    if (l10n == null) return null;

    switch (normalized) {
      case 'auth.register.verify_email_before_login':
        return l10n.authRegisterVerifyEmailBeforeLogin;
      case 'auth.profile.update_failed':
        return l10n.authProfileUpdateFailed;
      case 'auth.avatar.update_failed':
        return l10n.authAvatarUpdateFailed;
      case 'auth.login.app_credentials_rejected':
        return l10n.authLoginAppCredentialsRejected;
      case 'auth.login.session_token_missing':
        return l10n.authSessionTokenMissing;
      case 'auth.totp.setup_failed':
        return l10n.authTotpSetupFailed;
      case 'auth.totp.disable_failed':
        return l10n.authTotpDisableFailed;
      case 'auth.totp.verify_failed':
        return l10n.authTotpVerifyFailed;
      case 'auth.sessions.list_failed':
        return l10n.authSessionsLoadFailed;
      case 'auth.sessions.revoke_failed':
        return l10n.authSessionsRevokeFailed;
      case 'auth.register.not_logged_in':
        return l10n.authRegisterNotLoggedIn;
      case 'auth.not_authenticated':
        return l10n.errorAuth;
    }

    if (normalized.startsWith(_autoLoginErrorPrefix)) {
      final detail = normalized.substring(_autoLoginErrorPrefix.length);
      return l10n.authRegisterAutoLoginFailed(format(detail, l10n));
    }

    return null;
  }
}
