import 'package:flutter/material.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/core/widgets/floating_nav_bar.dart';
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
    }
  }

  Future<void> _checkBiometrics() async {
    if (!SettingsService.biometricsNotifier.value) return;
    
    setState(() => _isLocked = true);
    
    final success = await BiometricService.authenticate('Unlock App');
    if (success && mounted) {
      setState(() => _isLocked = false);
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

    final screens = [
      const HomeScreen(),
      const CallsScreen(),
      const ContactsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
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
