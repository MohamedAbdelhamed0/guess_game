import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/player_model.dart';

/// Confirmation dialog for the host to conclude the game session
class EndGameDialog extends StatelessWidget {
  final VoidCallback onConfirmEnd;

  const EndGameDialog({
    super.key,
    required this.onConfirmEnd,
  });

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onConfirmEnd,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EndGameDialog(onConfirmEnd: onConfirmEnd),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.accentRose, width: 1.5),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRose, size: 28),
          const SizedBox(width: 10),
          Text(
            'End Game?',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to end this game room? Final scores will be locked.',
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirmEnd();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentRose,
            foregroundColor: Colors.white,
          ),
          child: const Text('End Game'),
        ),
      ],
    );
  }
}

/// Final Game Results Dialog shown when the room status becomes ended
class GameOverDialog extends StatelessWidget {
  final List<PlayerModel> players;
  final VoidCallback onBackToLobby;

  const GameOverDialog({
    super.key,
    required this.players,
    required this.onBackToLobby,
  });

  static Future<void> show(
    BuildContext context, {
    required List<PlayerModel> players,
    required VoidCallback onBackToLobby,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        players: players,
        onBackToLobby: onBackToLobby,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine winner
    String winnerText = 'It was a Tie!';
    if (players.length >= 2) {
      if (players[0].score > players[1].score) {
        winnerText = '🏆 ${players[0].displayName} Wins!';
      } else if (players[1].score > players[0].score) {
        winnerText = '🏆 ${players[1].displayName} Wins!';
      }
    }

    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.accentAmber, width: 1.5),
      ),
      title: Column(
        children: [
          const Icon(
            Icons.military_tech_rounded,
            color: AppTheme.accentAmber,
            size: 54,
          ),
          const SizedBox(height: 8),
          Text(
            'GAME FINISHED',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.accentAmber,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            winnerText,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          ...players.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.displayName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${p.score} PTS',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onBackToLobby();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryNeon,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Back to Lobby'),
        ),
      ],
    );
  }
}
