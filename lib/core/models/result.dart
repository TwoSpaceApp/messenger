/// Результат операции с возможной ошибкой
class Result<T> {
  Result._({required this.success, this.data, this.error});

  factory Result.ok(T? data) {
    return Result._(data: data, success: true);
  }

  factory Result.err(String error) {
    return Result._(error: error, success: false);
  }
  final T? data;
  final String? error;
  final bool success;
}
