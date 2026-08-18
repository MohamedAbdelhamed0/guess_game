import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/lobby_screen.dart';

import 'package:google_fonts/google_fonts.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/game/:roomId',
      onExit: (context, state) async {
        if (GameScreen.allowExit) {
          return true;
        }

        final shouldLeave = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: AppTheme.accentRose, width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRose, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Leave the Game?',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to leave this game room? You will disconnect from the active match.',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Stay in Game',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRose,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Leave Game'),
              ),
            ],
          ),
        );

        if (shouldLeave == true) {
          GameScreen.allowExit = true;
          return true;
        }
        return false;
      },
      builder: (context, state) {
        final roomId = state.pathParameters['roomId'] ?? '';
        return GameScreen(roomId: roomId);
      },
    ),
  ],
);

/// Root Application Widget with Material 3 and GoRouter
class GuessGameApp extends StatelessWidget {
  const GuessGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ultimate Guess Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
