import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/environment.dart';
import 'chat_matrix_service.dart';
import 'token_manager.dart';

class MatrixService {
  final String _homeserverUrl = Environment.matrixHomeserverUrl;

  Future<String?> getCurrentUserId() async {
    final token = await TokenManager.getMatrixToken();
    if (token == null) return null;
    // A simple (and not very reliable) way to get user ID from token
    // In a real app, you'd likely store this separately or use a dedicated endpoint
    final parts = token.split('_');
    if (parts.length > 2) {
      return '@${parts[2]}:${Environment.matrixHomeserverUrl}';
    }
    return null;
  }

  Future<Map<String, dynamic>> _sendRequest(
    String endpoint, {
    String method = 'POST',
    Map<String, dynamic>? body,
    bool authenticate = true,
  }) async {
    final url = Uri.parse('$_homeserverUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};
    if (authenticate) {
      final token = await TokenManager.getMatrixToken();
      if (token == null) throw Exception('Not authenticated');
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    if (method == 'GET') {
      response = await http.get(url, headers: headers);
    } else {
      response = await http.post(url, headers: headers, body: jsonEncode(body));
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to execute request: ${response.body}');
    }
  }

  Future<dynamic> handleApiCall(String method, Map<String, dynamic> payload) async {
    switch (method) {
      case 'get-rooms':
        return await ChatMatrixService().getJoinedRooms();
      case 'get-room-meta':
        return await ChatMatrixService().getRoomNameAndAvatar(payload['roomId']);
      case 'get-messages':
        return await ChatMatrixService().loadMessages(roomId: payload['chatId'], limit: payload['limit'] ?? 50);
      case 'send-message':
        return await _sendMessage(payload);
      case 'upload-file':
        return await _uploadFile(payload);
      default:
        throw Exception('Unsupported API method: $method');
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> payload) async {
    final chatId = payload['chatId'] as String?;
    final text = payload['text'] as String?;
    if (chatId == null || text == null) {
      throw Exception('Missing chatId or text');
    }

    if (Environment.useMatrix) {
      final type = (payload['type'] ?? 'text').toString();
      final media = payload['mediaFileId'] as String? ?? payload['mediaId'] as String?;
      try {
        await ChatMatrixService().sendMessage(roomId: chatId, body: text, type: type == 'image' ? 'm.image' : 'm.text', mediaFileId: media);
      } catch (e) {
        rethrow;
      }
    }
    throw Exception('sendMessage: Matrix mode required');
  }

  Future<Map<String, dynamic>> _uploadFile(Map<String, dynamic> payload) async {
    final path = payload['path'] as String?;
    final filename = payload['filename'] as String?;
    if (path == null || filename == null) {
      throw Exception('Missing path or filename');
    }

    final bytes = await File(path).readAsBytes();
    return await uploadBytesToStorage(bytes, filename);
  }

  Future<Map<String, dynamic>> uploadBytesToStorage(List<int> bytes, String filename) async {
    if (Environment.useMatrix) {
      const contentType = 'application/octet-stream';
      final mxc = await ChatMatrixService().uploadMedia(bytes, contentType, filename);
      return {'\$id': mxc, 'id': mxc, 'viewUrl': getFileViewUrl(mxc ?? '').toString()};
    }
    throw Exception('uploadBytesToStorage: Matrix mode required');
  }

  Uri getFileViewUrl(String mxcUrl) {
    if (mxcUrl.startsWith('mxc://')) {
      final parts = mxcUrl.substring(6).split('/');
      if (parts.length == 2) {
        return Uri.parse('$_homeserverUrl/_matrix/media/v3/download/${parts[0]}/${parts[1]}');
      }
    }
    return Uri.parse(mxcUrl);
  }

  Future<String> downloadFile(String mxcUrl) async {
    final url = getFileViewUrl(mxcUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filename = mxcUrl.split('/').last;
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  static createAccount(String email, String password, {String? name}) {}
  
  static restoreJwt() {}
  
  static getJwt() {}
  
  static deleteCurrentSession() {}
  
  static saveSessionCookie(String? receivedCookie) {}
  
  static clearJwt() {}
  
  static createPhoneToken(String phone) {}
  
  static createEmailSession(String email, String s) {}
  
  static v1Endpoint() {}
  
  static saveJwt(String jwt) {}
  
  static setCurrentUserId(String userId) {}
}
