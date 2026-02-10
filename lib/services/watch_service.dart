import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wear/wear.dart';

class WatchService {
  static final WatchService _instance = WatchService._internal();
  factory WatchService() => _instance;
  WatchService._internal();

  final _wear = Wear();
  StreamSubscription<WearMessage>? _messageSubscription;

  // Callbacks for handling messages from the watch
  VoidCallback? onAcceptCall;
  VoidCallback? onDeclineCall;

  Future<void> init() async {
    try {
      final isPaired = await _wear.isPaired();
      if (isPaired) {
        _messageSubscription = _wear.messageEvents.listen(_handleMessageFromWatch);
        if (kDebugMode) {
          print('WatchService: Paired and listening for messages.');
        }
      } else {
        if (kDebugMode) {
          print('WatchService: No paired watch found.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('WatchService: Error initializing - $e');
      }
    }
  }

  void dispose() {
    _messageSubscription?.cancel();
  }

  void _handleMessageFromWatch(WearMessage event) {
    final path = event.path;
    if (kDebugMode) {
      print('WatchService: Received message on path "$path"');
    }
    switch (path) {
      case 'accept_call':
        onAcceptCall?.call();
        break;
      case 'decline_call':
        onDeclineCall?.call();
        break;
    }
  }

  Future<void> sendNewMessageNotification(String from, String text) async {
    await _sendMessage('new_message', {'from': from, 'text': text});
  }

  Future<void> sendIncomingCallNotification(String callerName) async {
    await _sendMessage('incoming_call', {'caller': callerName});
  }

  Future<void> sendHangupNotification() async {
    await _sendMessage('hangup_call', {});
  }

  Future<void> _sendMessage(String path, Map<String, dynamic> data) async {
    try {
      await _wear.sendMessage(
        path,
        Uint8List.fromList(data.toString().codeUnits),
      );
      if (kDebugMode) {
        print('WatchService: Sent message on path "$path"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('WatchService: Error sending message - $e');
      }
    }
  }
}
