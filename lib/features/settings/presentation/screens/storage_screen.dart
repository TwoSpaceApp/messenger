import 'dart:math';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class StoragePieChart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width, height: size.height);
    
    // App size (Blue)
    paint.color = Colors.blue;
    canvas.drawArc(rect, -pi/2, pi/2, true, paint);
    
    // Cache (Red)
    paint.color = Colors.red;
    canvas.drawArc(rect, 0, pi, true, paint);
    
    // User Data (Green)
    paint.color = Colors.green;
    canvas.drawArc(rect, pi, pi/2, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsStorageManagement)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(painter: StoragePieChart()),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.circle, color: Colors.blue),
            title: Text(l10n.settingsStorageAppSize),
            trailing: const Text('150 MB'),
          ),
          ListTile(
            leading: const Icon(Icons.circle, color: Colors.red),
            title: Text(l10n.settingsStorageKeepChat),
            trailing: const Text('400 MB'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.settingsStorageClearBtn),
          )
        ],
      ),
    );
  }
}
