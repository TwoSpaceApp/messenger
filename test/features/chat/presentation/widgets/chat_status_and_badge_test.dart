import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/widgets/unread_badge.dart';
import 'package:two_space_app/features/chat/presentation/widgets/message_status_icon.dart';

Widget _createTestShell(Widget child) {
  return ShadApp.custom(
    themeMode: ThemeMode.light,
    theme: ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadSlateColorScheme.light(),
    ),
    darkTheme: ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadSlateColorScheme.dark(),
    ),
    appBuilder: (_) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: ShadAppBuilder(child: child),
        ),
      ),
    ),
  );
}

Future<void> _pumpInShell(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_createTestShell(child));
  await tester.pumpAndSettle();
}

Future<void> _disposeShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  group('MessageStatusIcon', () {
    testWidgets('renders pending state first', (tester) async {
      await _pumpInShell(
        tester,
        const MessageStatusIcon(
          isPending: true,
          isDelivered: false,
          isRead: false,
        ),
      );

      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      await _disposeShell(tester);
    });

    testWidgets('animates from sent to read state', (tester) async {
      await _pumpInShell(
        tester,
        const MessageStatusIcon(
          isPending: false,
          isDelivered: false,
          isRead: false,
        ),
      );

      expect(find.byIcon(Icons.done_rounded), findsOneWidget);

      await tester.pumpWidget(
        _createTestShell(
          const MessageStatusIcon(
            isPending: false,
            isDelivered: true,
            isRead: true,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 260));
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
      await _disposeShell(tester);
    });
  });

  group('UnreadBadge', () {
    testWidgets('hides when count is zero', (tester) async {
      await _pumpInShell(tester, const UnreadBadge(count: 0));

      expect(find.byType(ShadBadge), findsNothing);
      expect(find.text('0'), findsNothing);
      await _disposeShell(tester);
    });

    testWidgets('shows compact capped count', (tester) async {
      await _pumpInShell(tester, const UnreadBadge(count: 142));

      expect(find.byType(ShadBadge), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      await _disposeShell(tester);
    });
  });
}
