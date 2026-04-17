import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

/// Notification service for local notifications and foreground service.
/// Handles message notifications, chat updates, and persistent service status.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final DevLogger _log = DevLogger('NotificationService');

  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Initialize the notification service.
  /// Should be called during app startup (e.g., in main.dart before runApp).
  Future<void> initialize() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings();

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

    _initialized = true;
    _log.info('NotificationService initialized');

    // Request permissions
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
      _log.warning('Failed to request notification permissions: $e');
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
    } else if (payload.startsWith('chat_new:')) {
      final chatId = payload.substring(9);
      _navigateToChat(chatId);
    } else if (payload.startsWith('reaction:')) {
      final messageId = payload.substring(9);
      _navigateToMessage(messageId);
    } else if (payload == 'service:foreground') {
      _openApp();
    }
  }

  void _navigateToChat(String roomId) {
    _log.debug('Navigate to chat: $roomId');
    // This will be handled by the app's router
  }

  void _navigateToMessage(String messageId) {
    _log.debug('Navigate to message: $messageId');
    // This will be handled by the app's router
  }

  void _openApp() {
    _log.debug('Open app from notification');
    // App will be brought to foreground automatically
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
}
