/// Thrown when an async operation exceeds its allowed duration.
class TimeoutException implements Exception {
  TimeoutException(this.message, [this.duration]);

  final String message;
  final Duration? duration;

  @override
  String toString() => 'TimeoutException: $message${duration != null ? ' (took $duration)' : ''}';
}
