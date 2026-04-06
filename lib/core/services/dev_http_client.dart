import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio_pkg;
import 'package:two_space_app/core/services/dev_network_logger.dart';

// Симуляция классов пакета http
class Response {
  Response(
    this.body,
    this.statusCode, {
    this.headers = const {},
    Uint8List? bytes,
  }) : bodyBytes = bytes ?? Uint8List.fromList(utf8.encode(body));
  final String body;
  final int statusCode;
  final Map<String, String> headers;
  final Uint8List bodyBytes;
}

class StreamedResponse extends Response {
  StreamedResponse(super.body, super.statusCode, {super.headers});
}

// Заглушки для Multipart
class BaseRequest {}

class Request extends BaseRequest {
  Request(this.method, this.url) : headers = {};
  final String method;
  final Uri url;
  final Map<String, String> headers;
}

class MultipartRequest extends BaseRequest {}

class Client {
  void close() {}
}

class ByteStream {}

final dio_pkg.Dio _dio = dio_pkg.Dio()
  ..interceptors.add(
    dio_pkg.InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['startTime'] as int?;
        final latencyMs = startTime != null
            ? DateTime.now().millisecondsSinceEpoch - startTime
            : 0;

        DevNetworkLogger.instance.logRequest(
          method: response.requestOptions.method,
          url: response.requestOptions.uri.toString(),
          statusCode: response.statusCode,
          latencyMs: latencyMs,
          requestBody: response.requestOptions.data,
          responseBody: response.data,
          requestHeaders: response.requestOptions.headers,
          responseHeaders: {
            for (final entry in response.headers.map.entries)
              entry.key: entry.value.join(', '),
          },
        );

        return handler.next(response);
      },
      onError: (e, handler) {
        final startTime = e.requestOptions.extra['startTime'] as int?;
        final latencyMs = startTime != null
            ? DateTime.now().millisecondsSinceEpoch - startTime
            : 0;

        DevNetworkLogger.instance.logRequest(
          method: e.requestOptions.method,
          url: e.requestOptions.uri.toString(),
          statusCode: e.response?.statusCode,
          latencyMs: latencyMs,
          requestBody: e.requestOptions.data,
          responseBody: e.response?.data ?? e.message,
          requestHeaders: e.requestOptions.headers,
          responseHeaders: {
            if (e.response != null)
              for (final entry in e.response!.headers.map.entries)
                entry.key: entry.value.join(', '),
          },
          errorMessage: e.message,
        );

        return handler.next(e);
      },
    ),
  );

Response _mapDioResponse(dio_pkg.Response res) {
  final dynamic data = res.data;
  final body = data is String ? data : jsonEncode(data);
  final headers = <String, String>{};
  res.headers.forEach((name, values) {
    if (values.isNotEmpty) headers[name] = values.first;
  });
  return Response(body, res.statusCode ?? 500, headers: headers);
}

dynamic _parseBody(Object? body) {
  if (body == null) return null;
  if (body is String) {
    try {
      return jsonDecode(body);
    } on FormatException catch (_) {}
  }
  return body;
}

Future<Response> get(Uri url, {Map<String, String>? headers}) async {
  try {
    final res = await _dio.getUri(
      url,
      options: dio_pkg.Options(headers: headers),
    );
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  try {
    final res = await _dio.postUri(
      url,
      data: _parseBody(body),
      options: dio_pkg.Options(headers: headers),
    );
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  try {
    final res = await _dio.putUri(
      url,
      data: _parseBody(body),
      options: dio_pkg.Options(headers: headers),
    );
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  try {
    final res = await _dio.patchUri(
      url,
      data: _parseBody(body),
      options: dio_pkg.Options(headers: headers),
    );
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  try {
    final res = await _dio.deleteUri(
      url,
      data: _parseBody(body),
      options: dio_pkg.Options(headers: headers),
    );
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}
