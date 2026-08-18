import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/player_model.dart';

/// Remote data source handling Player CRUD and Realtime Streams with Supabase.
class PlayerRemoteDataSource {
  final SupabaseClient? _client;

  PlayerRemoteDataSource([this._client]);

  SupabaseClient get _safeClient {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception('Supabase client is not initialized. Please configure credentials.');
    }
  }

  /// Add/Join a player to a room
  Future<PlayerModel> addPlayer({
    required String roomId,
    required String userId,
    required String displayName,
    required bool isHost,
  }) async {
    try {
      final response = await _safeClient
          .from(SupabaseConstants.playersTable)
          .upsert(
            {
              'room_id': roomId,
              'user_id': userId,
              'display_name': displayName.trim(),
              'is_host': isHost,
              'score': 0,
            },
            onConflict: 'room_id, user_id',
          )
          .select()
          .single();

      return PlayerModel.fromJson(response);
    } catch (e) {
      debugPrint('Error adding player: $e');
      rethrow;
    }
  }

  /// Get list of players currently in a room
  Future<List<PlayerModel>> getPlayersInRoom(String roomId) async {
    try {
      final response = await _safeClient
          .from(SupabaseConstants.playersTable)
          .select()
          .eq('room_id', roomId)
          .order('joined_at', ascending: true);

      return (response as List)
          .map((json) => PlayerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting players in room: $e');
      rethrow;
    }
  }

  /// Get a single player
  Future<PlayerModel?> getPlayer(String roomId, String userId) async {
    try {
      final response = await _safeClient
          .from(SupabaseConstants.playersTable)
          .select()
          .eq('room_id', roomId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return PlayerModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching player: $e');
      rethrow;
    }
  }

  /// Update the photo assigned to a player
  Future<void> updatePlayerPhoto({
    required String playerId,
    required String photoUrl,
  }) async {
    try {
      await _safeClient
          .from(SupabaseConstants.playersTable)
          .update({'photo_url': photoUrl})
          .eq('id', playerId);
    } catch (e) {
      debugPrint('Error updating player photo: $e');
      rethrow;
    }
  }

  /// Update a player's score
  Future<void> updatePlayerScore({
    required String playerId,
    required int score,
  }) async {
    try {
      await _safeClient
          .from(SupabaseConstants.playersTable)
          .update({'score': score})
          .eq('id', playerId);
    } catch (e) {
      debugPrint('Error updating player score: $e');
      rethrow;
    }
  }

  /// Remove player from room
  Future<void> removePlayer(String playerId) async {
    try {
      await _safeClient
          .from(SupabaseConstants.playersTable)
          .delete()
          .eq('id', playerId);
    } catch (e) {
      debugPrint('Error removing player: $e');
      rethrow;
    }
  }

  /// Realtime stream of players in a room
  Stream<List<PlayerModel>> streamPlayers(String roomId) {
    return _safeClient
        .from(SupabaseConstants.playersTable)
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('joined_at', ascending: true)
        .map((maps) {
          return maps
              .map((json) => PlayerModel.fromJson(json))
              .toList();
        });
  }
}
