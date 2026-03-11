import 'package:flutter/foundation.dart';

class DevToolsService {
  DevToolsService._();

  static final ValueNotifier<bool> performanceOverlayEnabled =
      ValueNotifier(false);
}
