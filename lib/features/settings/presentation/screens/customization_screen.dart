import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class CustomizationScreen extends ConsumerWidget {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = SettingsService.themeNotifier.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customization'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(
                            themeNotifier.primaryColorValue,
                          ).withValues(alpha: 0.2),
                          Color(
                            themeNotifier.primaryColorValue,
                          ).withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Custom Theme',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(themeNotifier.primaryColorValue),
                                ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Sample Button'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Color Section
          Text(
            'Color',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: GridView.count(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                ...['FF6B6B', 'FF8E44', 'F1D64E', '6BCB77', '4D96FF'].map((
                  color,
                ) {
                  final colorValue = int.parse('FF$color', radix: 16);
                  return _ColorOption(
                    color: Color(colorValue),
                    isSelected: themeNotifier.primaryColorValue == colorValue,
                    onTap: () {
                      SettingsService.updateTheme(
                        primaryColorValue: colorValue,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Font Section
          Text(
            'Font Family',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            ('Inter', 'Modern & Clean'),
            ('Roboto', 'Google Sans'),
            ('OpenSans', 'Professional'),
            ('Oswald', 'Bold & Strong'),
          ].map((font) {
            return _FontOption(
              name: font.$1,
              description: font.$2,
              isSelected: themeNotifier.fontFamily == font.$1,
              onTap: () {
                SettingsService.updateTheme(fontFamily: font.$1);
              },
            );
          }),
          const SizedBox(height: 24),

          // Shape Variant Section
          Text(
            'Shape Style',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            (ShapeVariant.compact, '◻️ Compact', 'Sharp corners'),
            (ShapeVariant.rounded, '⬤ Rounded', 'Balanced radius'),
            (ShapeVariant.expressive, '◐ Expressive', 'Large radius'),
          ].map((shape) {
            return _ShapeOption(
              label: shape.$2,
              description: shape.$3,
              isSelected: themeNotifier.shapeVariant == shape.$1,
              onTap: () {
                SettingsService.updateTheme(shapeVariant: shape.$1);
              },
            );
          }),
          const SizedBox(height: 24),

          // Compact Mode
          Card(
            child: SwitchListTile(
              title: const Text('Compact Mode'),
              subtitle: const Text('Reduce padding and spacing'),
              value: themeNotifier.compactMode,
              onChanged: (value) {
                SettingsService.updateTheme(compactMode: value);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                  width: 3,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _FontOption extends StatelessWidget {
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontOption({
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Text(name, style: TextStyle(fontFamily: name)),
        subtitle: Text(description),
        trailing: isSelected
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _ShapeOption extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShapeOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: ListTile(
        title: Text(label),
        subtitle: Text(description),
        trailing: isSelected
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
