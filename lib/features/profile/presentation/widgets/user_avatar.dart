import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/utils/aegis_avatar_url.dart';

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

  Uint8List? _decodeDataUri(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || !value.startsWith('data:')) {
      return null;
    }

    try {
      return UriData.parse(value).contentAsBytes();
    } catch (_) {
      return null;
    }
  }

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
    final url = widget.avatarUrl?.trim();

    final inlineBytes = _decodeDataUri(url);
    if (inlineBytes != null) {
      if (mounted) setState(() => _bytes = inlineBytes);
      return;
    }

    if (isLocalAvatarFilePath(url)) {
      try {
        final file = File(url!);
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
    final normalizedUrl = normalizeAegisAvatarUrl(widget.avatarUrl);
    if (_bytes != null) {
      return CircleAvatar(
          radius: r,
          backgroundColor: Colors.transparent,
          child: ClipOval(
              child: Image.memory(_bytes!,
                  width: r * 2, height: r * 2, fit: BoxFit.cover)));
    }
    if (normalizedUrl != null &&
        normalizedUrl.isNotEmpty &&
        !normalizedUrl.startsWith('data:') &&
        !isLocalAvatarFilePath(normalizedUrl)) {
      return CircleAvatar(
        key: ValueKey(normalizedUrl),
        radius: r,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: NetworkImage(normalizedUrl),
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
