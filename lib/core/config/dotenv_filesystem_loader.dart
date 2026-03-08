import 'package:two_space_app/core/config/dotenv_filesystem_loader_stub.dart'
    if (dart.library.io) 'dotenv_filesystem_loader_io.dart';

/// Attempts to read a `.env` file from the filesystem.
///
/// - On mobile/web this returns `null`.
/// - On desktop (IO platforms) it tries common locations (cwd and executable dir).
Future<String?> readDotenvFromFilesystem() => readDotenvFromFilesystemImpl();
