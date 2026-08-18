import 'dart:math';
import '../../core/constants/supabase_constants.dart';
import '../data_sources/player_remote_data_source.dart';
import '../data_sources/room_remote_data_source.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';

/// Repository for room lifecycle, code generation, and join validation.
class RoomRepository {
  final RoomRemoteDataSource _roomDataSource;
  final PlayerRemoteDataSource _playerDataSource;

  RoomRepository({
    RoomRemoteDataSource? roomDataSource,
    PlayerRemoteDataSource? playerDataSource,
  })  : _roomDataSource = roomDataSource ?? RoomRemoteDataSource(),
        _playerDataSource = playerDataSource ?? PlayerRemoteDataSource();

  /// Generate a random 6-character room code
  String generateRoomCode() {
    final random = Random.secure();
    final alphabet = SupabaseConstants.roomCodeAlphabet;
    final code = StringBuffer();
    for (int i = 0; i < SupabaseConstants.roomCodeLength; i++) {
      code.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return code.toString();
  }

  /// Create a new room and register the creator as the host player
  Future<({RoomModel room, PlayerModel hostPlayer})> createRoom({
    required String hostId,
    required String hostName,
  }) async {
    final code = generateRoomCode();
    final room = await _roomDataSource.createRoom(
      roomCode: code,
      hostId: hostId,
    );

    final player = await _playerDataSource.addPlayer(
      roomId: room.id,
      userId: hostId,
      displayName: hostName.isEmpty ? 'Host' : hostName,
      isHost: true,
    );

    return (room: room, hostPlayer: player);
  }

  /// Join an existing room by its 6-character code
  Future<({RoomModel room, PlayerModel player})> joinRoom({
    required String roomCode,
    required String userId,
    required String displayName,
  }) async {
    final cleanCode = roomCode.toUpperCase().trim();
    final room = await _roomDataSource.getRoomByCode(cleanCode);

    if (room == null) {
      throw Exception('Room code "$cleanCode" not found.');
    }

    if (room.status == SupabaseConstants.statusEnded) {
      throw Exception('This game room has already ended.');
    }

    // Check existing players
    final currentPlayers = await _playerDataSource.getPlayersInRoom(room.id);

    // If user is already in room, rejoin
    final existing = currentPlayers.where((p) => p.userId == userId).firstOrNull;
    if (existing != null) {
      return (room: room, player: existing);
    }

    // Otherwise check capacity (max 2 players)
    if (currentPlayers.length >= SupabaseConstants.maxPlayersPerRoom) {
      throw Exception('This room is full (2/2 players already joined).');
    }

    final isHost = room.hostId == userId;
    final player = await _playerDataSource.addPlayer(
      roomId: room.id,
      userId: userId,
      displayName: displayName.isEmpty ? 'Player' : displayName,
      isHost: isHost,
    );

    return (room: room, player: player);
  }

  /// Fetch a room by ID
  Future<RoomModel?> getRoomById(String roomId) =>
      _roomDataSource.getRoomById(roomId);

  /// Update room status
  Future<void> updateRoomStatus(String roomId, String status) =>
      _roomDataSource.updateRoomStatus(roomId, status);

  /// Toggle reveal for both photos (host only)
  Future<void> updateRoomRevealed(String roomId, bool revealed) =>
      _roomDataSource.updateRoomRevealed(roomId, revealed);

  /// Stream room state changes in realtime
  Stream<RoomModel> streamRoom(String roomId) =>
      _roomDataSource.streamRoom(roomId);
}
