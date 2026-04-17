import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/dev_logger.dart';

/// Типы ошибок для категоризации
enum ErrorCategory {
  network('Network'),
  authentication('Authentication'),
  validation('Validation'),
  notFound('NotFound'),
  permission('Permission'),
  timeout('Timeout'),
  server('Server'),
  unknown('Unknown');

  final String name;
  const ErrorCategory(this.name);
}

/// Структурированная ошибка с контекстом
class StructuredError {
  StructuredError({
    required this.category,
    required this.code,
    required this.message,
    this.userMessage,
    this.details,
    this.stackTrace,
    this.originalError,
  });

  final ErrorCategory category;
  final String code;
  final String message;
  final String? userMessage;
  final String? details;
  final StackTrace? stackTrace;
  final Object? originalError;

  @override
  String toString() => 'StructuredError($category, $code): $message';
}

/// Сервис для централизованной обработки и логирования ошибок
class ErrorHandlerService {
  static final DevLogger _logger = DevLogger('ErrorHandler');

  /// Обработать ошибку и вернуть структурированный результат
  static StructuredError handle(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    AppLocalizations? l10n,
  }) {
    final structured = _parseError(error, stackTrace, context);
    _logError(structured, context);
    return structured;
  }

  /// Получить пользовательское сообщение об ошибке
  static String getUserMessage(
    StructuredError error, [
    AppLocalizations? l10n,
  ]) {
    if (error.userMessage != null) {
      return error.userMessage!;
    }

    if (l10n != null) {
      return _mapErrorToLocalizedMessage(error, l10n);
    }

    return error.message;
  }

  /// Парсить ошибку и определить её категорию
  static StructuredError _parseError(
    Object error,
    StackTrace? stackTrace,
    String? context,
  ) {
    final errorString = error.toString().trim();

    // Проверка на сетевые ошибки
    if (_isNetworkError(errorString)) {
      return StructuredError(
        category: ErrorCategory.network,
        code: 'network_error',
        message: errorString,
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Проверка на ошибки аутентификации
    if (_isAuthError(errorString)) {
      return StructuredError(
        category: ErrorCategory.authentication,
        code: _extractAuthErrorCode(errorString),
        message: errorString,
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Проверка на ошибки валидации
    if (_isValidationError(errorString)) {
      return StructuredError(
        category: ErrorCategory.validation,
        code: 'validation_error',
        message: errorString,
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Проверка на ошибки timeout
    if (_isTimeoutError(errorString)) {
      return StructuredError(
        category: ErrorCategory.timeout,
        code: 'timeout_error',
        message: 'Request timed out',
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Проверка на ошибки сервера
    if (_isServerError(errorString)) {
      return StructuredError(
        category: ErrorCategory.server,
        code: _extractServerErrorCode(errorString),
        message: errorString,
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Проверка на ошибки прав доступа
    if (_isPermissionError(errorString)) {
      return StructuredError(
        category: ErrorCategory.permission,
        code: 'permission_denied',
        message: 'Permission denied',
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Проверка на ошибки "не найдено"
    if (_isNotFoundError(errorString)) {
      return StructuredError(
        category: ErrorCategory.notFound,
        code: 'not_found',
        message: 'Resource not found',
        details: context,
        stackTrace: stackTrace,
        originalError: error,
      );
    }

    // Неизвестная ошибка
    return StructuredError(
      category: ErrorCategory.unknown,
      code: 'unknown_error',
      message: errorString,
      details: context,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  /// Логировать ошибку с полной информацией
  static void _logError(StructuredError error, String? context) {
    final contextStr = context != null ? ' (context: $context)' : '';
    final detailsStr = error.details != null ? '\nDetails: ${error.details}' : '';

    _logger.error(
      '[${error.category.name}] ${error.code}: ${error.message}$contextStr$detailsStr',
    );

    if (error.stackTrace != null && kDebugMode) {
      _logger.error('StackTrace: ${error.stackTrace}');
    }
  }

  /// Маппировать ошибку на локализованное сообщение
  static String _mapErrorToLocalizedMessage(
    StructuredError error,
    AppLocalizations l10n,
  ) {
    switch (error.category) {
      case ErrorCategory.network:
        return l10n.errorNetwork;
      case ErrorCategory.authentication:
        return l10n.errorAuth;
      case ErrorCategory.validation:
        return l10n.errorInvalidArguments;
      case ErrorCategory.timeout:
        return 'Request timed out. Please try again.';
      case ErrorCategory.server:
        return 'Server error. Please try again later.';
      case ErrorCategory.permission:
        return 'You do not have permission to perform this action.';
      case ErrorCategory.notFound:
        return 'The requested resource was not found.';
      case ErrorCategory.unknown:
        return l10n.errorGeneric;
    }
  }

  // Вспомогательные методы для определения типа ошибки
  static bool _isNetworkError(String error) {
    return error.contains('SocketException') ||
        error.contains('NetworkException') ||
        error.contains('Connection refused') ||
        error.contains('Failed to connect') ||
        error.contains('No internet') ||
        error.contains('Connection timeout') ||
        error.contains('Connection reset');
  }

  static bool _isAuthError(String error) {
    return error.contains('auth.') ||
        error.contains('not_authenticated') ||
        error.contains('session_token_missing') ||
        error.contains('Unauthorized') ||
        error.contains('401');
  }

  static bool _isValidationError(String error) {
    return error.contains('ValidationException') ||
        error.contains('Invalid') ||
        error.contains('validation');
  }

  static bool _isTimeoutError(String error) {
    return error.contains('TimeoutException') ||
        error.contains('timeout') ||
        error.contains('Timeout');
  }

  static bool _isServerError(String error) {
    return error.contains('500') ||
        error.contains('502') ||
        error.contains('503') ||
        error.contains('ServerException') ||
        error.contains('Internal Server Error');
  }

  static bool _isPermissionError(String error) {
    return error.contains('Permission') ||
        error.contains('Forbidden') ||
        error.contains('403');
  }

  static bool _isNotFoundError(String error) {
    return error.contains('404') ||
        error.contains('NotFound') ||
        error.contains('not found');
  }

  static String _extractAuthErrorCode(String error) {
    final match = RegExp(r'auth\.[\w.]+').firstMatch(error);
    return match?.group(0) ?? 'auth_error';
  }

  static String _extractServerErrorCode(String error) {
    final match = RegExp(r'(\d{3})').firstMatch(error);
    return match?.group(0) ?? 'server_error';
  }
}
