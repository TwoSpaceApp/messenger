import 'package:flutter/material.dart';
import 'package:two_space_app/widgets/floating_nav_bar.dart';
import 'package:two_space_app/screens/home_screen.dart';
import 'package:two_space_app/screens/calls_screen.dart';
import 'package:two_space_app/screens/contacts_screen.dart';
import 'package:two_space_app/screens/profile_screen.dart';
import 'package:two_space_app/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    AuthService().getCurrentUserId().then((id) {
      if (mounted) setState(() => _myUserId = id);
    });
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // If we don't have user ID yet, maybe show loading or placeholder for profile
    // But other tabs work.
    
    final screens = [
      const HomeScreen(),
      const CallsScreen(),
      const ContactsScreen(),
      if (_myUserId != null) 
        ProfileScreen(userId: _myUserId!) 
      else 
        const Scaffold(body: Center(child: CircularProgressIndicator())),
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
