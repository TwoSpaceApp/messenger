import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/navigation/app_router.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/firebase_options.dart';

// Service is used through NotificationService() singleton, not from main.
// ignore_for_file: unreachable_from_main

/// Handler for background FCM messages.
/// Must be a top-level function or static method.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
  } catch (_) {
    return;
  }

  final log = DevLogger('FCMBackground');
  log.info('Background message received: ${message.messageId}');
  log.debug('Message data: ${message.data}');
}

/// Notification service for local notifications, foreground service, and push notifications.
/// Handles message notifications, chat updates, and persistent service status.
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static final DevLogger _log = DevLogger('NotificationService');

  late FlutterLocalNotificationsPlugin _plugin;
  FirebaseMessaging? _firebaseMessaging;
  bool _initialized = false;
  String? _fcmToken;

  // Stream controllers for notification events
  final StreamController<String> _onChatOpened = StreamController<String>.broadcast();
  final StreamController<String> _onMessageOpened = StreamController<String>.broadcast();

  /// Stream of chat IDs when user taps on a chat notification
  Stream<String> get onChatOpened => _onChatOpened.stream;

  /// Stream of message IDs when user taps on a message/reaction notification
  Stream<String> get onMessageOpened => _onMessageOpened.stream;

  /// Current FCM token for push notifications
  String? get fcmToken => _fcmToken;

  /// Initialize the notification service.
  /// Should be called during app startup (e.g., in main.dart before runApp).
  Future<void> initialize() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase Cloud Messaging
    await _initializeFirebaseMessaging();

    _initialized = true;
    _log.info('NotificationService initialized');
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request permissions separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channels for Android 8+
    await _createNotificationChannels();

    // Request permissions for local notifications
    await _requestLocalNotificationPermissions();
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission for push notifications
      await _requestPushNotificationPermissions();

      // Get FCM token
      await _updateFcmToken();

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen(
        (newToken) {
          _fcmToken = newToken;
          _log.info('FCM token refreshed');
          // TODO(wakcedon): Send new token to server
        },
        onError: (error) {
          _log.error('FCM token refresh error: $error');
        },
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError: (error) {
          _log.error('FCM foreground message error: $error');
        },
      );

      // Handle notification open events (when app is in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(
        _handleMessageOpenedApp,
        onError: (error) {
          _log.error('FCM message opened app error: $error');
        },
      );

      // Check if app was opened from a notification (when terminated)
      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        _log.info('App opened from terminated state via notification');
        _handleMessageOpenedApp(initialMessage);
      }

      _log.info('Firebase Messaging initialized');
    } catch (e, stackTrace) {
      _log.exception('Failed to initialize Firebase Messaging', e, stackTrace);
      _firebaseMessaging = null;
    }
  }

  /// Request permissions for local notifications
  Future<void> _requestLocalNotificationPermissions() async {
    try {
      // iOS permissions
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // Android 13+ permissions
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      _log.warning('Failed to request local notification permissions: $e');
    }
  }

  /// Request permissions for push notifications
  Future<void> _requestPushNotificationPermissions() async {
    final fm = _firebaseMessaging;
    if (fm == null) return;
    try {
      final settings = await fm.requestPermission();

      _log.info('Push notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      _log.warning('Failed to request push notification permissions: $e');
    }
  }

  /// Update and retrieve FCM token
  Future<void> _updateFcmToken() async {
    final fm = _firebaseMessaging;
    if (fm == null) return;
    try {
      _fcmToken = await fm.getToken();
      if (_fcmToken != null) {
        _log.info('FCM token retrieved successfully');
        _log.debug('Token: ${_fcmToken!.substring(0, _fcmToken!.length > 20 ? 20 : _fcmToken!.length)}...');
      } else {
        _log.warning('FCM token is null');
      }
    } catch (e) {
      _log.error('Failed to get FCM token: $e');
    }
  }

  /// Handle foreground FCM messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _log.info('Foreground FCM message received: ${message.messageId}');
    _log.debug('Message data: ${message.data}');

    final notification = message.notification;
    if (notification != null) {
      _log.debug('Notification title: ${notification.title}');
      _log.debug('Notification body: ${notification.body}');

      // Show local notification for foreground messages
      // This is needed because FCM doesn't show notifications automatically
      // when the app is in foreground
      await _showLocalNotificationFromFcm(message);
    }
  }

  /// Show local notification from FCM message
  Future<void> _showLocalNotificationFromFcm(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? 'message';
    final chatId = data['chat_id'] ?? data['room_id'];
    final messageId = data['message_id'];

    switch (type) {
      case 'message':
        if (chatId != null) {
          await showMessageNotification(
            title: notification.title ?? 'New Message',
            body: notification.body ?? '',
            chatId: chatId,
          );
        }
      case 'chat':
      case 'group':
        if (chatId != null) {
          await showChatUpdateNotification(
            title: notification.title ?? 'New Chat',
            body: notification.body ?? '',
            chatId: chatId,
          );
        }
      case 'reaction':
        if (messageId != null) {
          await showReactionNotification(
            title: notification.title ?? 'New Reaction',
            body: notification.body ?? '',
            messageId: messageId,
          );
        }
    }
  }

  /// Handle notification tap when app is in background/terminated
  void _handleMessageOpenedApp(RemoteMessage message) {
    _log.info('Notification opened app: ${message.messageId}');
    _log.debug('Message data: ${message.data}');

    final data = message.data;
    final type = data['type'] ?? 'message';
    final chatId = data['chat_id'] ?? data['room_id'];
    final messageId = data['message_id'];

    switch (type) {
      case 'message':
      case 'chat':
      case 'group':
        if (chatId != null) {
          _navigateToChat(chatId);
          _onChatOpened.add(chatId);
        }
      case 'reaction':
        if (messageId != null) {
          _navigateToMessage(messageId);
          _onMessageOpened.add(messageId);
        }
    }
  }

  /// Create notification channels for Android 8+.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    try {
      // Messages channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'messages',
          'Messages',
          description: 'Notifications for new messages',
          importance: Importance.high,
        ),
      );

      // Chat updates channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chats',
          'Chat Updates',
          description: 'Notifications for new chats and groups',
          importance: Importance.max,
        ),
      );

      // Service channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'service',
          'Service Status',
          description: 'Persistent notification for app service status',
          importance: Importance.low,
          showBadge: false,
        ),
      );

      // FCM channel (for push notifications)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'fcm_fallback_notification_channel',
          'Push Notifications',
          description: 'Notifications from server',
          importance: Importance.high,
        ),
      );
    } catch (e) {
      _log.warning('Failed to create notification channels: $e');
    }
  }

  /// Show a notification for a new message.
  Future<void> showMessageNotification({
    required String title,
    required String body,
    required String chatId,
    String? imageUrl,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService not initialized');
      return;
    }

    if (!SettingsService.notificationsEnabledNotifier.value ||
        !SettingsService.notificationsMessageEnabledNotifier.value) {
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'messages',
        'Messages',
        channelDescription: 'Notifications for new messages',
        importance: Importance.high,
        priority: Priority.high,
        playSound: SettingsService.soundEnabledNotifier.value,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: SettingsService.soundEnabledNotifier.value,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      await _plugin.show(
        chatId.hashCode,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'chat:$chatId',
      );

      _log.debug('Message notification shown: $title');
    } catch (error) {
      _log.error('Failed to show message notification: $error');
    }
  }

  /// Show a notification for new chats or groups.
  Future<void> showChatUpdateNotification({
    required String title,
    required String body,
    required String chatId,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService not initialized');
      return;
    }

    if (!SettingsService.notificationsEnabledNotifier.value ||
        !SettingsService.notificationsChatEnabledNotifier.value) {
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'chats',
        'Chat Updates',
        channelDescription: 'Notifications for new chats and groups',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      );

      await _plugin.show(
        ('chat_$chatId').hashCode,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'chat_new:$chatId',
      );

      _log.debug('Chat update notification shown: $title');
    } catch (error) {
      _log.error('Failed to show chat update notification: $error');
    }
  }

  /// Show a notification for reactions on messages.
  Future<void> showReactionNotification({
    required String title,
    required String body,
    required String messageId,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService not initialized');
      return;
    }

    if (!SettingsService.notificationsEnabledNotifier.value ||
        !SettingsService.notificationsReactionEnabledNotifier.value) {
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'messages',
        'Messages',
        channelDescription: 'Notifications for reactions',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
      );

      await _plugin.show(
        ('reaction_$messageId').hashCode,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'reaction:$messageId',
      );

      _log.debug('Reaction notification shown: $title');
    } catch (error) {
      _log.error('Failed to show reaction notification: $error');
    }
  }

  /// Update the persistent foreground service notification.
  /// Shows app is actively listening for messages.
  Future<void> updateForegroundServiceNotification({
    int? unreadCount,
  }) async {
    if (!_initialized) {
      _log.warning('NotificationService not initialized');
      return;
    }

    if (!SettingsService.foregroundServiceEnabledNotifier.value) {
      return;
    }

    try {
      final statusText = unreadCount != null && unreadCount > 0
          ? 'Connected • $unreadCount unread'
          : 'Connected';

      const androidDetails = AndroidNotificationDetails(
        'service',
        'Service Status',
        channelDescription: 'Persistent notification for app service',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'open_app',
            'Open',
            showsUserInterface: true,
          ),
        ],
      );

      await _plugin.show(
        999,
        'TwoSpace',
        statusText,
        const NotificationDetails(android: androidDetails),
        payload: 'service:foreground',
      );

      _log.debug('Foreground service notification updated: $statusText');
    } catch (error) {
      _log.error('Failed to update foreground service notification: $error');
    }
  }

  /// Cancel a specific notification by ID.
  Future<void> cancelNotification(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (error) {
      _log.error('Failed to cancel notification: $error');
    }
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (error) {
      _log.error('Failed to cancel all notifications: $error');
    }
  }

  /// Handle notification tap (called when user taps notification).
  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    _log.info('Notification tapped: $payload');

    // Payload format:
    // 'chat:roomId' - open chat
    // 'chat_new:chatId' - open new chat
    // 'reaction:messageId' - open message
    // 'service:foreground' - open app

    if (payload.startsWith('chat:')) {
      final roomId = payload.substring(5);
      _navigateToChat(roomId);
      _onChatOpened.add(roomId);
    } else if (payload.startsWith('chat_new:')) {
      final chatId = payload.substring(9);
      _navigateToChat(chatId);
      _onChatOpened.add(chatId);
    } else if (payload.startsWith('reaction:')) {
      final messageId = payload.substring(9);
      _navigateToMessage(messageId);
      _onMessageOpened.add(messageId);
    } else if (payload == 'service:foreground') {
      _openApp();
    }
  }

  void _navigateToChat(String roomId) {
    _log.debug('Navigate to chat: $roomId');
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('${AppStrings.routeChat}/$roomId');
    }
  }

  void _navigateToMessage(String messageId) {
    _log.debug('Navigate to message: $messageId');
    _log.warning('Message-level deep link not yet implemented: $messageId');
  }

  void _openApp() {
    _log.debug('Open app from notification');
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(AppStrings.routeHome);
    }
  }

  /// Start the foreground service (Android only).
  /// Shows persistent notification so app continues to receive messages.
  Future<void> startForegroundService() async {
    if (!_initialized) {
      _log.warning('NotificationService not initialized');
      return;
    }

    if (!SettingsService.foregroundServiceEnabledNotifier.value) {
      return;
    }

    try {
      await updateForegroundServiceNotification(unreadCount: 0);
      _log.info('Foreground service started');
    } catch (error) {
      _log.error('Failed to start foreground service: $error');
    }
  }

  /// Stop the foreground service.
  Future<void> stopForegroundService() async {
    if (!_initialized) return;
    try {
      await cancelNotification(999);
      _log.info('Foreground service stopped');
    } catch (error) {
      _log.error('Failed to stop foreground service: $error');
    }
  }

  /// Subscribe to a topic for push notifications
  Future<void> subscribeToTopic(String topic) async {
    final fm = _firebaseMessaging;
    if (fm == null) return;
    try {
      await fm.subscribeToTopic(topic);
      _log.info('Subscribed to topic: $topic');
    } catch (e) {
      _log.error('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    final fm = _firebaseMessaging;
    if (fm == null) return;
    try {
      await fm.unsubscribeFromTopic(topic);
      _log.info('Unsubscribed from topic: $topic');
    } catch (e) {
      _log.error('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Delete FCM token (e.g., on logout)
  Future<void> deleteFcmToken() async {
    final fm = _firebaseMessaging;
    if (fm == null) return;
    try {
      await fm.deleteToken();
      _fcmToken = null;
      _log.info('FCM token deleted');
    } catch (e) {
      _log.error('Failed to delete FCM token: $e');
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _onChatOpened.close();
    await _onMessageOpened.close();
  }
}
