class UserContentSanitizer {
  UserContentSanitizer._();

  static final RegExp _controlChars = RegExp(
    '[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]',
  );
  static final RegExp _invisibleChars = RegExp('[\u200B-\u200F\uFEFF]');
  static final RegExp _htmlTags = RegExp('<[^>]*>');
  static final RegExp _usernameUnsafeChars = RegExp('[^a-zA-Z0-9_.-]');

  static String sanitizePlainText(
    String? value, {
    int maxLength = 2048,
    bool preserveNewlines = true,
    bool trim = true,
  }) {
    var next = value ?? '';
    next = next.replaceAll(_invisibleChars, '');
    next = next.replaceAll(_controlChars, '');

    if (!preserveNewlines) {
      next = next.replaceAll('\n', ' ').replaceAll('\r', ' ');
    }

    next = next.replaceAll('\r\n', '\n');
    next = next.replaceAll('\r', '\n');
    next = next.replaceAll(RegExp(r'[ \t]+'), ' ');
    next = next.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    if (trim) {
      next = next.trim();
    }

    if (next.length > maxLength) {
      next = next.substring(0, maxLength).trimRight();
    }

    return next;
  }

  static String? sanitizeOptionalText(
    String? value, {
    int maxLength = 2048,
    bool preserveNewlines = true,
    bool trim = true,
  }) {
    final next = sanitizePlainText(
      value,
      maxLength: maxLength,
      preserveNewlines: preserveNewlines,
      trim: trim,
    );
    return next.isEmpty ? null : next;
  }

  static String sanitizeUsername(String? value, {int maxLength = 32}) {
    var next = sanitizePlainText(
      value,
      maxLength: maxLength,
      preserveNewlines: false,
    ).replaceFirst('@', '');
    next = next.replaceAll(_usernameUnsafeChars, '');
    if (next.length > maxLength) {
      next = next.substring(0, maxLength);
    }
    return next;
  }

  static String sanitizeRichTextDisplay(
    String? value, {
    String? parseMode,
    int maxLength = 4000,
  }) {
    var next = sanitizePlainText(
      value,
      maxLength: maxLength * 2,
      trim: false,
    );
    if ((parseMode ?? '').toLowerCase() == 'html') {
      next = next.replaceAll(_htmlTags, ' ');
    }
    return sanitizePlainText(
      next,
      maxLength: maxLength,
    );
  }
}
