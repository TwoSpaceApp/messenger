class UserFacingError {
  UserFacingError._();

  static final RegExp _exceptionPrefix = RegExp(r'^[A-Za-z]+Exception:\s*');

  static String format(Object error) {
    final raw = error.toString().trim();
    final cleaned = raw.replaceFirst(_exceptionPrefix, '').trim();
    return cleaned.isEmpty ? raw : cleaned;
  }
}
