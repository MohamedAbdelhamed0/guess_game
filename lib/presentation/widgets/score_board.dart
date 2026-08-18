import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../controllers/score_controller.dart';
import '../../data/models/player_model.dart';

/// Live score board widget with host score manipulation controls.
class ScoreBoard extends ConsumerWidget {
  final String roomId;
  final List<PlayerModel> players;
  final String currentUserId;
  final bool isHost;

  const ScoreBoard({
    super.key,
    required this.roomId,
    required this.players,
    required this.currentUserId,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (players.isEmpty) return const SizedBox.shrink();

    final scoreController = ref.read(scoreControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30363D), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppTheme.accentAmber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'GAME SCORE',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.accentAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Player 1
              if (players.isNotEmpty)
                _buildPlayerScoreTile(
                  context,
                  player: players[0],
                  isCurrentUser: players[0].userId == currentUserId,
                  scoreController: scoreController,
                ),

              // VS Divider
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'VS',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white54,
                  ),
                ),
              ),

              // Player 2
              if (players.length > 1)
                _buildPlayerScoreTile(
                  context,
                  player: players[1],
                  isCurrentUser: players[1].userId == currentUserId,
                  scoreController: scoreController,
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'Waiting for Player 2...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (isHost) ...[
            const SizedBox(height: 10),
            Text(
              '👑 Host Controls: Tap +1 to award points for correct guesses',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerScoreTile(
    BuildContext context, {
    required PlayerModel player,
    required bool isCurrentUser,
    required ScoreController scoreController,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  isCurrentUser ? '${player.displayName} (You)' : player.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? AppTheme.primaryNeon : AppTheme.secondaryNeon,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isHost)
                _buildIconButton(
                  icon: Icons.remove,
                  onPressed: () => scoreController.decrementScore(roomId, player),
                ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentAmber.withAlpha(100),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${player.score}',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentAmber,
                  ),
                ),
              ),
              if (isHost)
                _buildIconButton(
                  icon: Icons.add,
                  onPressed: () => scoreController.incrementScore(roomId, player),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
