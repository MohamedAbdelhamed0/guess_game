import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/player_model.dart';
import '../data/repositories/player_repository.dart';
import 'auth_controller.dart';
import 'game_controller.dart';

class ScoreController {
  final PlayerRepository _playerRepo;
  final Ref _ref;

  ScoreController(this._playerRepo, this._ref);

  /// Increment score by 1 (Host only)
  Future<void> incrementScore(String roomId, PlayerModel player) async {
    final gameState = _ref.read(gameControllerProvider(roomId));
    if (!gameState.isHost) return;

    final newScore = player.score + 1;
    await _playerRepo.updateScore(
      playerId: player.id,
      newScore: newScore,
    );
  }

  /// Decrement score by 1, minimum 0 (Host only)
  Future<void> decrementScore(String roomId, PlayerModel player) async {
    final gameState = _ref.read(gameControllerProvider(roomId));
    if (!gameState.isHost) return;

    final newScore = (player.score - 1).clamp(0, 999);
    await _playerRepo.updateScore(
      playerId: player.id,
      newScore: newScore,
    );
  }

  /// Reset score to 0 (Host only)
  Future<void> resetScore(String roomId, PlayerModel player) async {
    final gameState = _ref.read(gameControllerProvider(roomId));
    if (!gameState.isHost) return;

    await _playerRepo.updateScore(
      playerId: player.id,
      newScore: 0,
    );
  }
}

final scoreControllerProvider = Provider<ScoreController>((ref) {
  final playerRepo = ref.watch(playerRepositoryProvider);
  return ScoreController(playerRepo, ref);
});
