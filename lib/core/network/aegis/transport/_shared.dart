import 'package:two_space_app/core/network/aegis/transport/_connection.dart'
    show AegisConnection;
import 'package:two_space_app/core/network/aegis/transport/_native.dart'
    if (dart.library.html) 'package:two_space_app/core/network/aegis/transport/_web.dart'
    as impl;

export 'package:two_space_app/core/network/aegis/transport/_connection.dart'
    show AegisConnection;

/// Factory function to create platform-specific connection
/// Returns an AegisConnection implementation for the current platform
AegisConnection createConnection() {
  return impl.createConnection();
}
