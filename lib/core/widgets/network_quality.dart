import 'dart:async';

import 'package:flutter/material.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';

/// Shows simple network quality indicator (0-3 bars) based on ping RTT to
/// the configured Aegis server. This is a light-weight heuristic and
/// intended for UI feedback only.
class NetworkQualityIndicator extends StatefulWidget {
  const NetworkQualityIndicator({super.key});

  @override
  State<NetworkQualityIndicator> createState() =>
      _NetworkQualityIndicatorState();
}

class _NetworkQualityIndicatorState extends State<NetworkQualityIndicator> {
  Timer? _timer;
  int _bars = 0; // 0..3
  int? _rttMs;
  final AegisAuthService _auth = AegisAuthService();

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    try {
      // Reuse the existing protocol connection instead of opening a
      // throwaway TCP socket every probe.
      if (!_auth.isConnected || !_auth.isAuthenticated) {
        if (mounted) setState(() => _bars = 0);
        return;
      }

      final sw = Stopwatch()..start();
      await _auth.rawClient.ping();
      sw.stop();

      final rtt = sw.elapsedMilliseconds;
      var bars = 0;
      if (rtt < 120) {
        bars = 3;
      } else if (rtt < 400) {
        bars = 2;
      } else if (rtt < 1200) {
        bars = 1;
      } else {
        bars = 0;
      }
      if (mounted) {
        setState(() {
          _bars = bars;
          _rttMs = rtt;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _bars = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _bars >= 2
        ? Colors.greenAccent
        : (_bars == 1 ? Colors.orangeAccent : Colors.redAccent);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (i) {
          final active = i < _bars;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 8,
              height: 8 + i * 6,
              decoration: BoxDecoration(
                color: active
                    ? color
                    : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        if (_rttMs != null) ...[
          const SizedBox(width: 8),
          Text('${_rttMs!} ms', style: TextStyle(color: color, fontSize: 12)),
        ],
      ],
    );
  }
}
