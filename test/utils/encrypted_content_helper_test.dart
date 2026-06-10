import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/utils/encrypted_content_helper.dart';

void main() {
  group("EncryptedContentHelper", () {
    test("pack pads short content to minimum length", () {
      final packed = EncryptedContentHelper.pack("hello");

      expect(packed.length, greaterThanOrEqualTo(EncryptedContentHelper.minLength));
      expect(jsonDecode(packed), isA<Map<String, dynamic>>());
    });

    test("unpack returns original content from wrapped payload", () {
      final packed = EncryptedContentHelper.pack("secret message");

      expect(EncryptedContentHelper.unpack(packed), "secret message");
    });

    test("unpack returns original string for non-json payload", () {
      expect(EncryptedContentHelper.unpack("plain text"), "plain text");
    });
  });
}
