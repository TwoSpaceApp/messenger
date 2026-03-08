import 'dart:async';

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
    this.headers = const {},
  });
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final int? statusCode;
  final int latencyMs;
  final dynamic requestBody;
  final dynamic responseBody;
  final Map<String, dynamic> headers;
}

class DevNetworkLogger {
  DevNetworkLogger._internal();
  static final DevNetworkLogger instance = DevNetworkLogger._internal();

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
    Map<String, dynamic> headers = const {},
  }) {
    final log = DevNetworkLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      method: method.toUpperCase(),
      url: url,
      statusCode: statusCode,
      latencyMs: latencyMs,
      requestBody: requestBody,
      responseBody: responseBody,
      headers: headers,
    );

    _logs.insert(0, log);
    if (_logs.length > 200) {
      _logs.removeLast();
    }
    _controller.add(_logs);
  }

  void clear() {
    _logs.clear();
    _controller.add(_logs);
  }
}
