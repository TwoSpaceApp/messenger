import 'dart:io';

Future<String?> readDotenvFromFilesystemImpl() async {
  final candidates = <String>{
    '.env',
  };

  try {
    final exe = Platform.resolvedExecutable;
    final exeDir = File(exe).parent.path;
    candidates.add('$exeDir/.env');
  } catch (_) {
    // Ignore: not critical.
  }

  for (final path in candidates) {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {
      // Ignore: best-effort.
    }
  }

  return null;
}
