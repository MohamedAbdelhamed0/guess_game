import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_game/presentation/dialogs/full_screen_image_viewer.dart';

void main() {
  testWidgets('FullScreenImageViewer renders title, controls, and responds to zoom buttons',
      (WidgetTester tester) async {
    // 1x1 transparent PNG bytes for testing
    final testBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                FullScreenImageViewer.show(
                  context,
                  imageBytes: testBytes,
                  title: "Opponent's Photo",
                  subtitle: "Tap to zoom",
                );
              },
              child: const Text('Open Viewer'),
            ),
          ),
        ),
      ),
    );

    // Tap button to open viewer
    await tester.tap(find.text('Open Viewer'));
    await tester.pumpAndSettle();

    // Verify viewer elements are visible
    expect(find.text("Opponent's Photo"), findsOneWidget);
    expect(find.text("Tap to zoom"), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byTooltip('Zoom In'), findsOneWidget);
    expect(find.byTooltip('Zoom Out'), findsOneWidget);
    expect(find.byTooltip('Fit to Screen'), findsOneWidget);

    // Tap Zoom In button
    await tester.tap(find.byTooltip('Zoom In'));
    await tester.pumpAndSettle();

    // Scale should have increased from 100%
    expect(find.text('140%'), findsWidgets);

    // Tap Fit to Screen button
    await tester.tap(find.byTooltip('Fit to Screen'));
    await tester.pumpAndSettle();

    // Scale should be reset to 100%
    expect(find.text('100%'), findsOneWidget);

    // Tap close button
    final closeButtonFinder = find.byIcon(Icons.close_rounded);
    expect(closeButtonFinder, findsOneWidget);
    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.text("Opponent's Photo"), findsNothing);
  });
}
