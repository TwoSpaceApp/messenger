import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:two_space_app/constants/app_constants.dart';
import 'package:two_space_app/services/dev_logger.dart';

/// Валидатор переменных окружения для безопасного запуска приложения
class EnvironmentValidator {
  static final DevLogger _logger = DevLogger('EnvironmentValidator');

  static bool _isMatrixEnabled() {
    final raw = (dotenv.env['MATRIX_ENABLE'] ?? dotenv.env['USE_MATRIX'] ?? 'true')
        .trim()
        .toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static String? _matrixHomeserverUrl() {
    final v = dotenv.env['MATRIX_HOMESERVER_URL'] ??
        dotenv.env['MATRIX_SERVER_URL'] ??
        dotenv.env['MATRIX_HOMESERVER'];
    final vv = v?.trim();
    if (vv == null || vv.isEmpty) return null;
    return vv;
  }

  /// Проверить все требуемые переменные окружения при старте
  static Future<ValidationResult> validateOnStartup() async {
    try {
      _logger.info('🔍 Начинаем валидацию окружения...');

      final errors = <String>[];
      final warnings = <String>[];

      // Проверка критичных переменных
      // Требуем homeserver URL только если Matrix включён.
      if (_isMatrixEnabled()) {
        final homeserver = _matrixHomeserverUrl();
        if (homeserver == null) {
          warnings.add('⚠️  Matrix включён, но не задан homeserver URL: MATRIX_HOMESERVER_URL (или MATRIX_SERVER_URL/MATRIX_HOMESERVER)');
        }
      }

      // Проверка опциональных переменных
      final optionalVars = ['SENTRY_DSN', 'ANALYTICS_KEY'];
      for (final variable in optionalVars) {
        if (dotenv.env[variable] == null || dotenv.env[variable]!.isEmpty) {
          warnings.add('⚠️  Опциональная переменная не установлена: $variable');
        }
      }

      // Проверка валидности URL
      final homeserver = _matrixHomeserverUrl();
      if (homeserver != null && !_isValidUrl(homeserver)) {
        errors.add('❌ MATRIX_HOMESERVER_URL содержит невалидный URL');
      }

      // Проверка APP_ENV (опционально; если не задан — используется дефолт)
      final validEnvironments = ['development', 'staging', 'production'];
      final appEnv = dotenv.env['APP_ENV']?.trim();
      if (appEnv != null && appEnv.isNotEmpty && !validEnvironments.contains(appEnv)) {
        errors.add('❌ APP_ENV должен быть одним из: ${validEnvironments.join(", ")}');
      }

      // Логирование предупреждений
      for (final warning in warnings) {
        _logger.warning(warning);
      }

      // Логирование ошибок
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
        isValid: isValid,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      _logger.error('🚨 Критическая ошибка при валидации: $e');
      return ValidationResult(
        isValid: false,
        errors: ['Неожиданная ошибка при валидации: $e'],
      );
    }
  }

  /// Получить значение переменной окружения с дефолтным значением
  static String getEnvOrDefault(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Получить значение переменной окружения или null
  static String? getEnv(String key) {
    return dotenv.env[key];
  }

  /// Проверить валидность URL
  static bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// Проверить, находимся ли мы в production
  static bool isProduction() {
    return dotenv.env['APP_ENV'] == 'production';
  }

  /// Проверить, находимся ли мы в development
  static bool isDevelopment() {
    return dotenv.env['APP_ENV'] == 'development';
  }

  /// Получить информацию об окружении для логирования
  static Map<String, String> getEnvironmentInfo() {
    final homeserver = (dotenv.env['MATRIX_HOMESERVER_URL'] ??
            dotenv.env['MATRIX_SERVER_URL'] ??
            dotenv.env['MATRIX_HOMESERVER'])
        ?.trim();

    return {
      'APP_ENV': dotenv.env['APP_ENV'] ?? 'unknown',
      'MATRIX_SERVER': (homeserver == null || homeserver.isEmpty) ? 'not set' : homeserver,
      'VERSION': AppConstants.appVersion,
      'BUILD': AppConstants.buildNumber.toString(),
    };
  }
}

/// Результат валидации окружения
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  @override
  String toString() {
    return '''
ValidationResult(
  isValid: $isValid,
  errors: ${errors.length},
  warnings: ${warnings.length}
)
''';
  }
}
