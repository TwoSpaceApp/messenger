import 'dart:async';
import 'dart:typed_data';

/// Abstract connection interface for both native (TCP) and web (WebSocket).
abstract class AegisConnection {
  /// Whether the connection is open.
  bool get isConnected;

  /// Stream of incoming data.
  Stream<Uint8List> get onData;

  /// Stream of error events.
  Stream<Object> get onError;

  /// Stream of close events.
  Stream<void> get onClose;

  /// Connect to [host]:[port].
  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    bool useTls = false,
  });

  /// Send [data] to the server.
  Future<void> send(Uint8List data);

  /// Flush any buffered data.
  Future<void> flush();

  /// Pause receiving data.
  void pause();

  /// Resume receiving data.
  void resume();

  /// Close the connection.
  Future<void> close();

  /// Release all resources.
  void dispose();
}
