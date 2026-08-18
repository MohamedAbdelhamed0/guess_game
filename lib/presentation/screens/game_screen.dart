import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../controllers/game_controller.dart';
import '../dialogs/end_game_dialog.dart';
import '../widgets/photo_upload_sheet.dart';
import '../widgets/player_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/room_code_input.dart';
import '../widgets/score_board.dart';

/// Active game screen coordinating real-time players, photos, score, and host controls.
class GameScreen extends ConsumerStatefulWidget {
  final String roomId;

  const GameScreen({super.key, required this.roomId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _hasShownGameOverDialog = false;

  void _showPhotoUploadModal(String opponentName) {
    PhotoUploadSheet.show(
      context,
      opponentName: opponentName,
      onConfirmUpload: (file) async {
        final success = await ref
            .read(gameControllerProvider(widget.roomId).notifier)
            .uploadPhotoForOpponent(file);
        return success;
      },
    );
  }

  void _handleEndGame() {
    EndGameDialog.show(
      context,
      onConfirmEnd: () {
        ref.read(gameControllerProvider(widget.roomId).notifier).endRoom();
      },
    );
  }

  void _handleRevealPhotos() {
    final gameState = ref.read(gameControllerProvider(widget.roomId));
    final notifier = ref.read(gameControllerProvider(widget.roomId).notifier);

    if (gameState.isRevealed) {
      notifier.hidePhotos();
    } else {
      notifier.revealPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider(widget.roomId));

    // Listen for Game Over event
    ref.listen<GameState>(
      gameControllerProvider(widget.roomId),
      (prev, next) {
        if (next.isEnded && !_hasShownGameOverDialog && mounted) {
          _hasShownGameOverDialog = true;
          GameOverDialog.show(
            context,
            players: next.players,
            onBackToLobby: () => context.go('/'),
          );
        }
      },
    );

    return Scaffold(
      appBar: _buildAppBar(gameState),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.3,
            colors: [
              Color(0xFF1E1B4B),
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildBody(gameState),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(GameState state) {
    final roomCode = state.room?.roomCode ?? '------';

    return AppBar(
      title: RoomCodeBadge(roomCode: roomCode),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        tooltip: 'Leave to Lobby',
        onPressed: () => context.go('/'),
      ),
      actions: [
        if (state.isHost && state.areBothPhotosReady && !state.isEnded)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: _handleRevealPhotos,
              icon: Icon(
                state.isRevealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppTheme.accentGreen,
                size: 20,
              ),
              label: Text(
                state.isRevealed ? 'Hide' : 'Reveal',
                style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.accentGreen.withAlpha(25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (state.isHost)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: state.isEnded ? null : _handleEndGame,
              icon: const Icon(Icons.stop_circle_outlined, color: AppTheme.accentRose, size: 20),
              label: const Text(
                'End Game',
                style: TextStyle(color: AppTheme.accentRose, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.accentRose.withAlpha(25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(GameState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.secondaryNeon),
            SizedBox(height: 16),
            Text('Connecting to game room...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.room == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.accentRose),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Lobby'),
              ),
            ],
          ),
        ),
      );
    }

    // 1. Waiting for Player 2
    if (!state.hasBothPlayers) {
      return _buildWaitingForPlayerView(state);
    }

    // 2. Both players joined: Show Game Arena
    return ResponsiveLayout(
      mobile: _buildMobileGameLayout(state),
      desktop: _buildDesktopGameLayout(state),
    );
  }

  Widget _buildWaitingForPlayerView(GameState state) {
    final roomCode = state.room?.roomCode ?? '';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryNeon.withAlpha(100), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryNeon.withAlpha(50),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: AppTheme.secondaryNeon,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Waiting for Opponent',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share this room code with your friend to start playing:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // Big Room Code Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryNeon, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    roomCode,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: AppTheme.secondaryNeon,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RoomCodeBadge(roomCode: roomCode),

            const SizedBox(height: 36),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
                ),
                SizedBox(width: 12),
                Text(
                  'Waiting for player to connect...',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileGameLayout(GameState state) {
    final currentPlayer = state.currentPlayer;
    final opponent = state.opponentPlayer;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Scoreboard
          ScoreBoard(
            roomId: widget.roomId,
            players: state.players,
            currentUserId: state.currentUserId,
            isHost: state.isHost,
          ),
          const SizedBox(height: 16),

          // 2. Opponent's Card (The photo YOU see and they have to guess)
          if (opponent != null)
            SizedBox(
              height: 280,
              child: PlayerCard(
                player: opponent,
                isCurrentUser: false,
                isRevealed: state.isRevealed,
                isUploading: state.isUploadingPhoto,
                onUploadPhoto: () => _showPhotoUploadModal(opponent.displayName),
              ),
            ),

          const SizedBox(height: 16),

          // 3. Your Card (Your Mystery Photo - Hidden from you)
          if (currentPlayer != null)
            SizedBox(
              height: 280,
              child: PlayerCard(
                player: currentPlayer,
                isCurrentUser: true,
                isRevealed: state.isRevealed,
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDesktopGameLayout(GameState state) {
    final currentPlayer = state.currentPlayer;
    final opponent = state.opponentPlayer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Scoreboard
          ScoreBoard(
            roomId: widget.roomId,
            players: state.players,
            currentUserId: state.currentUserId,
            isHost: state.isHost,
          ),
          const SizedBox(height: 20),

          // 2. Side-by-Side Dual Player Arena
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Opponent Card
                if (opponent != null)
                  Expanded(
                    child: PlayerCard(
                      player: opponent,
                      isCurrentUser: false,
                      isRevealed: state.isRevealed,
                      isUploading: state.isUploadingPhoto,
                      onUploadPhoto: () => _showPhotoUploadModal(opponent.displayName),
                    ),
                  ),

                const SizedBox(width: 24),

                // Current User Mystery Card
                if (currentPlayer != null)
                  Expanded(
                    child: PlayerCard(
                      player: currentPlayer,
                      isCurrentUser: true,
                      isRevealed: state.isRevealed,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
