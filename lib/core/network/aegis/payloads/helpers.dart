import 'dart:convert';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/utils/user_content_sanitizer.dart';

class ParsedRichText {
  ParsedRichText({required this.text, this.parseMode});
  final String text;
  final String? parseMode;
}

ParsedRichText parseRichTextContent(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map<String, dynamic>) {
      final kind = (decoded['Kind'] as String?)?.toLowerCase();
      if (kind == 'rich-text' || kind == 'bot-rich-text') {
        final text = decoded['Text'] as String? ?? '';
        final parseMode = decoded['ParseMode'] as String?;
        return ParsedRichText(
          text: UserContentSanitizer.sanitizeRichTextDisplay(
            text,
            parseMode: parseMode,
          ),
          parseMode: (parseMode?.toLowerCase() == ParseMode.html.value)
              ? null
              : parseMode,
        );
      }
    }
  } catch (_) {
    // Content is plain text.
  }

  return ParsedRichText(
    text: UserContentSanitizer.sanitizeRichTextDisplay(content),
  );
}

dynamic normalizeMsgPack(dynamic value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), normalizeMsgPack(v)),
    );
  }
  if (value is List) {
    return value.map(normalizeMsgPack).toList();
  }
  return value;
}

Map<String, dynamic> decodePayloadMap(List<int> bytes) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  if (data.isEmpty) {
    return <String, dynamic>{};
  }

  final firstByte = data.first;
  if (firstByte == 0x7b || firstByte == 0x5b) {
    return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
  }

  final raw = msgpack.deserialize(data);
  return Map<String, dynamic>.from(normalizeMsgPack(raw) as Map);
}

int parseIntValue(dynamic value, {required String fieldName}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('Unsupported int value for $fieldName: $value');
}

int? parseNullableIntValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool parseBoolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

List<int> parseIntList(dynamic value) {
  if (value is! List) {
    return const <int>[];
  }

  return value
      .map(parseNullableIntValue)
      .whereType<int>()
      .toList(growable: false);
}

DateTime parseDateTimeValue(dynamic value) {
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String) {
    return DateTime.parse(value).toUtc();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }

  throw FormatException('Unsupported DateTime value: $value');
}

DateTime? parseNullableDateTimeValue(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'null') {
      return null;
    }
  }

  return parseDateTimeValue(value);
}

/// Normalized response for unified media sending API.
class MediaSendResponse {
  MediaSendResponse({
    required this.success,
    this.messageId = 0,
    this.messageText,
  });
  final bool success;
  final int messageId;
  final String? messageText;
}

/// Binary attachment payload for media/file messages.
class MediaAttachmentPayload {
  MediaAttachmentPayload({
    required this.fileName,
    required this.mimeType,
    required this.base64Data,
    this.sizeBytes,
  });

  factory MediaAttachmentPayload.fromJson(Map<String, dynamic> json) =>
      MediaAttachmentPayload(
        fileName: json["FileName"] as String,
        mimeType: json["MimeType"] as String,
        base64Data: json["Base64Data"] as String,
        sizeBytes: json["SizeBytes"] as int?,
      );
  final String fileName;
  final String mimeType;
  final String base64Data;
  final int? sizeBytes;

  Map<String, dynamic> toJson() => {
    'FileName': fileName,
    'MimeType': mimeType,
    'Base64Data': base64Data,
    if (sizeBytes != null) 'SizeBytes': sizeBytes,
  };
}

/// Parsed media payload extracted from message content JSON envelope.
class ParsedMediaAttachment {
  ParsedMediaAttachment({
    required this.fileName,
    required this.mimeType,
    required this.base64Data,
    this.text,
    this.sizeBytes,
  });
  final String? text;
  final String fileName;
  final String mimeType;
  final String base64Data;
  final int? sizeBytes;

  List<int> decodeBytes() => base64Decode(base64Data);
}

class ParsedMediaEnvelope {
  ParsedMediaEnvelope({required this.attachments, this.text});
  final String? text;
  final List<ParsedMediaAttachment> attachments;
}

ParsedMediaEnvelope? tryParseMediaAttachments(
  String content,
  MessageContentType contentType,
) {
  if (contentType != MessageContentType.image &&
      contentType != MessageContentType.video &&
      contentType != MessageContentType.file &&
      contentType != MessageContentType.audio) {
    return null;
  }

  try {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    ParsedMediaAttachment? parseAttachment(
      dynamic node,
      String? fallbackText,
    ) {
      if (node is! Map<String, dynamic>) {
        return null;
      }

      final fileName = node['FileName'] ?? node['fileName'];
      final mimeType = node['MimeType'] ?? node['mimeType'];
      final base64Data = node['Base64Data'] ?? node['base64Data'];

      if (fileName is! String || mimeType is! String || base64Data is! String) {
        return null;
      }

      final size = node['SizeBytes'] ?? node['sizeBytes'];
      return ParsedMediaAttachment(
        text: (node['Text'] ?? node['text']) as String? ?? fallbackText,
        fileName: fileName,
        mimeType: mimeType,
        base64Data: base64Data,
        sizeBytes: size is int ? size : int.tryParse('${size ?? ''}'),
      );
    }

    final rootText = (decoded['Text'] ?? decoded['text']) as String?;

    final attachmentsNode = decoded['Attachments'] ?? decoded['attachments'];
    if (attachmentsNode is List) {
      final parsed = attachmentsNode
          .map((item) => parseAttachment(item, rootText))
          .whereType<ParsedMediaAttachment>()
          .toList(growable: false);

      if (parsed.isNotEmpty) {
        return ParsedMediaEnvelope(text: rootText, attachments: parsed);
      }
    }

    final single = parseAttachment(decoded, rootText);
    if (single != null) {
      return ParsedMediaEnvelope(text: rootText, attachments: [single]);
    }

    return null;
  } catch (_) {
    return null;
  }
}

ParsedMediaAttachment? tryParseMediaAttachment(
  String content,
  MessageContentType contentType,
) {
  final parsed = tryParseMediaAttachments(content, contentType);
  if (parsed == null || parsed.attachments.isEmpty) {
    return null;
  }

  return parsed.attachments.first;
}
