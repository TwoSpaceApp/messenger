import 'package:flutter/foundation.dart';

import 'package:two_space_app/features/people/data/models/person_entry.dart';

enum CallHistoryDirection { incoming, outgoing }
enum CallHistoryOutcome { connected, missed, canceled }

@immutable
class CallHistoryEntry {
  const CallHistoryEntry({
    required this.id,
    required this.person,
    required this.startedAt,
    required this.direction,
    required this.outcome,
    this.duration = Duration.zero,
    this.isVideo = false,
  });

  final String id;
  final PersonEntry person;
  final DateTime startedAt;
  final Duration duration;
  final bool isVideo;
  final CallHistoryDirection direction;
  final CallHistoryOutcome outcome;

  bool get isMissed => outcome == CallHistoryOutcome.missed;

  CallHistoryEntry copyWith({
    String? id,
    PersonEntry? person,
    DateTime? startedAt,
    Duration? duration,
    bool? isVideo,
    CallHistoryDirection? direction,
    CallHistoryOutcome? outcome,
  }) {
    return CallHistoryEntry(
      id: id ?? this.id,
      person: person ?? this.person,
      startedAt: startedAt ?? this.startedAt,
      duration: duration ?? this.duration,
      isVideo: isVideo ?? this.isVideo,
      direction: direction ?? this.direction,
      outcome: outcome ?? this.outcome,
    );
  }

  factory CallHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CallHistoryEntry(
      id: json['id']?.toString() ?? '',
      person: PersonEntry.fromJson(
        Map<String, dynamic>.from(
          json['person'] as Map<dynamic, dynamic>? ?? const <String, dynamic>{},
        ),
      ),
      startedAt:
          DateTime.tryParse(json['startedAt']?.toString() ?? '') ?? DateTime.now(),
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      isVideo: json['isVideo'] == true,
      direction: CallHistoryDirection.values.firstWhere(
        (value) => value.name == json['direction'],
        orElse: () => CallHistoryDirection.outgoing,
      ),
      outcome: CallHistoryOutcome.values.firstWhere(
        (value) => value.name == json['outcome'],
        orElse: () => CallHistoryOutcome.connected,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'person': person.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'isVideo': isVideo,
      'direction': direction.name,
      'outcome': outcome.name,
    };
  }
}
