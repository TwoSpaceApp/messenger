import 'package:flutter/material.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({
    required this.userId,
    super.key,
    this.embedded = false,
  });

  final String userId;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      userId: userId,
      embedded: embedded,
      variant: ProfileScreenVariant.account,
    );
  }
}
