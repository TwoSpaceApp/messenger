class MatrixEvent {
  final String eventId;
  final String roomId;
  final String sender;
  final DateTime originServerTs;
  final Map<String, dynamic> content;

  MatrixEvent({
    required this.eventId,
    required this.roomId,
    required this.sender,
    required this.originServerTs,
    required this.content,
  });

  factory MatrixEvent.fromJson(Map<String, dynamic> json) {
    return MatrixEvent(
      eventId: json['event_id'],
      roomId: json['room_id'],
      sender: json['sender'],
      originServerTs: DateTime.fromMillisecondsSinceEpoch(json['origin_server_ts']),
      content: json['content'],
    );
  }
}
