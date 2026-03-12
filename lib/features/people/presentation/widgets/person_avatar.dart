import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/utils/aegis_avatar_url.dart';

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    required this.name,
    super.key,
    this.avatarUrl,
    this.photoBytes,
    this.radius = 24,
    this.showOnline = false,
  });

  final String name;
  final String? avatarUrl;
  final Uint8List? photoBytes;
  final double radius;
  final bool showOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedAvatarUrl = normalizeAegisAvatarUrl(avatarUrl);
    final imageProvider = photoBytes != null
        ? MemoryImage(photoBytes!) as ImageProvider<Object>
      : (normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty)
        ? NetworkImage(normalizedAvatarUrl)
            : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.24),
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        if (showOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
