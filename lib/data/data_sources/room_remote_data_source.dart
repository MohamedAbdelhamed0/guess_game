import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/room_model.dart';

/// Remote data source handling Room CRUD and Realtime Streams with Supabase.
class RoomRemoteDataSource {
  final SupabaseClient? _client;

  RoomRemoteDataSource([this._client]);

  SupabaseClient get _safeClient {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception('Supabase client is not initialized. Please configure credentials.');
    }
  }

  /// Create a new room in Supabase
  Future<RoomModel> createRoom({
    required String roomCode,
    required String hostId,
  }) async {
    try {
      final response = await _safeClient
          .from(SupabaseConstants.roomsTable)
          .insert({
            'room_code': roomCode.toUpperCase().trim(),
            'host_id': hostId,
            'status': SupabaseConstants.statusWaiting,
          })
          .select()
          .single();

      return RoomModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating room: $e');
      rethrow;
    }
  }

  /// Query a room by its 6-character code
  Future<RoomModel?> getRoomByCode(String roomCode) async {
    try {
      final response = await _safeClient
          .from(SupabaseConstants.roomsTable)
          .select()
          .eq('room_code', roomCode.toUpperCase().trim())
          .maybeSingle();

      if (response == null) return null;
      return RoomModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching room by code: $e');
      rethrow;
    }
  }

  /// Query a room by its UUID
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final response = await _safeClient
          .from(SupabaseConstants.roomsTable)
          .select()
          .eq('id', roomId)
          .maybeSingle();

      if (response == null) return null;
      return RoomModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching room by ID: $e');
      rethrow;
    }
  }

  /// Update room status ('waiting' -> 'playing' -> 'ended')
  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await _safeClient
          .from(SupabaseConstants.roomsTable)
          .update({'status': status})
          .eq('id', roomId);
    } catch (e) {
      debugPrint('Error updating room status: $e');
      rethrow;
    }
  }

  /// Toggle the revealed flag on a room (host reveals both photos)
  Future<void> updateRoomRevealed(String roomId, bool revealed) async {
    try {
      await _safeClient
          .from(SupabaseConstants.roomsTable)
          .update({'revealed': revealed})
          .eq('id', roomId);
    } catch (e) {
      debugPrint('Error updating room revealed: $e');
      rethrow;
    }
  }

  /// Realtime stream for a specific room
  Stream<RoomModel> streamRoom(String roomId) {
    return _safeClient
        .from(SupabaseConstants.roomsTable)
        .stream(primaryKey: ['id'])
        .eq('id', roomId)
        .map((maps) {
          if (maps.isEmpty) {
            throw Exception('Room not found');
          }
          return RoomModel.fromJson(maps.first);
        });
  }
}
