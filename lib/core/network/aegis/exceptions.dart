/// Exception thrown for connection-related errors
class ConnectionException implements Exception {

  ConnectionException(this.message, [this.originalError]);
  final String message;
  final dynamic originalError;

  @override
  String toString() => 'ConnectionException: $message${originalError != null ? ' (caused by: $originalError)' : ''}';
}

/// Exception thrown when client is not connected
class NotConnectedException implements Exception {
  NotConnectedException([this.message = "Client is not connected to server"]);
  final String message;

  @override
  String toString() => 'NotConnectedException: $message';
}

/// Exception thrown for timeout operations
class TimeoutException implements Exception {

  TimeoutException(this.message, this.timeout);
  final String message;
  final Duration timeout;

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}
