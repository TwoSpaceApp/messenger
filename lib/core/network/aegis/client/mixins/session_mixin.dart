import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisSessionMixin on AegisClientBase {

  Future<SessionListResponse> listActiveSessions() async {
    requireAuthenticated();

    final msg = Message.withType(
      MessageType.sessionListRequest,
      const SessionListRequest().toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.sessionListResponse},
    );
    return SessionListResponse.fromBytes(response.payload);
  }

  Future<SessionRevokeResponse> revokeSession(String sessionId) async {
    requireAuthenticated();

    final parsedSessionId = int.tryParse(sessionId);
    if (parsedSessionId == null || parsedSessionId <= 0) {
      throw ArgumentError.value(sessionId, 'sessionId', 'Session id must be numeric');
    }

    final msg = Message.withType(
      MessageType.sessionRevokeRequest,
      SessionRevokeRequest(sessionId: parsedSessionId).toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.sessionRevokeResponse},
    );
    return SessionRevokeResponse.fromBytes(response.payload);
  }
}
