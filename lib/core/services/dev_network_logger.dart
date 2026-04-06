import 'dart:async';

import 'package:two_space_app/core/services/dev_sensitive_data_policy.dart';

enum DevNetworkLogKind {
  success,
  redirect,
  clientError,
  serverError,
  networkError,
}

enum DevNetworkBodyType {
  empty,
  json,
  text,
  form,
  binary,
  unknown,
}

class DevNetworkLog {
  DevNetworkLog({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    required this.latencyMs,
    this.statusCode,
    this.requestBody,
    this.responseBody,
    this.requestHeaders = const {},
    this.responseHeaders = const {},
    this.errorMessage,
  });
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final int? statusCode;
  final int latencyMs;
  final dynamic requestBody;
  final dynamic responseBody;
  final Map<String, dynamic> requestHeaders;
  final Map<String, dynamic> responseHeaders;
  final String? errorMessage;

  bool get isError =>
      kind == DevNetworkLogKind.clientError ||
      kind == DevNetworkLogKind.serverError ||
      kind == DevNetworkLogKind.networkError;

  DevNetworkLogKind get kind {
    if (statusCode == null) return DevNetworkLogKind.networkError;
    if (statusCode! >= 500) return DevNetworkLogKind.serverError;
    if (statusCode! >= 400) return DevNetworkLogKind.clientError;
    if (statusCode! >= 300) return DevNetworkLogKind.redirect;
    return DevNetworkLogKind.success;
  }

  DevNetworkBodyType get requestBodyType => _detectBodyType(requestBody);
  DevNetworkBodyType get responseBodyType =>
      _detectBodyType(errorMessage ?? responseBody);

  String get statusLabel {
    if (statusCode == null) return 'NO RESPONSE';
    return statusCode.toString();
  }

  String get kindLabel {
    switch (kind) {
      case DevNetworkLogKind.success:
        return 'SUCCESS';
      case DevNetworkLogKind.redirect:
        return 'REDIRECT';
      case DevNetworkLogKind.clientError:
        return 'CLIENT';
      case DevNetworkLogKind.serverError:
        return 'SERVER';
      case DevNetworkLogKind.networkError:
        return 'NETWORK';
    }
  }

  String get requestTypeLabel => _bodyTypeLabel(requestBodyType);
  String get responseTypeLabel => _bodyTypeLabel(responseBodyType);

  static DevNetworkBodyType _detectBodyType(dynamic body) {
    if (body == null) return DevNetworkBodyType.empty;
    if (body is Map || body is List) return DevNetworkBodyType.json;
    if (body is List<int>) return DevNetworkBodyType.binary;
    if (body is String) {
      final trimmed = body.trim();
      if (trimmed.isEmpty) return DevNetworkBodyType.empty;
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        return DevNetworkBodyType.json;
      }
      if (trimmed.contains('=')) return DevNetworkBodyType.form;
      return DevNetworkBodyType.text;
    }
    return DevNetworkBodyType.unknown;
  }

  static String _bodyTypeLabel(DevNetworkBodyType type) {
    switch (type) {
      case DevNetworkBodyType.empty:
        return 'EMPTY';
      case DevNetworkBodyType.json:
        return 'JSON';
      case DevNetworkBodyType.text:
        return 'TEXT';
      case DevNetworkBodyType.form:
        return 'FORM';
      case DevNetworkBodyType.binary:
        return 'BINARY';
      case DevNetworkBodyType.unknown:
        return 'UNKNOWN';
    }
  }
}

class DevNetworkLogger {
  DevNetworkLogger._internal();
  static final DevNetworkLogger instance = DevNetworkLogger._internal();
  static const int _maxEntries = 1000;

  final List<DevNetworkLog> _logs = [];
  final _controller = StreamController<List<DevNetworkLog>>.broadcast();

  Stream<List<DevNetworkLog>> get logsStream => _controller.stream;
  List<DevNetworkLog> get logs => List.unmodifiable(_logs);

  void logRequest({
    required String method,
    required String url,
    int? statusCode,
    int latencyMs = 0,
    dynamic requestBody,
    dynamic responseBody,
    Map<String, dynamic> requestHeaders = const {},
    Map<String, dynamic> responseHeaders = const {},
    String? errorMessage,
  }) {
    final safeUrl = DebugDataSanitizer.sanitizeText(url);
    final safeRequestHeaders = DebugDataSanitizer.sanitizeMap(requestHeaders);
    final safeResponseHeaders = DebugDataSanitizer.sanitizeMap(responseHeaders);
    final safeRequestBody = DebugDataSanitizer.sanitizeStructured(requestBody);
    final safeResponseBody = DebugDataSanitizer.sanitizeStructured(responseBody);
    final safeErrorMessage = errorMessage == null
        ? null
        : DebugDataSanitizer.sanitizeText(errorMessage);

    final log = DevNetworkLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      method: method.toUpperCase(),
      url: safeUrl,
      statusCode: statusCode,
      latencyMs: latencyMs,
      requestBody: safeRequestBody,
      responseBody: safeResponseBody,
      requestHeaders: safeRequestHeaders,
      responseHeaders: safeResponseHeaders,
      errorMessage: safeErrorMessage,
    );

    _logs.insert(0, log);
    if (_logs.length > _maxEntries) {
      _logs.removeLast();
    }
    _controller.add(List<DevNetworkLog>.unmodifiable(_logs));
  }

  void clear() {
    _logs.clear();
    _controller.add(List<DevNetworkLog>.unmodifiable(_logs));
  }
}
