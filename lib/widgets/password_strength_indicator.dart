import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            color: index < strength
                ? _getColor(strength)
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Color _getColor(int strength) {
    switch (strength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
