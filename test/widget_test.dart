import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_game/app.dart';

void main() {
  testWidgets('App smoke test - verifies Lobby Screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GuessGameApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that Lobby Screen renders
    expect(find.text('HOST A NEW ROOM'), findsOneWidget);
    expect(find.text('Create New Game Room'), findsOneWidget);
    expect(find.text('Join Game Room'), findsOneWidget);
  });
}
