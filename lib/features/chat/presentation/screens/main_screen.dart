import 'package:flutter/material.dart';
import 'package:two_space_app/core/widgets/floating_nav_bar.dart';
import 'package:two_space_app/features/chat/presentation/screens/home_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/calls_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/contacts_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
