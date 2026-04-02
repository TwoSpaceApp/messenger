import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock call history model
class CallHistory {
  final String id;
  final String contactId;
  final String contactName;
  final String? contactAvatar;
  final DateTime timestamp;
  final Duration? duration;
  final bool isIncoming;

  CallHistory({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.timestamp,
    required this.isIncoming,
    this.contactAvatar,
    this.duration,
  });
}

// Call history provider
final callHistoryProvider = FutureProvider<List<CallHistory>>((ref) async {
  // Mock data - replace with actual service call
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    CallHistory(
      id: '1',
      contactId: 'user1',
      contactName: 'John Doe',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      duration: const Duration(minutes: 5),
      isIncoming: true,
    ),
    CallHistory(
      id: '2',
      contactId: 'user2',
      contactName: 'Jane Smith',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(minutes: 12),
      isIncoming: false,
    ),
  ];
});
