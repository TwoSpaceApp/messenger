import 'package:flutter/material.dart';
import 'package:two_space_app/widgets/floating_nav_bar.dart';
import 'package:two_space_app/screens/home_screen.dart';
import 'package:two_space_app/screens/calls_screen.dart';
import 'package:two_space_app/screens/contacts_screen.dart';
import 'package:two_space_app/screens/settings_screen.dart';

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
