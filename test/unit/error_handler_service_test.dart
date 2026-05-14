import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/services/error_handler_service.dart';
import 'package:two_space_app/core/services/time_out_exception.dart'
    as service_timeout;

void main() {
  group("ErrorCategory", () {
    test("all categories are defined", () {
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

    test("each category has a name", () {
      for (final category in ErrorCategory.values) {
        expect(category.name, isNotEmpty);
      }
    });
  });

  group("StructuredError", () {
    test("toString includes category, code and message", () {
      final error = StructuredError(
        category: ErrorCategory.network,
        code: "network_error",
        message: "Connection failed",
      );
      expect(error.toString(), "[Network] network_error: Connection failed");
    });

    test("toString includes userMessage when set", () {
      final error = StructuredError(
        category: ErrorCategory.authentication,
        code: "auth_error",
        message: "Unauthorized",
        userMessage: "Please log in again",
      );
      expect(error.userMessage, "Please log in again");
    });

    test("all fields are accessible", () {
      final stackTrace = StackTrace.current;
      final error = StructuredError(
        category: ErrorCategory.validation,
        code: "validation_error",
        message: "Invalid input",
        userMessage: "Wrong format",
        details: "Testing context",
        stackTrace: stackTrace,
        originalError: const FormatException("bad"),
      );
      expect(error.category, ErrorCategory.validation);
      expect(error.code, "validation_error");
      expect(error.message, "Invalid input");
      expect(error.userMessage, "Wrong format");
      expect(error.details, "Testing context");
      expect(error.stackTrace, stackTrace);
      expect(error.originalError, isA<FormatException>());
    });
  });

  group("ErrorHandlerService.handle", () {
    test("returns a StructuredError", () {
      final result = ErrorHandlerService.handle(
        Exception("test"),
        context: "test_context",
      );
      expect(result, isA<StructuredError>());
    });

    test("network error is detected from SocketException", () {
      final error = ErrorHandlerService.handle(
        const io.SocketException("Connection failed"),
        context: "test",
      );
      expect(error.category, ErrorCategory.network);
      expect(error.code, "network_error");
    });

    test("network error is detected from Connection refused", () {
      final error = ErrorHandlerService.handle(
        Exception("Connection refused"),
        context: "test",
      );
      expect(error.category, ErrorCategory.network);
      expect(error.code, "network_error");
    });

    test("network error is detected from NetworkException", () {
      final error = ErrorHandlerService.handle(
        Exception("NetworkException occurred"),
        context: "test",
      );
      expect(error.category, ErrorCategory.network);
    });

    test("authentication error is detected from auth. prefix", () {
      final error = ErrorHandlerService.handle(
        Exception("auth.not_authenticated"),
        context: "test",
      );
      expect(error.category, ErrorCategory.authentication);
      expect(error.code, "auth.not_authenticated");
    });

    test("authentication error is detected from not_authenticated", () {
      final error = ErrorHandlerService.handle(
        Exception("not_authenticated error"),
        context: "test",
      );
      expect(error.category, ErrorCategory.authentication);
    });

    test("authentication error is detected from Unauthorized", () {
      final error = ErrorHandlerService.handle(
        Exception("Unauthorized"),
        context: "test",
      );
      expect(error.category, ErrorCategory.authentication);
    });

    test("validation error is detected from ValidationException", () {
      final error = ErrorHandlerService.handle(
        Exception("ValidationException: invalid input"),
        context: "test",
      );
      expect(error.category, ErrorCategory.validation);
      expect(error.code, "validation_error");
    });

    test("timeout error is detected from dart async TimeoutException", () {
      final error = ErrorHandlerService.handle(
        TimeoutException("timed out after 30s"),
        context: "test",
      );
      expect(error.category, ErrorCategory.timeout);
      expect(error.code, "timeout_error");
      expect(error.message, "Request timed out");
    });

    test("timeout error is detected from custom TimeoutException", () {
      final error = ErrorHandlerService.handle(
        service_timeout.TimeoutException("step timed out"),
        context: "test",
      );
      expect(error.category, ErrorCategory.timeout);
    });

    test("server error is detected from 500 status", () {
      final error = ErrorHandlerService.handle(
        Exception("500 Internal Server Error"),
        context: "test",
      );
      expect(error.category, ErrorCategory.server);
    });

    test("server error is detected from ServerException", () {
      final error = ErrorHandlerService.handle(
        Exception("ServerException occurred"),
        context: "test",
      );
      expect(error.category, ErrorCategory.server);
    });

    test("server error extracts server code", () {
      final error = ErrorHandlerService.handle(
        Exception("503 Service Unavailable"),
        context: "test",
      );
      expect(error.code, "503");
    });

    test("permission error is detected from Permission denied", () {
      final error = ErrorHandlerService.handle(
        Exception("Permission denied"),
        context: "test",
      );
      expect(error.category, ErrorCategory.permission);
      expect(error.code, "permission_denied");
      expect(error.message, "Permission denied");
    });

    test("permission error is detected from Forbidden", () {
      final error = ErrorHandlerService.handle(
        Exception("Forbidden"),
        context: "test",
      );
      expect(error.category, ErrorCategory.permission);
    });

    test("permission error is detected from 403", () {
      final error = ErrorHandlerService.handle(
        Exception("You got 403"),
        context: "test",
      );
      expect(error.category, ErrorCategory.permission);
    });

    test("not found error is detected from 404", () {
      final error = ErrorHandlerService.handle(
        Exception("Resource 404"),
        context: "test",
      );
      expect(error.category, ErrorCategory.notFound);
      expect(error.code, "not_found");
      expect(error.message, "Resource not found");
    });

    test("not found error is detected from NotFound", () {
      final error = ErrorHandlerService.handle(
        Exception("NotFound"),
        context: "test",
      );
      expect(error.category, ErrorCategory.notFound);
    });

    test("unknown error catches unrecognized errors", () {
      final error = ErrorHandlerService.handle(
        Exception("Some random error"),
        context: "test",
      );
      expect(error.category, ErrorCategory.unknown);
      expect(error.code, "unknown_error");
    });

    test("stackTrace is preserved in structured error", () {
      final trace = StackTrace.current;
      final error = ErrorHandlerService.handle(
        Exception("test"),
        stackTrace: trace,
        context: "test",
      );
      expect(error.stackTrace, trace);
    });

    test("originalError is preserved", () {
      const original = FormatException("bad format");
      final error = ErrorHandlerService.handle(
        original,
        context: "test",
      );
      expect(error.originalError, original);
    });
  });

  group("ErrorHandlerService.getUserMessage", () {
    test("returns userMessage when set", () {
      final error = StructuredError(
        category: ErrorCategory.network,
        code: "network_error",
        message: "Connection failed",
        userMessage: "Can't connect to server",
      );
      expect(
        ErrorHandlerService.getUserMessage(error),
        "Can't connect to server",
      );
    });

    test("returns message when no userMessage and no l10n", () {
      final error = StructuredError(
        category: ErrorCategory.unknown,
        code: "unknown_error",
        message: "Something went wrong",
      );
      expect(
        ErrorHandlerService.getUserMessage(error),
        "Something went wrong",
      );
    });
  });
}