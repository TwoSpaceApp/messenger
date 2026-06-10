import 'package:riverpod/riverpod.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    void listener() => state = SettingsService.notificationsEnabledNotifier.value;
    SettingsService.notificationsEnabledNotifier.addListener(listener);
    ref.onDispose(
      () => SettingsService.notificationsEnabledNotifier.removeListener(listener),
    );
    return SettingsService.notificationsEnabledNotifier.value;
  }

  void setEnabled(bool v) {
    // Fire-and-forget; result not needed in notifier
    // ignore: discarded_futures
    SettingsService.setNotificationsEnabled(v);
  }
}

class SoundNotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    void listener() => state = SettingsService.soundEnabledNotifier.value;
    SettingsService.soundEnabledNotifier.addListener(listener);
    ref.onDispose(
      () => SettingsService.soundEnabledNotifier.removeListener(listener),
    );
    return SettingsService.soundEnabledNotifier.value;
  }

  void setEnabled(bool v) {
    // Fire-and-forget; result not needed in notifier
    // ignore: discarded_futures
    SettingsService.setSoundEnabled(v);
  }
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
