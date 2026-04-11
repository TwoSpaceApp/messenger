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

      if (Environment.aegisPort <= 0 || Environment.aegisPort > 65535) {
        errors.add('❌ AEGIS_PORT должен быть в диапазоне 1..65535');
      }

      if (Environment.aegisConnectTimeout <= Duration.zero) {
        errors.add('❌ AEGIS_CONNECT_TIMEOUT_SECONDS должен быть больше 0');
      }

      final validEnvironments = ['development', 'staging', 'production'];
      if (Environment.appEnv.isNotEmpty &&
          !validEnvironments.contains(Environment.appEnv)) {
        errors.add(
          '❌ APP_ENV должен быть одним из: ${validEnvironments.join(", ")}',
        );
      }

      warnings.forEach(_logger.warning);
      errors.forEach(_logger.error);

      final isValid = errors.isEmpty;
      if (isValid) {
        _logger.info('✅ Валидация окружения пройдена успешно!');
      } else {
        _logger.error('❌ Валидация окружения завершилась с ошибками');
      }

      return ValidationResult(
        isValid: isValid,
        errors: errors,
        warnings: warnings,
      );
    } on Object catch (error) {
      return ValidationResult(
        isValid: false,
        errors: ['Неожиданная ошибка при валидации: $error'],
      );
    }
  }

  static bool isProduction() => Environment.appEnv == 'production';
  static bool isDevelopment() => Environment.appEnv == 'development';

  static Map<String, String> getEnvironmentInfo() {
    return {
      'APP_ENV': Environment.appEnv.isEmpty ? 'unknown' : Environment.appEnv,
      'AEGIS_SERVER': Environment.aegisHost.isEmpty
          ? 'not set'
          : '${Environment.aegisHost}:${Environment.aegisPort}',
      'VERSION': AppConstants.appVersion,
      'BUILD': AppConstants.buildNumber.toString(),
    };
  }
}

class ValidationResult {
  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
}
