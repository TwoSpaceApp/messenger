import 'package:dio/dio.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:flutter/foundation.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  Dio? _dio;

  Dio get dio {
    if (_dio == null) {
      _dio = Dio();
      _configureDio();
    }
    return _dio!;
  }

  void _configureDio() {
    final proxySettings = SettingsService.proxySettings;
    final bool proxyEnabled = proxySettings['enabled'] ?? false;

    if (proxyEnabled) {
      final String? host = proxySettings['host'];
      final String? port = proxySettings['port'];
      final String? username = proxySettings['username'];
      final String? password = proxySettings['password'];

      if (host != null && port != null) {
        final proxy = 'PROXY $host:$port';
        if (kDebugMode) {
          print('Configuring Dio with proxy: $proxy');
        }

        (_dio!.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
          client.findProxy = (uri) {
            return proxy;
          };
          // If proxy requires authentication
          if (username != null && password != null && username.isNotEmpty && password.isNotEmpty) {
            client.authenticateProxy = (host, port, scheme, realm) {
              client.addCredentials(
                Uri.parse('http://$host:$port'),
                realm,
                HttpClientBasicCredentials(username, password),
              );
              return true;
            };
          }
          return client;
        };
      } else {
        if (kDebugMode) {
          print('Proxy enabled but host or port is missing.');
        }
      }
    } else {
      // Ensure no proxy is set if disabled
      (_dio!.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = null;
      if (kDebugMode) {
        print('Proxy is disabled.');
      }
    }
  }

  // Method to reconfigure Dio if settings change
  void reconfigure() {
    _dio = null; // Force re-creation with new settings
    _dio = Dio();
    _configureDio();
  }
}
