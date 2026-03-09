import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/features/settings/presentation/screens/update_screen.dart';

class UpdateInfo {
  UpdateInfo(
      {required this.latestVersion,
      required this.updateUrl,
      this.notes = '',
      this.apkFileId,
      this.apkBucketId,
      this.sha256,
      this.platform,
      this.forceUpdate = false,
      this.selectedAbi});

  factory UpdateInfo.fromJson(Map<String, dynamic> j) => UpdateInfo(
        latestVersion: j['version']?.toString() ?? '',
        updateUrl: j['apkURL']?.toString() ?? j['apkUrl']?.toString() ?? '',
        apkFileId: j['apkFileId']?.toString(),
        apkBucketId: j['apkBucketId']?.toString(),
        notes: j['notes']?.toString() ?? '',
        sha256: j['sha256']?.toString(),
        platform: j['platform']?.toString(),
        forceUpdate: (j['forceUpdate'] == true) ||
            (j['forceUpdate']?.toString().toLowerCase() == 'true'),
        selectedAbi: j['selectedAbi']?.toString(),
      );
  final String latestVersion;
  final String updateUrl; // direct URL to APK
  final String? apkFileId; // optional release artifact identifier
  final String? apkBucketId; // optional bucket id
  final String notes;
  final String? sha256;
  final String? platform;
  final bool forceUpdate;
  final String? selectedAbi;
}

class UpdateService {
  static const MethodChannel _channel = MethodChannel('two_space_app/update');

  static Future<bool> canRequestInstallPackages() async {
    try {
      final res =
          await _channel.invokeMethod<bool>('canRequestInstallPackages');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openInstallSettings() async {
    try {
      final res = await _channel.invokeMethod<bool>('openInstallSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  // Returns UpdateInfo if available and newer than current app, otherwise null
  static Future<UpdateInfo?> checkForUpdate() async {
    // Remote update feed is not configured yet.
    return null;
  }

  // downloads apk to temp file and returns local path
  static Future<String?> downloadApk(String url,
      {ValueChanged<double>? onProgress}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/update_${DateTime.now().millisecondsSinceEpoch}.apk';
      
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
      return savePath;
    } catch (e) {
      if (kDebugMode) debugPrint('APK download failed: $e');
      return null;
    }
  }

  static Future<bool> verifySha256(String filePath, String expectedHex) async {
    try {
      final f = File(filePath);
      if (!await f.exists()) return false;
      final bytes = await f.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString().toLowerCase() == expectedHex.toLowerCase();
    } catch (e) {
      if (kDebugMode) debugPrint('sha256 verify failed: $e');
      return false;
    }
  }

  // Ask platform to install the APK (Android). Returns true if the platform acknowledged the request.
  static Future<bool> installApk(String apkPath) async {
    try {
      final res =
          await _channel.invokeMethod<bool>('installApk', {'path': apkPath});
      return res ?? false;
    } catch (e) {
      if (kDebugMode) debugPrint('installApk failed: $e');
      return false;
    }
  }
}

// Helper widget that shows a dialog and triggers download+install when user confirms
class UpdateDialog {
  static Future<void> showIfAvailable(BuildContext context) async {
    if (kDebugMode) debugPrint('UpdateDialog: showIfAvailable called');
    final info = await UpdateService.checkForUpdate();
    if (info == null) return;
    if (!context.mounted) return;
    // Push a full-screen update page that looks like Telegram's update prompt
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (c) => UpdateScreen(info: info)));
  }
}

// Progress overlay removed; UpdateScreen handles download/install UI.
