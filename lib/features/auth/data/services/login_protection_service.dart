class LoginProtectionService {
  factory LoginProtectionService() => _instance;

  LoginProtectionService._();

  static final LoginProtectionService _instance = LoginProtectionService._();

  int _failedAttempts = 0;
  DateTime? _cooldownUntil;

  bool get isCoolingDown {
    final cooldownUntil = _cooldownUntil;
    if (cooldownUntil == null) {
      return false;
    }
    if (DateTime.now().isAfter(cooldownUntil)) {
      _cooldownUntil = null;
      return false;
    }
    return true;
  }

  int get remainingCooldownSeconds {
    final cooldownUntil = _cooldownUntil;
    if (cooldownUntil == null) {
      return 0;
    }
    final remaining = cooldownUntil.difference(DateTime.now()).inSeconds;
    return remaining <= 0 ? 0 : remaining;
  }

  void recordSuccess() {
    _failedAttempts = 0;
    _cooldownUntil = null;
  }

  void recordFailure() {
    _failedAttempts += 1;

    Duration? cooldown;
    if (_failedAttempts >= 8) {
      cooldown = const Duration(seconds: 60);
    } else if (_failedAttempts >= 5) {
      cooldown = const Duration(seconds: 20);
    } else if (_failedAttempts >= 3) {
      cooldown = const Duration(seconds: 8);
    }

    if (cooldown != null) {
      _cooldownUntil = DateTime.now().add(cooldown);
    }
  }
}
