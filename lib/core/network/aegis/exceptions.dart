/// Exception thrown for connection-related errors
class ConnectionException implements Exception {
  final String message;
  final dynamic originalError;

  ConnectionException(this.message, [this.originalError]);

  @override
  String toString() => 'ConnectionException: $message${originalError != null ? ' (caused by: $originalError)' : ''}';
}

/// Exception thrown when client is not connected
class NotConnectedException implements Exception {
  final String message;
  NotConnectedException([this.message = 'Client is not connected to server']);

  @override
  String toString() => 'NotConnectedException: $message';
}

/// Exception thrown for timeout operations
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}
