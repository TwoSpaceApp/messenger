import 'dart:convert';

import 'package:flutter/foundation.dart';

class DevSensitiveDataPolicy {
  DevSensitiveDataPolicy._();

  static final ValueNotifier<bool> revealSensitiveDataForNewLogs =
      ValueNotifier(false);

  static bool get canRevealSensitiveData => kDebugMode;

  static bool get revealSensitiveData =>
      canRevealSensitiveData && revealSensitiveDataForNewLogs.value;

  static void setRevealSensitiveData(bool value) {
    revealSensitiveDataForNewLogs.value = canRevealSensitiveData && value;
  }
}

class DebugDataSanitizer {
  DebugDataSanitizer._();

  static const String redactedPlaceholder = '[redacted]';

  static const Set<String> _sensitiveKeyTokens = <String>{
    'access_token',
    'accesskey',
    'api_key',
    'app_hash',
    'app_pin',
    'apphash',
    'authorization',
    'bearer',
    'biometric',
    'cookie',
    'passcode',
    'password',
    'pin',
    'private_key',
    'privatekey',
    'public_key',
    'publickey',
    'refresh_token',
    'secret',
    'sessiontoken',
    'session_token',
    'set-cookie',
    'token',
    'totp',
    'x-auth-token',
  };

  static final RegExp _jsonSensitiveFieldPattern = RegExp(
    r'("[^"]*(?:token|secret|password|passcode|pin|cookie|key|authorization|sessiontoken|totp|biometric|apphash)[^"]*"\s*:\s*)("[^"]*"|[^,}\]]+)',
    caseSensitive: false,
  );

  static final RegExp _namedValuePattern = RegExp(
    r'(\b(?:authorization|access[_-]?token|refresh[_-]?token|session[_-]?token|sessiontoken|password|passcode|pin|secret|private[_-]?key|public[_-]?key|api[_-]?key|app[_-]?hash|cookie|set-cookie|totp(?:[_-]?secret)?|x-auth-token)\b\s*[:=]\s*)([^\s,;]+)',
    caseSensitive: false,
  );

  static final RegExp _bearerPattern = RegExp(
    r'\b(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+',
    caseSensitive: false,
  );

  static final RegExp _urlSensitiveParamPattern = RegExp(
    '([?&](?:access_token|refresh_token|session_token|sessiontoken|token|secret|password|passcode|pin|private_key|public_key|api_key|app_hash|code)=)([^&#]+)',
    caseSensitive: false,
  );

  static String sanitizeText(String value) {
    if (value.isEmpty || DevSensitiveDataPolicy.revealSensitiveData) {
      return value;
    }

    var sanitized = value;
    sanitized = sanitized.replaceAllMapped(
      _bearerPattern,
      (match) => '${match.group(1)} $redactedPlaceholder',
    );
    sanitized = sanitized.replaceAllMapped(
      _namedValuePattern,
      (match) => '${match.group(1)}$redactedPlaceholder',
    );
    sanitized = sanitized.replaceAllMapped(
      _jsonSensitiveFieldPattern,
      (match) => '${match.group(1)}"$redactedPlaceholder"',
    );
    sanitized = sanitized.replaceAllMapped(
      _urlSensitiveParamPattern,
      (match) => '${match.group(1)}$redactedPlaceholder',
    );
    return sanitized;
  }

  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> value) {
    if (DevSensitiveDataPolicy.revealSensitiveData) {
      return value;
    }

    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key: sanitizeStructured(entry.value, keyHint: entry.key),
    };
  }

  static dynamic sanitizeStructured(dynamic value, {String? keyHint}) {
    if (DevSensitiveDataPolicy.revealSensitiveData) {
      return value;
    }

    if (_isSensitiveKey(keyHint)) {
      return _maskValue(value);
    }

    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString(): sanitizeStructured(
            entry.value,
            keyHint: entry.key.toString(),
          ),
      };
    }

    if (value is List) {
      return value
          .map((item) => sanitizeStructured(item, keyHint: keyHint))
          .toList(growable: false);
    }

    if (value is String) {
      return sanitizeText(value);
    }

    if (value is num || value is bool || value == null) {
      return value;
    }

    try {
      return sanitizeText(jsonEncode(value));
    } on Object catch (_) {
      return sanitizeText(value.toString());
    }
  }

  static bool _isSensitiveKey(String? key) {
    if (key == null || key.isEmpty) {
      return false;
    }

    final normalized = key.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '');
    return _sensitiveKeyTokens.any(
      (token) => normalized.contains(token.replaceAll(RegExp('[^a-z0-9]+'), '')),
    );
  }

  static dynamic _maskValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value.isEmpty ? '' : '$redactedPlaceholder:${value.length}';
    }
    if (value is List) {
      return '$redactedPlaceholder:${value.length}';
    }
    if (value is Map) {
      return '$redactedPlaceholder:${value.length}';
    }
    return redactedPlaceholder;
  }
}
