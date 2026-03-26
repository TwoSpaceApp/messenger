import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({
    required this.count,
    super.key,
  });

  final int count;

  String get _label => count > 99 ? '99+' : '$count';

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return ShadBadge(
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
