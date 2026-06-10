import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

class Pong {
  Pong({required this.latencyMs});

  factory Pong.fromJson(Map<String, dynamic> json) => Pong(
    latencyMs: (json["LatencyMs"] as num? ?? 0).toInt(),
  );

  factory Pong.fromBytes(List<int> bytes) {
    return Pong.fromJson(decodePayloadMap(bytes));
  }
  final int latencyMs;

  Map<String, dynamic> toJson() => {'LatencyMs': latencyMs};
  List<int> toBytes() => msgpack.serialize(toJson());
}

class KeepAliveExponential {
  KeepAliveExponential({
    required this.lastSeqReceived,
    this.backoffLevel = 0,
  });

  factory KeepAliveExponential.fromJson(Map<String, dynamic> json) =>
      KeepAliveExponential(
        lastSeqReceived: (json["LastSeqReceived"] as num? ?? 0).toInt(),
        backoffLevel: (json["BackoffLevel"] as num? ?? 0).toInt(),
      );
  final int lastSeqReceived;
  final int backoffLevel;

  Map<String, dynamic> toJson() => {
    'LastSeqReceived': lastSeqReceived,
    'BackoffLevel': backoffLevel,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class KeepAliveExponentialResponse {
  KeepAliveExponentialResponse({required this.success});

  factory KeepAliveExponentialResponse.fromJson(Map<String, dynamic> json) =>
      KeepAliveExponentialResponse(
        success: json["Success"] as bool? ?? false,
      );

  factory KeepAliveExponentialResponse.fromBytes(List<int> bytes) =>
      KeepAliveExponentialResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
}
