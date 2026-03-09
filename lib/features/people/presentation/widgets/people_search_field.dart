import 'package:flutter/material.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';

class PeopleSearchField extends StatelessWidget {
  const PeopleSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    super.key,
    this.focusNode,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.64)),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
