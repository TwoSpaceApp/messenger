import 'package:intl/intl.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class MessageTimeFormatter {
  const MessageTimeFormatter._();

  static String formatTime(
    DateTime time, {
    MessageTimestampPrecision? precision,
  }) {
    final localTime = time.toLocal();
    return DateFormat(_timePattern(precision)).format(localTime);
  }

  static String formatConversationTime(
    DateTime? time, {
    MessageTimestampPrecision? precision,
  }) {
    if (time == null) return '';

    final localTime = time.toLocal();
    final now = DateTime.now();
    final sameDay =
        localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day;
    if (sameDay) {
      return formatTime(localTime, precision: precision);
    }

    if (localTime.year == now.year) {
      return DateFormat('dd.MM').format(localTime);
    }

    return DateFormat('dd.MM.yy').format(localTime);
  }

  static String formatDateSeparator(DateTime time, {required String todayLabel, required String yesterdayLabel}) {
    final localTime = time.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(localTime.year, localTime.month, localTime.day);
    final diff = today.difference(messageDay).inDays;
    if (diff == 0) return todayLabel;
    if (diff == 1) return yesterdayLabel;
    if (localTime.year == now.year) {
      return DateFormat('d MMMM').format(localTime);
    }
    return DateFormat('d MMMM yyyy').format(localTime);
  }

  static String _timePattern(MessageTimestampPrecision? precision) {
    switch (
        precision ?? SettingsService.messageTimestampPrecisionNotifier.value) {
      case MessageTimestampPrecision.minutes:
        return 'HH:mm';
      case MessageTimestampPrecision.seconds:
        return 'HH:mm:ss';
      case MessageTimestampPrecision.milliseconds:
        return 'HH:mm:ss.SSS';
    }
  }
}
