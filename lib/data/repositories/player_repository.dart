import '../data_sources/player_remote_data_source.dart';
import '../models/player_model.dart';

/// Repository for player updates, photo assignment, and scoring operations.
class PlayerRepository {
  final PlayerRemoteDataSource _playerDataSource;

  PlayerRepository({PlayerRemoteDataSource? playerDataSource})
      : _playerDataSource = playerDataSource ?? PlayerRemoteDataSource();

  /// Stream of players in a given room
  Stream<List<PlayerModel>> streamPlayers(String roomId) =>
      _playerDataSource.streamPlayers(roomId);

  /// Fetch player list in a given room
  Future<List<PlayerModel>> getPlayers(String roomId) =>
      _playerDataSource.getPlayersInRoom(roomId);

  /// Assign photo to a player (the photo that this player must guess)
  Future<void> assignPhotoToPlayer({
    required String targetPlayerId,
    required String photoUrl,
  }) {
    return _playerDataSource.updatePlayerPhoto(
      playerId: targetPlayerId,
      photoUrl: photoUrl,
    );
  }

  /// Reset photos for all players in a room (start next round)
  Future<void> resetRoomPhotos(String roomId) =>
      _playerDataSource.resetPlayersPhotos(roomId);

  /// Update a player's score
  Future<void> updateScore({
    required String playerId,
    required int newScore,
  }) {
    return _playerDataSource.updatePlayerScore(
      playerId: playerId,
      score: newScore,
    );
  }

  /// Remove player from room
  Future<void> removePlayer(String playerId) =>
      _playerDataSource.removePlayer(playerId);
}
