import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/transport/_connection.dart';

/// Factory function to create web connection (for conditional export)
AegisConnection createConnection() {
  return WebAegisConnection();
}

/// Web WebSocket implementation for browser platforms.
/// 
/// On web, browsers can only communicate via:
/// - HTTP/HTTPS
/// - WebSocket (ws:// / wss://)
/// 
/// This implementation connects to a WebSocket endpoint that proxies to the native Aegis TCP protocol.
class WebAegisConnection implements AegisConnection {
  bool _isConnected = false;
  bool _disposed = false;
  html.WebSocket? _webSocket;
  Completer<void>? _connectCompleter;

  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();
  final StreamController<void> _closeController =
      StreamController<void>.broadcast();

  StreamSubscription? _subscription;

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
    if (_disposed) {
      throw StateError('Connection disposed');
    }
    if (_isConnected) {
      throw StateError('Already connected');
    }

    _connectCompleter = Completer<void>();

    try {
      // Build WebSocket URL
      // On web, we use the same scheme as the page (secure HTTPS → wss://, plain HTTP → ws://)
      final wsScheme = html.window.location.protocol == 'https:' ? 'wss' : 'ws';
      final pageHost = html.window.location.hostname ?? 'localhost';
      final pagePort = html.window.location.port ?? (wsScheme == 'wss' ? '443' : '80');
      
      // Connect to WebSocket proxy on the same origin, on path /ws
      // This assumes nginx is configured to proxy /ws to localhost:9999
      final wsUrl = '$wsScheme://$pageHost:$pagePort/ws';

      AegisLogger.info('WebSocket: Connecting to $wsUrl');

      _webSocket = html.WebSocket(wsUrl);

      // Connection opened
      _webSocket!.onOpen.listen((_) {
        if (_disposed) return;
        _isConnected = true;
        AegisLogger.info('WebSocket: Connected');
        _connectCompleter?.complete();
      });

      // Data received (could be Blob, String, or typed array)
      _webSocket!.onMessage.listen((event) {
        if (_disposed || !_isConnected) return;

        try {
          final data = event.data;
          
          if (data is List<int>) {
            // Already a list of integers, convert to Uint8List
            final bytes = Uint8List.fromList(data);
            _dataController.add(bytes);
          } else if (data is String) {
            // UTF-8 encoded string - convert to bytes
            // Note: This might not work correctly for binary data
            final bytes = Uint8List.fromList(data.codeUnits);
            _dataController.add(bytes);
          } else {
            AegisLogger.warning('WebSocket: Unexpected message type: ${data.runtimeType}');
          }
        } catch (e) {
          AegisLogger.warning('WebSocket: Error processing message: $e');
          _errorController.add(e);
        }
      });

      // Error occurred
      _webSocket!.onError.listen((event) {
        if (_disposed) return;
        _isConnected = false;
        final error = 'WebSocket error: ${event.toString()}';
        AegisLogger.error(error);
        _errorController.add(Exception(error));
        _connectCompleter?.completeError(error);
      });

      // Connection closed
      _webSocket!.onClose.listen((event) {
        if (_disposed) return;
        _isConnected = false;
        final code = event.code;
        final reason = event.reason ?? 'unknown';
        AegisLogger.info('WebSocket: Closed (code=$code, reason=$reason)');
        _closeController.add(null);
        _connectCompleter?.completeError(
          Exception('WebSocket closed: code=$code reason=$reason'),
        );
      });

      // Wait for connection or timeout
      if (timeout != null) {
        await _connectCompleter!.future.timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException('WebSocket connection timeout');
          },
        );
      } else {
        await _connectCompleter!.future;
      }
    } catch (e) {
      _isConnected = false;
      if (!_connectCompleter!.isCompleted) {
        _connectCompleter?.completeError(e);
      }
      _errorController.add(e);
      rethrow;
    }
  }

  @override
  Future<void> send(Uint8List data) async {
    if (_disposed) {
      throw StateError('Connection disposed');
    }
    if (!_isConnected || _webSocket == null) {
      throw StateError('Not connected');
    }
    
    try {
      // Send as typed data (binary)
      _webSocket!.sendTypedData(data);
    } catch (e) {
      AegisLogger.error('WebSocket: Send failed: $e');
      _errorController.add(e);
      rethrow;
    }
  }

  @override
  Future<void> flush() async {
    // WebSocket doesn't need explicit flush
  }

  @override
  void pause() {
    // Stream pause not directly supported on WebSocket
    // Would require buffering logic
  }

  @override
  void resume() {
    // Stream resume not directly supported on WebSocket
    // Would require buffering logic
  }

  @override
  Future<void> close() async {
    if (!_isConnected || _webSocket == null) return;
    
    try {
      _isConnected = false;
      _webSocket!.close();
      _webSocket = null;
    } catch (e) {
      AegisLogger.warning('WebSocket: Error during close: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    close().ignore();
    _subscription?.cancel();
    
    if (!_dataController.isClosed) _dataController.close();
    if (!_errorController.isClosed) _errorController.close();
    if (!_closeController.isClosed) _closeController.close();
  }
}
