import 'dart:convert';
import 'package:http/http.dart' as http_pkg;
import 'package:two_space_app/core/services/dev_network_logger.dart';

// Реэкспортируем важные классы http, чтобы не ломать импорты
export 'package:http/http.dart' show MultipartRequest, StreamedResponse, Client, BaseRequest, Response, Request, ByteStream;

class _DevDevHttpClient extends http_pkg.BaseClient {
  final http_pkg.Client _inner = http_pkg.Client();

  @override
  Future<http_pkg.StreamedResponse> send(http_pkg.BaseRequest request) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Копируем тело для логера (если это обычный Request)
    dynamic requestBody;
    if (request is http_pkg.Request) {
      if (request.bodyBytes.isNotEmpty) {
        try {
          requestBody = jsonDecode(request.body);
        } catch (_) {
          requestBody = request.body;
        }
      }
    }

    http_pkg.StreamedResponse? response;
    try {
      response = await _inner.send(request);
      
      // Для логирования ответа нам нужно прочитать Stream, но не испортить
      // его для основного приложения. Поэтому мы читаем его в память:
      final respBytes = await response.stream.toBytes();
      final bodyString = utf8.decode(respBytes, allowMalformed: true);
      
      dynamic responseBody;
      try {
        responseBody = jsonDecode(bodyString);
      } catch (_) {
        responseBody = bodyString;
      }
      
      final latencyMs = DateTime.now().millisecondsSinceEpoch - startTime;
      
      DevNetworkLogger.instance.logRequest(
        method: request.method,
        url: request.url.toString(),
        statusCode: response.statusCode,
        latencyMs: latencyMs,
        requestBody: requestBody,
        responseBody: responseBody,
        headers: request.headers,
      );

      // Воссоздаем ответ с буферизированными данными, чтобы оригинальный код смог его прочесть
      return http_pkg.StreamedResponse(
        Stream.value(respBytes),
        response.statusCode,
        contentLength: respBytes.length,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e) {
      final latencyMs = DateTime.now().millisecondsSinceEpoch - startTime;
      DevNetworkLogger.instance.logRequest(
        method: request.method,
        url: request.url.toString(),
        statusCode: null,
        latencyMs: latencyMs,
        requestBody: requestBody,
        responseBody: 'ERROR: $e',
        headers: request.headers,
      );
      rethrow;
    }
  }
}

final _client = _DevDevHttpClient();

Future<http_pkg.Response> get(Uri url, {Map<String, String>? headers}) => _client.get(url, headers: headers);
Future<http_pkg.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => _client.post(url, headers: headers, body: body, encoding: encoding);
Future<http_pkg.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => _client.put(url, headers: headers, body: body, encoding: encoding);
Future<http_pkg.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => _client.patch(url, headers: headers, body: body, encoding: encoding);
Future<http_pkg.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => _client.delete(url, headers: headers, body: body, encoding: encoding);
