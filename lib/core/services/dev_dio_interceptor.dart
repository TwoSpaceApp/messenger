import 'package:dio/dio.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';

class DevDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(response.requestOptions, response: response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, error: err);
    super.onError(err, handler);
  }

  void _log(RequestOptions options, {Response? response, DioException? error}) {
    final startTime = options.extra['startTime'] as int?;
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final latencyMs = startTime != null ? endTime - startTime : 0;

    dynamic responseBody;
    int? statusCode;

    if (response != null) {
      responseBody = response.data;
      statusCode = response.statusCode;
    } else if (error != null) {
      responseBody = error.response?.data ?? error.message;
      statusCode = error.response?.statusCode;
    }

    DevNetworkLogger.instance.logRequest(
      method: options.method,
      url: options.uri.toString(),
      statusCode: statusCode,
      latencyMs: latencyMs,
      requestBody: options.data,
      responseBody: responseBody,
      headers: options.headers,
    );
  }
}
