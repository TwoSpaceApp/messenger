import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Reusable user avatar widget.
/// Supports local files, network URLs and initials fallback.
class UserAvatar extends StatefulWidget {
  const UserAvatar(
      {super.key,
      this.avatarUrl,
      this.avatarFileId,
      this.name,
      this.radius = 24});
  final String? avatarUrl;
  final String? avatarFileId;
  final String? name;
  final double radius;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _bytes;
  static final Map<String, Uint8List> _cache = {};

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If avatar data changed, clear cached bytes and reload
    if (oldWidget.avatarFileId != widget.avatarFileId ||
        oldWidget.avatarUrl != widget.avatarUrl) {
      if (widget.avatarFileId != null && widget.avatarFileId!.isNotEmpty) {
        _cache.remove(widget.avatarFileId);
      }
      _bytes = null;
      _loadIfNeeded();
    }
  }

  Future<void> _loadIfNeeded() async {
    final fid = widget.avatarFileId;
    final url = widget.avatarUrl;

    if (url != null && url.isNotEmpty && !url.startsWith('http')) {
      try {
        final file = File(url);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted) setState(() => _bytes = bytes);
          return;
        }
      } catch (_) {}
    }

    if (fid == null || fid.isEmpty) {
      return;
    }
    if (fid.isNotEmpty && _cache.containsKey(fid)) {
      setState(() => _bytes = _cache[fid]);
      return;
    }
    try {
      final file = File(fid);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        _cache[fid] = bytes;
        if (mounted) setState(() => _bytes = bytes);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;
    if (_bytes != null) {
      return CircleAvatar(
          radius: r,
          backgroundColor: Colors.transparent,
          child: ClipOval(
              child: Image.memory(_bytes!,
                  width: r * 2, height: r * 2, fit: BoxFit.cover)));
    }
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        key: ValueKey(widget.avatarUrl),
        radius: r,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: NetworkImage(widget.avatarUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback on network image load error
        },
      );
    }

    // Gradient fallback for text avatars
    final nameVal = widget.name ?? '?';
    final hash = nameVal.hashCode;
    final h1 = (hash % 360).toDouble();
    final h2 = ((hash ~/ 360) % 360).toDouble();
    final colors = [
      HSVColor.fromAHSV(1, h1, 0.7, 0.9).toColor(),
      HSVColor.fromAHSV(1, h2, 0.8, 0.8).toColor(),
    ];
    final initial = nameVal.isNotEmpty ? nameVal[0].toUpperCase() : '?';

    return Container(
      width: r * 2,
      height: r * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: r * 0.9, // Adjust size based on radius
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
