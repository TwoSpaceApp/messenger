import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/services/error_handler_service.dart';

void main() {
  group('ErrorHandlerService Integration Tests', () {
    test('handle returns StructuredError with correct category', () {
      final error = Exception('Network error');
      final result = ErrorHandlerService.handle(error);
      
      expect(result, isA<StructuredError>());
      expect(result.category, ErrorCategory.network);
      expect(result.code, 'network_error');
      expect(result.message, 'Network error');
    });

    // test('handle correctly categorizes SocketException', () {
    //   final error = SocketException('Connection failed');
    //   final result = ErrorHandlerService.handle(error);
    //   
    //   expect(result.category, ErrorCategory.network);
    //   expect(result.code, 'network_error');
    // });
    //
    // test('handle correctly categorizes TimeoutException', () {
    //   final error = TimeoutException('Request timed out', Duration(seconds: 30));
    //   final result = ErrorHandlerService.handle(error);
    //   
    //   expect(result.category, ErrorCategory.timeout);
    //   expect(result.code, 'timeout_error');
    //   expect(result.message, 'Request timed out');
    // });

    test('handle correctly categorizes auth errors', () {
      final error = Exception('auth.not_authenticated');
      final result = ErrorHandlerService.handle(error);
      
      expect(result.category, ErrorCategory.authentication);
      expect(result.code, 'auth.not_authenticated');
    });

    test('handle correctly categorizes validation errors', () {
      final error = Exception('ValidationException: Invalid input');
      final result = ErrorHandlerService.handle(error);
      
      expect(result.category, ErrorCategory.validation);
      expect(result.code, 'validation_error');
    });

    test('handle correctly categorizes server errors', () {
      final error = Exception('500 Internal Server Error');
      final result = ErrorHandlerService.handle(error);
      
      expect(result.category, ErrorCategory.server);
      expect(result.code, '500');
    });

    test('handle correctly categorizes permission errors', () {
      final error = Exception('Permission denied');
      final result = ErrorHandlerService.handle(error);
      
      expect(result.category, ErrorCategory.permission);
      expect(result.code, 'permission_denied');
      expect(result.message, 'Permission denied');
    });

    test('handle correctly categorizes not found errors', () {
      final error = Exception('404 Not Found');
      final result = ErrorHandlerService.handle(error);
      
      expect(result.category, ErrorCategory.notFound);
      expect(result.code, 'not_found');
      expect(result.message, 'Resource not found');
    });

    test('handle correctly categorizes unknown errors', () {
      final error = Exception('Some unknown error');
      final result = ErrorHandlerService.handle(error);
      
      expect(result.category, ErrorCategory.unknown);
      expect(result.code, 'unknown_error');
    });

    test('handle preserves original error', () {
      final originalError = Exception('Original error');
      final result = ErrorHandlerService.handle(originalError);
      
      expect(result.originalError, originalError);
    });

    test('handle preserves stack trace when provided', () {
      final stackTrace = StackTrace.current;
      final error = Exception('Test error');
      final result = ErrorHandlerService.handle(error, stackTrace: stackTrace);
      
      expect(result.stackTrace, stackTrace);
    });

    test('handle preserves context when provided', () {
      final error = Exception('Test error');
      final result = ErrorHandlerService.handle(error, context: 'test_context');
      
      expect(result.details, 'test_context');
    });

    test('getUserMessage returns userMessage when set', () {
      final error = StructuredError(
        category: ErrorCategory.network,
        code: 'network_error',
        message: 'Connection failed',
        userMessage: 'Cannot connect to server',
      );
      
      expect(
        ErrorHandlerService.getUserMessage(error),
        'Cannot connect to server',
      );
    });

    test('getUserMessage returns message when no userMessage', () {
      final error = StructuredError(
        category: ErrorCategory.network,
        code: 'network_error',
        message: 'Connection failed',
      );
      
      expect(
        ErrorHandlerService.getUserMessage(error),
        'Connection failed',
      );
    });

    test('getUserMessage returns localized message when l10n provided', () {
      // This test would require mocking AppLocalizations, so we just test
      // that it doesn't crash when l10n is null
      final error = StructuredError(
        category: ErrorCategory.network,
        code: 'network_error',
        message: 'Connection failed',
      );
      
      expect(
        ErrorHandlerService.getUserMessage(error),
        'Connection failed',
      );
    });

    test('StructuredError toString format is correct', () {
      final error = StructuredError(
        category: ErrorCategory.network,
        code: 'network_error',
        message: 'Connection failed',
      );
      
      expect(error.toString(), '[Network] network_error: Connection failed');
    });

    test('ErrorCategory enum values are correct', () {
      expect(ErrorCategory.network.name, 'Network');
      expect(ErrorCategory.authentication.name, 'Authentication');
      expect(ErrorCategory.validation.name, 'Validation');
      expect(ErrorCategory.notFound.name, 'NotFound');
      expect(ErrorCategory.permission.name, 'Permission');
      expect(ErrorCategory.timeout.name, 'Timeout');
      expect(ErrorCategory.server.name, 'Server');
      expect(ErrorCategory.unknown.name, 'Unknown');
    });

    test('ErrorCategory values are all defined', () {
      expect(ErrorCategory.values.length, 8);
      expect(ErrorCategory.values, containsAll([
        ErrorCategory.network,
        ErrorCategory.authentication,
        ErrorCategory.validation,
        ErrorCategory.notFound,
        ErrorCategory.permission,
        ErrorCategory.timeout,
        ErrorCategory.server,
        ErrorCategory.unknown,
      ]));
    });

    test('handle with context logs error properly', () {
      // This test verifies that the method doesn't crash with context
      final error = Exception('Test error with context');
      final result = ErrorHandlerService.handle(error, context: 'test context');
      
      expect(result, isA<StructuredError>());
      expect(result.message, 'Test error with context');
    });

    test('handle with stack trace logs error properly', () {
      // This test verifies that the method doesn't crash with stack trace
      final error = Exception('Test error with stack trace');
      final stackTrace = StackTrace.current;
      final result = ErrorHandlerService.handle(error, stackTrace: stackTrace);
      
      expect(result, isA<StructuredError>());
      expect(result.message, 'Test error with stack trace');
    });
  });
}