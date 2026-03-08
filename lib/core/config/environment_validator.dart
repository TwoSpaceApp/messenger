import 'dart:async';

import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/constants/app_constants.dart';
import 'package:two_space_app/core/services/dev_logger.dart';

class EnvironmentValidator {
  static final DevLogger _logger = DevLogger('EnvironmentValidator');

  static Future<ValidationResult> validateOnStartup() async {
    try {
      _logger.info('🔍 Начинаем валидацию окружения...');
      final errors = <String>[];
      final warnings = <String>[];

      if (Environment.useMatrix) {
        if (Environment.matrixHomeserverUrl.isEmpty) {
          warnings.add('⚠️  Matrix включён, но не задан homeserver URL');
        }
      }

      if (Environment.sentryDsn.isEmpty) {
        warnings.add('⚠️  Опциональная переменная не установлена: SENTRY_DSN');
      }

      if (Environment.matrixHomeserverUrl.isNotEmpty &&
          !_isValidUrl(Environment.matrixHomeserverUrl)) {
        errors.add('❌ MATRIX_HOMESERVER_URL содержит невалидный URL');
      }

      final validEnvironments = ['development', 'staging', 'production'];
      if (Environment.appEnv.isNotEmpty &&
          !validEnvironments.contains(Environment.appEnv)) {
        errors.add(
            '❌ APP_ENV должен быть одним из: ${validEnvironments.join(", ")}');
      }

      for (final warning in warnings) {
        _logger.warning(warning);
      }
      for (final error in errors) {
        _logger.error(error);
      }

      final isValid = errors.isEmpty;
      if (isValid) {
        _logger.info('✅ Валидация окружения пройдена успешно!');
      } else {
        _logger.error('❌ Валидация окружения завершилась с ошибками');
      }

      return ValidationResult(
          isValid: isValid, errors: errors, warnings: warnings);
    } catch (e) {
      return ValidationResult(
          isValid: false, errors: ['Неожиданная ошибка при валидации: $e']);
    }
  }

  static bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  static bool isProduction() => Environment.appEnv == 'production';
  static bool isDevelopment() => Environment.appEnv == 'development';

  static Map<String, String> getEnvironmentInfo() {
    return {
      'APP_ENV': Environment.appEnv.isEmpty ? 'unknown' : Environment.appEnv,
      'MATRIX_SERVER': Environment.matrixHomeserverUrl.isEmpty
          ? 'not set'
          : Environment.matrixHomeserverUrl,
      'VERSION': AppConstants.appVersion,
      'BUILD': AppConstants.buildNumber.toString(),
    };
  }
}

class ValidationResult {
  ValidationResult(
      {required this.isValid,
      this.errors = const [],
      this.warnings = const []});
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
}
