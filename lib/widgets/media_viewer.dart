import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:two_space_app/l10n/app_localizations.dart';

class MediaViewer extends StatelessWidget {
  final Uint8List? bytes;
  final String? localPath;
  final String? title;

  const MediaViewer({super.key, this.bytes, this.localPath, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget child;
    if (bytes != null) {
      child = InteractiveViewer(child: Image.memory(bytes!, fit: BoxFit.contain));
    } else if (localPath != null) {
      final file = File(localPath!);
      child = InteractiveViewer(child: Image.file(file, fit: BoxFit.contain));
    } else {
      child = Center(child: Text(l10n.noData));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title ?? l10n.previewTitle)),
      body: Center(child: child),
    );
  }
}
