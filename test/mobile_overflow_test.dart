import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_game/data/models/player_model.dart';
import 'package:guess_game/presentation/widgets/player_card.dart';
import 'package:guess_game/presentation/widgets/room_code_input.dart';
import 'package:guess_game/presentation/widgets/score_board.dart';

void main() {
  testWidgets('RoomCodeBadge, ScoreBoard, and PlayerCard render cleanly on small mobile viewport without overflow',
      (WidgetTester tester) async {
    // Set a narrow mobile screen size (320x568 - iPhone SE size)
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final player1 = PlayerModel(
      id: 'p1',
      roomId: 'room1',
      userId: 'user1',
      displayName: 'VeryLongPlayerName1',
      photoUrl: 'https://example.com/photo.jpg',
      score: 15,
      isHost: true,
      joinedAt: DateTime.now(),
    );

    final player2 = PlayerModel(
      id: 'p2',
      roomId: 'room1',
      userId: 'user2',
      displayName: 'VeryLongPlayerName2',
      score: 12,
      isHost: false,
      joinedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const RoomCodeBadge(roomCode: 'ABC123'),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ScoreBoard(
                    roomId: 'room1',
                    players: [player1, player2],
                    currentUserId: 'user1',
                    isHost: true,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 280,
                    child: PlayerCard(
                      player: player1,
                      isCurrentUser: true,
                      isRevealed: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 280,
                    child: PlayerCard(
                      player: player2,
                      isCurrentUser: false,
                      isRevealed: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all key texts rendered without any layout assertions/overflow errors
    expect(find.text('ABC123'), findsOneWidget);
    expect(find.text('GAME SCORE'), findsOneWidget);
    expect(find.text('15'), findsWidgets);
    expect(find.text('12'), findsWidgets);
    expect(find.text('MYSTERY PHOTO'), findsOneWidget);
    expect(find.text('Pick a Photo for VeryLongPlayerName2'), findsOneWidget);
  });
}
