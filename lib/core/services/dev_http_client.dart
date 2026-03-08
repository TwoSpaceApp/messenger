import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio_pkg;

// Симуляция классов пакета http
class Response {
  Response(this.body, this.statusCode,
      {this.headers = const {}, Uint8List? bytes})
      : bodyBytes = bytes ?? Uint8List.fromList(utf8.encode(body));
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

final dio_pkg.Dio _dio = dio_pkg.Dio();

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
      // ignore: empty_catches
    } catch (_) {}
  }
  return body;
}

Future<Response> get(Uri url, {Map<String, String>? headers}) async {
  try {
    final res =
        await _dio.getUri(url, options: dio_pkg.Options(headers: headers));
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> post(Uri url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  try {
    final res = await _dio.postUri(url,
        data: _parseBody(body), options: dio_pkg.Options(headers: headers));
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> put(Uri url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  try {
    final res = await _dio.putUri(url,
        data: _parseBody(body), options: dio_pkg.Options(headers: headers));
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> patch(Uri url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  try {
    final res = await _dio.patchUri(url,
        data: _parseBody(body), options: dio_pkg.Options(headers: headers));
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}

Future<Response> delete(Uri url,
    {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  try {
    final res = await _dio.deleteUri(url,
        data: _parseBody(body), options: dio_pkg.Options(headers: headers));
    return _mapDioResponse(res);
  } on dio_pkg.DioException catch (e) {
    if (e.response != null) return _mapDioResponse(e.response!);
    throw Exception(e.message);
  }
}
