import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';
import 'package:two_space_app/core/services/media_file_service.dart';

class DevLogExportService {
  DevLogExportService._();

  static Future<String> createBundleFile({
    Iterable<String>? appLogs,
    Iterable<DevNetworkLog>? networkLogs,
    String? suggestedName,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Log file export is not available on web yet');
    }

    final directory = await getTemporaryDirectory();
    final fileName = suggestedName ?? _defaultFileName();
    final file = File(p.join(directory.path, fileName));
    final content = await buildBundleText(
      appLogs: appLogs,
      networkLogs: networkLogs,
    );
    await file.writeAsString(content, flush: true);
    return file.path;
  }

  static Future<String?> exportBundle({
    Iterable<String>? appLogs,
    Iterable<DevNetworkLog>? networkLogs,
    String? suggestedName,
  }) async {
    final filePath = await createBundleFile(
      appLogs: appLogs,
      networkLogs: networkLogs,
      suggestedName: suggestedName,
    );

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await MediaFileService.share(filePath, subject: p.basename(filePath));
      return null;
    }

    return MediaFileService.saveAs(
      filePath,
      suggestedName: suggestedName ?? p.basename(filePath),
    );
  }

  static Future<String> buildBundleText({
    Iterable<String>? appLogs,
    Iterable<DevNetworkLog>? networkLogs,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _loadDeviceInfo();
    final normalizedAppLogs = (appLogs ?? const <String>[]).toList(growable: false);
    final normalizedNetworkLogs =
        (networkLogs ?? const <DevNetworkLog>[]).toList(growable: false);

    return <String>[
      'TwoSpace Debug Export',
      'Generated: ${DateTime.now().toIso8601String()}',
      '',
      'App',
      'Name: ${packageInfo.appName}',
      'Version: ${packageInfo.version}+${packageInfo.buildNumber}',
      'Package: ${packageInfo.packageName}',
      '',
      'Device',
      deviceInfo,
      '',
      'Application Logs',
      formatAppLogs(normalizedAppLogs),
      '',
      'Network Logs',
      formatNetworkLogs(normalizedNetworkLogs),
    ].join('\n');
  }

  static String formatAppLogs(Iterable<String> logs) {
    final lines = logs.toList(growable: false);
    if (lines.isEmpty) {
      return '[no application logs]';
    }
    return lines.join('\n');
  }

  static String formatNetworkLogs(Iterable<DevNetworkLog> logs) {
    final entries = logs.toList(growable: false);
    if (entries.isEmpty) {
      return '[no network logs]';
    }

    return entries.map(_formatNetworkLogEntry).join('\n\n');
  }

  static String _formatNetworkLogEntry(DevNetworkLog log) {
    final lines = <String>[
      '[${log.timestamp.toIso8601String()}] ${log.method} ${log.url}',
      'Status: ${log.statusLabel} (${log.kindLabel})',
      'Latency: ${log.latencyMs} ms',
      'Request type: ${log.requestTypeLabel}',
      'Response type: ${log.responseTypeLabel}',
    ];

    if (log.requestHeaders.isNotEmpty) {
      lines.add('Request headers:');
      lines.add(_prettyPrint(log.requestHeaders));
    }
    if (log.requestBody != null) {
      lines.add('Request body:');
      lines.add(_prettyPrint(log.requestBody));
    }
    if (log.responseHeaders.isNotEmpty) {
      lines.add('Response headers:');
      lines.add(_prettyPrint(log.responseHeaders));
    }
    if (log.responseBody != null) {
      lines.add('Response body:');
      lines.add(_prettyPrint(log.responseBody));
    }
    if ((log.errorMessage ?? '').trim().isNotEmpty) {
      lines.add('Error:');
      lines.add(log.errorMessage!.trim());
    }

    return lines.join('\n');
  }

  static String _prettyPrint(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return trimmed;
      }
      try {
        final decoded = jsonDecode(trimmed);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } on Object catch (_) {
        return value;
      }
    }
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }

  static Future<String> _loadDeviceInfo() async {
    final info = DeviceInfoPlugin();

    if (kIsWeb) {
      final webInfo = await info.webBrowserInfo;
      return [
        'Platform: web',
        'Browser: ${webInfo.browserName.name}',
        'User agent: ${webInfo.userAgent ?? 'unknown'}',
        'Hardware concurrency: ${webInfo.hardwareConcurrency ?? 'unknown'}',
        'Language: ${webInfo.language ?? 'unknown'}',
      ].join('\n');
    }

    if (Platform.isAndroid) {
      final androidInfo = await info.androidInfo;
      final abis = androidInfo.supportedAbis
          .where((abi) => abi.isNotEmpty)
          .join(', ');
      return [
        'Platform: android',
        'Device: ${androidInfo.manufacturer} ${androidInfo.model}'.trim(),
        'OS: Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})',
        'Build: ${androidInfo.device} • ${androidInfo.product}',
        if (abis.isNotEmpty) 'ABIs: $abis',
      ].join('\n');
    }

    if (Platform.isIOS) {
      final iosInfo = await info.iosInfo;
      return [
        'Platform: ios',
        'Device: ${iosInfo.name}',
        'Model: ${iosInfo.model}',
        'OS: ${iosInfo.systemName} ${iosInfo.systemVersion}',
      ].join('\n');
    }

    if (Platform.isMacOS) {
      final macInfo = await info.macOsInfo;
      return [
        'Platform: macos',
        'Device: ${macInfo.model}',
        'OS: ${macInfo.osRelease}',
        'Arch: ${macInfo.arch}',
        'Kernel: ${macInfo.kernelVersion}',
      ].join('\n');
    }

    if (Platform.isWindows) {
      final windowsInfo = await info.windowsInfo;
      return [
        'Platform: windows',
        'Computer: ${windowsInfo.computerName}',
        'Edition: ${windowsInfo.editionId}',
        'Version: ${windowsInfo.displayVersion}',
        'Build: ${windowsInfo.buildNumber}',
      ].join('\n');
    }

    if (Platform.isLinux) {
      final linuxInfo = await info.linuxInfo;
      return [
        'Platform: linux',
        'Name: ${linuxInfo.name}',
        'Version: ${linuxInfo.version}',
        'Pretty name: ${linuxInfo.prettyName}',
      ].join('\n');
    }

    return [
      'Platform: ${Platform.operatingSystem}',
      'Version: ${Platform.operatingSystemVersion}',
      'Hostname: ${Platform.localHostname}',
    ].join('\n');
  }

  static String _defaultFileName() {
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    return 'two_space_logs_$stamp.txt';
  }
}
