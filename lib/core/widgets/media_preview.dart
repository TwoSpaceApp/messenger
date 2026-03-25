import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

/// Simple media preview widget used in chat messages and galleries.
class MediaPreview extends StatefulWidget {
  const MediaPreview(
      {required this.mediaId,
      super.key,
      this.filename,
      this.mimeType,
      this.maxHeight,
      this.autoDownload = false});
  final String mediaId;
  final String? filename;
  final String? mimeType; // optional mime type passed from callers
  final double? maxHeight;
  final bool autoDownload;

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  static final Map<String, String> _pathCache = <String, String>{};

  bool _loading = false;
  String? _error;
  String? _resolvedPath;
  final AegisChatService _chatService = AegisChatService();

  @override
  void initState() {
    super.initState();
    if (widget.autoDownload) {
      // trigger a background download (ignore errors, show a tiny progress)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _download();
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_resolveLocalPathIfAvailable());
      }
    });
  }

  Future<void> _resolveLocalPathIfAvailable() async {
    try {
      if (_resolvedPath != null) return;
      final cachedPath = _pathCache[widget.mediaId];
      if (cachedPath != null && await File(cachedPath).exists()) {
        if (mounted) {
          setState(() {
            _resolvedPath = cachedPath;
          });
        }
        return;
      }

      final file = File(widget.mediaId);
      if (await file.exists()) {
        _pathCache[widget.mediaId] = file.path;
        if (mounted) {
          setState(() {
            _resolvedPath = file.path;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<String> _ensureResolvedPath() async {
    final currentPath = _resolvedPath;
    if (currentPath != null && await File(currentPath).exists()) {
      return currentPath;
    }

    final cachedPath = _pathCache[widget.mediaId];
    if (cachedPath != null && await File(cachedPath).exists()) {
      if (mounted) {
        setState(() {
          _resolvedPath = cachedPath;
        });
      }
      return cachedPath;
    }

    final downloadedPath = await _chatService.downloadMediaToTempFile(widget.mediaId);
    _pathCache[widget.mediaId] = downloadedPath;
    if (mounted) {
      setState(() {
        _resolvedPath = downloadedPath;
      });
    }
    return downloadedPath;
  }

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final path = await _ensureResolvedPath();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.fileDownloaded(path))));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveToGallery() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final temp = await _ensureResolvedPath();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.fileSavedTemp(temp))));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _share() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final temp = await _ensureResolvedPath();
      await Share.shareXFiles([XFile(temp)], text: widget.filename);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRemote = widget.mediaId.startsWith('http://') ||
        widget.mediaId.startsWith('https://');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Builder(
            builder: (c) {
              if (_resolvedPath != null) {
                return Image.file(File(_resolvedPath!), fit: BoxFit.cover);
              }
              if (isRemote) {
                return Image.network(widget.mediaId,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, st) =>
                        const Center(child: Icon(Icons.broken_image)));
              }
              return const Center(child: Icon(Icons.insert_drive_file));
            },
          ),
        ),
        if (_error != null)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.errorWithDetail(_error!),
                  style: const TextStyle(color: Colors.red))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: _loading ? null : _download,
                icon: const Icon(Icons.download)),
            IconButton(
                onPressed: _loading ? null : _saveToGallery,
                icon: const Icon(Icons.save_alt)),
            IconButton(
                onPressed: _loading ? null : _share,
                icon: const Icon(Icons.share)),
          ],
        ),
      ],
    );
  }
}
