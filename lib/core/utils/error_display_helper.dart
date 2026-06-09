import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/services/error_handler_service.dart';

/// Хелпер для отображения ошибок пользователю
class ErrorDisplayHelper {
  static final DevLogger _logger = DevLogger('ErrorDisplay');

  /// Показать ошибку в SnackBar
  static void showErrorSnackBar(
    BuildContext context,
    Object error, {
    String? context_,
    Duration duration = const Duration(seconds: 4),
  }) {
    final l10n = AppLocalizations.of(context);
    final structured = ErrorHandlerService.handle(
      error,
      context: context_,
    );
    final message = ErrorHandlerService.getUserMessage(structured, l10n);

    _logger.debug('Showing error snackbar: $message');

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Показать ошибку в диалоге
  static Future<void> showErrorDialog(
    BuildContext context,
    Object error, {
    String? title,
    String? context_,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      _logger.error('Localization not available in context');
      return;
    }
    
    final structured = ErrorHandlerService.handle(
      error,
      context: context_,
    );
    final message = ErrorHandlerService.getUserMessage(structured, l10n);

    _logger.debug('Showing error dialog: $message');

    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title ?? l10n.errorGeneric),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  /// Обработать ошибку и показать уведомление
  static void handleAndNotify(
    BuildContext context,
    Object error, {
    String? context_,
    bool useDialog = false,
    String? dialogTitle,
  }) {
    _logger.error('Error occurred: $error');

    if (useDialog) {
      // Fire-and-forget; dialog result not needed
      // ignore: discarded_futures
      showErrorDialog(
        context,
        error,
        title: dialogTitle,
        context_: context_,
      );
    } else {
      showErrorSnackBar(
        context,
        error,
        context_: context_,
      );
    }
  }

  /// Получить локализованное сообщение об ошибке
  static String getErrorMessage(
    Object error,
    AppLocalizations l10n, {
    String? context_,
  }) {
    final structured = ErrorHandlerService.handle(
      error,
      context: context_,
    );
    return ErrorHandlerService.getUserMessage(structured, l10n);
  }

  /// Логировать ошибку с полным контекстом
  static void logError(
    Object error,
    StackTrace? stackTrace, {
    String? context_,
    String? userMessage,
  }) {
    final structured = ErrorHandlerService.handle(
      error,
      stackTrace: stackTrace,
      context: context_,
    );

    _logger.structuredException(
      userMessage ?? 'Error occurred',
      error,
      stackTrace,
      category: structured.category.name,
      code: structured.code,
      details: structured.details,
    );
  }
}
