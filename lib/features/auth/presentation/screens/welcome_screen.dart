import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/constants/greeting_constants.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    required this.name,
    super.key,
    this.username,
    this.avatarUrl,
    this.avatarFileId,
    this.description,
    this.phone,
  });
  final String name;
  final String? username;
  final String? avatarUrl;
  final String? avatarFileId;
  final String? description;
  final String? phone;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  Timer? _timer;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _greeting = GreetingConstants
        .greetings[Random().nextInt(GreetingConstants.greetings.length)];
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
    _timer = Timer(
      GreetingConstants.welcomeScreenDuration + const Duration(seconds: 1),
      _transitionToMain,
    );
  }

  void _transitionToMain() {
    _ctrl.reverse().then((_) {
      if (mounted) {
        context.go(AppStrings.routeHome);
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
                padding: const EdgeInsets.all(UITokens.spaceXL),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: UITokens.spaceSm),
                    Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (widget.username != null &&
                        widget.username!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: UITokens.spaceSm),
                        child: Text(
                          '@${widget.username!.trim()}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    const SizedBox(height: GreetingConstants.spacingSmall),
                    if (widget.description != null &&
                        widget.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: UITokens.spaceSm),
                        child: Text(
                          widget.description!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                        ),
                      ),
                    if ((widget.phone ?? '').trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: UITokens.spaceSmMd),
                        child: Text(
                          widget.phone!.trim(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.65),
                              ),
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
