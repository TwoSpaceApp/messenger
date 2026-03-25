import 'package:flutter/foundation.dart';

import 'package:two_space_app/features/people/data/models/person_entry.dart';

enum CallHistoryDirection { incoming, outgoing }
enum CallHistoryOutcome { connected, missed, canceled }

String _directionWire(CallHistoryDirection value) {
  switch (value) {
    case CallHistoryDirection.incoming:
      return 'incoming';
    case CallHistoryDirection.outgoing:
      return 'outgoing';
  }
}

CallHistoryDirection _directionFromWire(String? value) {
  switch (value) {
    case 'incoming':
      return CallHistoryDirection.incoming;
    case 'outgoing':
      return CallHistoryDirection.outgoing;
    default:
      return CallHistoryDirection.outgoing;
  }
}

String _outcomeWire(CallHistoryOutcome value) {
  switch (value) {
    case CallHistoryOutcome.connected:
      return 'connected';
    case CallHistoryOutcome.missed:
      return 'missed';
    case CallHistoryOutcome.canceled:
      return 'canceled';
  }
}

CallHistoryOutcome _outcomeFromWire(String? value) {
  switch (value) {
    case 'connected':
      return CallHistoryOutcome.connected;
    case 'missed':
      return CallHistoryOutcome.missed;
    case 'canceled':
      return CallHistoryOutcome.canceled;
    default:
      return CallHistoryOutcome.connected;
  }
}

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
      direction: _directionFromWire(json['direction']?.toString()),
      outcome: _outcomeFromWire(json['outcome']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'person': person.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'isVideo': isVideo,
      'direction': _directionWire(direction),
      'outcome': _outcomeWire(outcome),
    };
  }
}
