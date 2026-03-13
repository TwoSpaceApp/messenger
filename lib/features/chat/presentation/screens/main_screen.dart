import 'package:flutter/material.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/core/widgets/floating_nav_bar.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/calls_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/home_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/contacts_screen.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLocked = false;
  bool _biometricCheckInFlight = false;
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CallsScreen(),
    ContactsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometrics();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      AegisChatService().flushNow();
    }
  }

  Future<void> _checkBiometrics() async {
    if (!SettingsService.biometricsNotifier.value) return;

    if (_biometricCheckInFlight) return;
    _biometricCheckInFlight = true;
    if (mounted && !_isLocked) {
      setState(() => _isLocked = true);
    }
    
    try {
      final success = await BiometricService.authenticate('Unlock App');
      if (success && mounted && _isLocked) {
        setState(() => _isLocked = false);
      }
    } finally {
      _biometricCheckInFlight = false;
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkBiometrics,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          FloatingNavBar(
            selectedIndex: _currentIndex,
            onItemSelected: _onTabChanged,
          ),
        ],
      ),
    );
  }
}
