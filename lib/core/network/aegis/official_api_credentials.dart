/// Application credentials sent during the Aegis protocol handshake.
class AegisApiCredentials {
  final int appId;
  final String appHash;

  const AegisApiCredentials({
    required this.appId,
    required this.appHash,
  })  : assert(appId > 0, 'appId must be positive'),
        assert(appHash != '', 'appHash must not be empty');
}

/// Built-in credentials for the first-party Aegis Dart client.
class AegisOfficialApiCredentials {
  static const AegisApiCredentials credentials = AegisApiCredentials(
    appId: 2041001,
    appHash: '8f4c1db0e7c2456d9ab31f4e6d8c9a0137f2c4b56d8e1a903bc7d52e6f194a3c',
  );
}
