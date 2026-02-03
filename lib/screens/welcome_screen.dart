import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:two_space_app/constants/greeting_constants.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';

import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String name;
  final String? avatarUrl;
  final String? avatarFileId;
  final String? description;
  final String? phone;
  const WelcomeScreen({super.key, required this.name, this.avatarUrl, this.avatarFileId, this.description, this.phone});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  Timer? _timer;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _greeting = GreetingConstants.greetings[Random().nextInt(GreetingConstants.greetings.length)];
    _ctrl = AnimationController(
      vsync: this,
      duration: GreetingConstants.animationDuration,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _scale = Tween<double>(
      begin: GreetingConstants.scaleStart,
      end: GreetingConstants.scaleEnd,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    
    _ctrl.forward();
    
    // Transition to MainScreen after displaying welcome message
    _timer = Timer(GreetingConstants.welcomeScreenDuration + const Duration(seconds: 1), _transitionToMain);
  }

  void _transitionToMain() {
    _ctrl.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use ScreenBackground to ensure it matches the chosen theme
    return Scaffold(
      body: ScreenBackground(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: GlassCard(
                borderRadius: GreetingConstants.cardBorderRadius,
                 padding: const EdgeInsets.all(32),
                 child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAvatar(
                      avatarUrl: widget.avatarUrl,
                      avatarFileId: widget.avatarFileId,
                      name: widget.name,
                      radius: GreetingConstants.avatarRadius * 1.5,
                    ),
                    const SizedBox(height: GreetingConstants.spacingLarge),
                    Text(
                      _greeting, // Using random greeting
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                     const SizedBox(height: 8),
                    Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: GreetingConstants.spacingSmall),
                    if (widget.description != null && widget.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                         child: Text(
                          widget.description!,
                           textAlign: TextAlign.center,
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                         ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
