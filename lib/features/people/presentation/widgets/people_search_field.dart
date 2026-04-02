import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/app_colors.dart';
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
    final theme = Theme.of(context);

    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ShadInput(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontSize: 15.s(context),
        ),
        onChanged: onChanged,
        placeholder: Text(
          hintText,
          style: TextStyle(color: AppColors.hintText(context)),
        ),
        leading: Icon(
          Icons.search_rounded,
          color: AppColors.iconMuted(context),
          size: iconSize,
        ),
        trailing: controller.text.isNotEmpty
            ? ShadIconButton.ghost(
                width: 32.s(context),
                height: 32.s(context),
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.iconMuted(context),
                  size: iconSize,
                ),
              )
            : null,
      ),
    );
  }
}
