import 'package:flutter/material.dart';
import 'package:two_space_app/core/utils/responsive.dart';
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
    final horizontalPadding = 12.s(context);
    final iconSize = 20.s(context);
    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 15.s(context),
            ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.64)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white70,
            size: iconSize,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: iconSize,
                  ),
                )
              : null,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
