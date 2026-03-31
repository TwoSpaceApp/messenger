import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/chat/presentation/widgets/feature_in_development_dialog.dart';

Widget _buildShell() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showFeatureInDevelopmentDialog(
              context,
              feature: 'Leave room',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows localized in-development dialog content', (tester) async {
    await tester.pumpWidget(_buildShell());

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('In development'), findsOneWidget);
    expect(find.text('Leave room'), findsOneWidget);
    expect(
      find.text(
        'Leave room is in development and will appear here in a future update.',
      ),
      findsOneWidget,
    );
  });
}
