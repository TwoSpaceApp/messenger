import 'dart:ffi' hide Opaque;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

/// Open database connection for native platforms (mobile, desktop, Linux)
QueryExecutor openDatabase() {
  if (Platform.isAndroid || Platform.isIOS) {
    return SqfliteQueryExecutor.inDatabaseFolder(path: 'aegis_chat.sqlite');
  }

  return LazyDatabase(() async {
    _configureSqliteRuntime();
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'aegis_chat.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: _configureSqliteRuntime,
    );
  });
}

bool _sqliteRuntimeConfigured = false;

void _configureSqliteRuntime() {
  if (_sqliteRuntimeConfigured) {
    return;
  }
  _sqliteRuntimeConfigured = true;

  if (!Platform.isLinux) {
    return;
  }

  sqlite_open.open.overrideFor(
    sqlite_open.OperatingSystem.linux,
    _openSqliteDynamicLibrary,
  );
}

DynamicLibrary _openSqliteDynamicLibrary() {
  for (final candidate in const [
    'libsqlite3.so.0',
    '/lib/x86_64-linux-gnu/libsqlite3.so.0',
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    'libsqlite3.so',
  ]) {
    try {
      return DynamicLibrary.open(candidate);
    } catch (_) {
      // Try the next known soname.
    }
  }
  throw ArgumentError(
    'Failed to load sqlite3 dynamic library on Linux. '
    'Tried libsqlite3.so.0, libsqlite3.so, and common distro paths.',
  );
}
