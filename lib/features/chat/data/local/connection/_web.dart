import 'package:drift/drift.dart';

/// For web platform, return a lazy database that fails when accessed
/// This allows the app to load but prevents data operations
QueryExecutor openDatabase() {
  // Return a LazyDatabase that will throw when actually used
  return LazyDatabase(() async {
    throw UnsupportedError(
      'Database not supported on web platform. '
      'This is a placeholder implementation.',
    );
  });
}
