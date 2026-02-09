import 'package:flutter/foundation.dart';

/// A service for handling local notifications.
///
/// This is a template/stub implementation. To make it functional,
/// you would integrate a package like `flutter_local_notifications`.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initializes the notification service.
  ///
  /// In a real implementation, you would configure channels for Android,
  /// request permissions for iOS, and set up callbacks for when a
  /// notification is tapped.
  Future<void> init() async {
    if (kDebugMode) {
      print('NotificationService: Initialized (stub).');
    }
    // Example with a real plugin:
    // final notificationsPlugin = FlutterLocalNotificationsPlugin();
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings();
    // const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    // await notificationsPlugin.initialize(initSettings, onDidReceiveNotificationResponse: onNotificationTapped);
  }

  /// Shows a notification for a new message.
  Future<void> showNewMessageNotification({
    required String title,
    required String body,
    required String roomId,
  }) async {
    if (kDebugMode) {
      print('--- NEW MESSAGE NOTIFICATION ---');
      print('Title: $title');
      print('Body: $body');
      print('Room ID: $roomId');
      print('--------------------------------');
    }
    // Example with a real plugin:
    // await _notificationsPlugin.show(
    //   roomId.hashCode, // Use a consistent ID for the room
    //   title,
    //   body,
    //   _getPlatformChannelDetails('messages'),
    //   payload: 'chat/$roomId',
    // );
  }

  /// Shows a notification for an incoming call.
  ///
  /// This notification should have high priority and include action buttons.
  Future<void> showIncomingCallNotification({
    required String callId,
    required String callerName,
  }) async {
    if (kDebugMode) {
      print('--- INCOMING CALL NOTIFICATION ---');
      print('Caller: $callerName');
      print('Call ID: $callId');
      print('Actions: [Answer, Decline]');
      print('----------------------------------');
    }
    // Example with a real plugin:
    // await _notificationsPlugin.show(
    //   callId.hashCode,
    //   'Incoming Call',
    //   'Call from $callerName',
    //   _getPlatformChannelDetails('calls', withActions: true),
    //   payload: 'call/$callId',
    // );
  }

  /// Shows a notification for a "ping" or mention.
  Future<void> showPingNotification({
    required String title,
    required String body,
    required String roomId,
  }) async {
    if (kDebugMode) {
      print('--- PING NOTIFICATION ---');
      print('Title: $title');
      print('Body: $body');
      print('Room ID: $roomId');
      print('-------------------------');
    }
    // Example with a real plugin:
    // await _notificationsPlugin.show(
    //   (roomId + '_ping').hashCode,
    //   title,
    //   body,
    //   _getPlatformChannelDetails('pings'),
    //   payload: 'chat/$roomId',
    // );
  }

  /// Cancels a notification, e.g., when a call is answered or declined elsewhere.
  Future<void> cancelNotification(int notificationId) async {
    if (kDebugMode) {
      print('NotificationService: Cancelling notification $notificationId (stub).');
    }
    // Example with a real plugin:
    // await _notificationsPlugin.cancel(notificationId);
  }
}
