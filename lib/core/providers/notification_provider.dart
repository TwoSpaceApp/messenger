import 'package:riverpod/riverpod.dart';

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setEnabled(bool v) => state = v;
}

class SoundNotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setEnabled(bool v) => state = v;
}

// Notification state
final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

// Sound notifications provider
final soundNotificationsProvider =
    NotifierProvider<SoundNotificationsNotifier, bool>(
  SoundNotificationsNotifier.new,
);
