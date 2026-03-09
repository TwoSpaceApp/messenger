import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', requireEnvFile: true)
abstract class Env {
    @EnviedField(varName: 'MATRIX_ENABLE', defaultValue: 'false')
  static const String matrixEnable = _Env.matrixEnable;

  @EnviedField(
      varName: 'MATRIX_HOMESERVER_URL', defaultValue: 'https://matrix.org')
  static const String matrixHomeserverUrl = _Env.matrixHomeserverUrl;

  @EnviedField(varName: 'MATRIX_SERVER_NAME', defaultValue: '')
  static const String matrixServerName = _Env.matrixServerName;

  @EnviedField(varName: 'MATRIX_ACCESS_TOKEN', defaultValue: '')
  static const String matrixAccessToken = _Env.matrixAccessToken;

  @EnviedField(varName: 'ENABLE_DEV_TOOLS', defaultValue: 'false')
  static const String enableDevTools = _Env.enableDevTools;

  @EnviedField(varName: 'APP_ENV', defaultValue: 'development')
  static const String appEnv = _Env.appEnv;

  @EnviedField(varName: 'SENTRY_DSN', defaultValue: '')
  static const String sentryDsn = _Env.sentryDsn;

    @EnviedField(varName: 'AEGIS_HOST', defaultValue: '95.215.56.43')
  static const String aegisHost = _Env.aegisHost;

  @EnviedField(varName: 'AEGIS_PORT', defaultValue: '8888')
  static const String aegisPort = _Env.aegisPort;

  @EnviedField(varName: 'AEGIS_CONNECT_TIMEOUT_SECONDS', defaultValue: '10')
  static const String aegisConnectTimeoutSeconds =
      _Env.aegisConnectTimeoutSeconds;
}
