import 'dart:async';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({required this.phone, super.key});
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _controller = TextEditingController();
  final bool _loading = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isEmpty || code.length < 4) return; // basic guard
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor =
        Color(SettingsService.themeNotifier.value.primaryColorValue);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.confirmCodeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.codeSentTo(widget.phone),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.enterCodeHint),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(l10n.confirmButton),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _secondsLeft > 0
                  ? null
                  : () {
                      // Signal caller to resend by popping null and letting caller re-send token
                      Navigator.of(context).pop();
                    },
              child: Text(_secondsLeft > 0
                  ? l10n.resendCountdown(_secondsLeft)
                  : l10n.resendCodeButton),
            ),
          ],
        ),
      ),
    );
  }
}
