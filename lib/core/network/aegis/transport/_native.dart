import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/transport/_connection.dart';

/// Factory function to create native connection (for conditional export)
AegisConnection createConnection() {
  return NativeAegisConnection();
}

/// Native TCP socket implementation for non-web platforms.
class NativeAegisConnection implements AegisConnection {
  late Socket _socket;
  bool _isConnected = false;

  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();
  final StreamController<void> _closeController =
      StreamController<void>.broadcast();

  StreamSubscription<Uint8List>? _subscription;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<Uint8List> get onData => _dataController.stream;

  @override
  Stream<Object> get onError => _errorController.stream;

  @override
  Stream<void> get onClose => _closeController.stream;

  @override
  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    bool useTls = false,
  }) async {
    if (_isConnected) {
      throw StateError('Already connected');
    }

    try {
      final connectTimeout = timeout ?? const Duration(seconds: 10);

      if (useTls) {
        _socket = await SecureSocket.connect(
          host,
          port,
          timeout: connectTimeout,
        ).timeout(connectTimeout);
      } else {
        _socket = await Socket.connect(
          host,
          port,
          timeout: connectTimeout,
        ).timeout(connectTimeout);
      }

      _isConnected = true;
      _listen();

      AegisLogger.info('Native TCP connected to $host:$port');
    } catch (e) {
      _isConnected = false;
      _errorController.add(e);
      rethrow;
    }
  }

  void _listen() {
    _subscription = _socket.listen(
      (data) {
        if (!_dataController.isClosed) {
          _dataController.add(data);
        }
      },
      onError: (error) {
        _isConnected = false;
        if (!_errorController.isClosed) {
          _errorController.add(error);
        }
      },
      onDone: () {
        _isConnected = false;
        if (!_closeController.isClosed) {
          _closeController.add(null);
        }
      },
    );
  }

  @override
  Future<void> send(Uint8List data) async {
    if (!_isConnected) {
      throw StateError('Not connected');
    }
    _socket.add(data);
  }

  @override
  Future<void> flush() async {
    if (_isConnected) {
      await _socket.flush();
    }
  }

  @override
  void pause() {
    _subscription?.pause();
  }

  @override
  void resume() {
    _subscription?.resume();
  }

  @override
  Future<void> close() async {
    if (!_isConnected) return;
    _isConnected = false;
    try {
      await _subscription?.cancel();
      _subscription = null;
      await _socket.close();
    } catch (_) {
      // Best-effort close
    }
  }

  @override
  void dispose() {
    close().ignore();
    if (!_dataController.isClosed) _dataController.close();
    if (!_errorController.isClosed) _errorController.close();
    if (!_closeController.isClosed) _closeController.close();
  }
}
