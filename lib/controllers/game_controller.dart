import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/supabase_constants.dart';
import '../data/models/player_model.dart';
import '../data/models/room_model.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/room_repository.dart';
import '../data/repositories/storage_repository.dart';
import 'auth_controller.dart';

/// Complete Game State for the active room
class GameState {
  final RoomModel? room;
  final List<PlayerModel> players;
  final String currentUserId;
  final bool isLoading;
  final bool isUploadingPhoto;
  final String? errorMessage;

  const GameState({
    this.room,
    this.players = const [],
    required this.currentUserId,
    this.isLoading = true,
    this.isUploadingPhoto = false,
    this.errorMessage,
  });

  /// The current logged-in player in this room
  PlayerModel? get currentPlayer =>
      players.where((p) => p.userId == currentUserId).firstOrNull;

  /// The other/opponent player in this room
  PlayerModel? get opponentPlayer =>
      players.where((p) => p.userId != currentUserId).firstOrNull;

  /// Is current user the host of the room
  bool get isHost {
    if (room == null) return false;
    return room!.hostId == currentUserId || (currentPlayer?.isHost ?? false);
  }

  /// Has Player 2 joined yet?
  bool get hasBothPlayers => players.length >= 2;

  /// Have I (current user) uploaded a photo for my opponent?
  /// (Since I upload for opponent, opponent will have a photoUrl)
  bool get haveIUploadedPhotoForOpponent =>
      opponentPlayer != null && opponentPlayer!.hasPhoto;

  /// Has opponent uploaded a photo for me?
  /// (Opponent upload sets my photoUrl)
  bool get hasOpponentUploadedPhotoForMe =>
      currentPlayer != null && currentPlayer!.hasPhoto;

  /// Are both photos uploaded and ready?
  bool get areBothPhotosReady =>
      players.length == 2 && players.every((p) => p.hasPhoto);

  /// Is game currently actively in guessing phase
  bool get isPlaying =>
      room != null &&
      (room!.status == SupabaseConstants.statusPlaying ||
          (room!.status != SupabaseConstants.statusEnded && areBothPhotosReady));

  /// Has game ended
  bool get isEnded =>
      room != null && room!.status == SupabaseConstants.statusEnded;

  /// Are photos currently revealed to both players?
  bool get isRevealed => room?.revealed ?? false;

  GameState copyWith({
    RoomModel? room,
    List<PlayerModel>? players,
    String? currentUserId,
    bool? isLoading,
    bool? isUploadingPhoto,
    String? errorMessage,
  }) {
    return GameState(
      room: room ?? this.room,
      players: players ?? this.players,
      currentUserId: currentUserId ?? this.currentUserId,
      isLoading: isLoading ?? this.isLoading,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      errorMessage: errorMessage,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final String roomId;
  final RoomRepository _roomRepo;
  final PlayerRepository _playerRepo;
  final StorageRepository _storageRepo;
  StreamSubscription<RoomModel>? _roomSubscription;
  StreamSubscription<List<PlayerModel>>? _playersSubscription;

  GameNotifier({
    required this.roomId,
    required RoomRepository roomRepo,
    required PlayerRepository playerRepo,
    required StorageRepository storageRepo,
    required String currentUserId,
  })  : _roomRepo = roomRepo,
        _playerRepo = playerRepo,
        _storageRepo = storageRepo,
        super(GameState(
          currentUserId: currentUserId,
        )) {
    _initGame();
  }

  Future<void> _initGame() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Initial fetch
      final room = await _roomRepo.getRoomById(roomId);
      final players = await _playerRepo.getPlayers(roomId);

      state = state.copyWith(
        room: room,
        players: players,
        isLoading: false,
      );

      // 2. Real-time Room Stream
      _roomSubscription = _roomRepo.streamRoom(roomId).listen(
        (updatedRoom) {
          state = state.copyWith(room: updatedRoom);
        },
        onError: (err) {
          debugPrint('Room stream error: $err');
        },
      );

      // 3. Real-time Players Stream
      _playersSubscription = _playerRepo.streamPlayers(roomId).listen(
        (updatedPlayers) {
          state = state.copyWith(players: updatedPlayers);

          // If host and both photos ready, automatically mark room as playing
          if (state.isHost &&
              state.areBothPhotosReady &&
              state.room?.status == SupabaseConstants.statusWaiting) {
            _roomRepo.updateRoomStatus(roomId, SupabaseConstants.statusPlaying);
          }
        },
        onError: (err) {
          debugPrint('Players stream error: $err');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load game: $e',
      );
    }
  }

  /// Upload a photo selected for the opponent to guess
  Future<bool> uploadPhotoForOpponent(XFile imageFile) async {
    final opponent = state.opponentPlayer;
    if (opponent == null) {
      state = state.copyWith(errorMessage: 'Waiting for opponent to join first.');
      return false;
    }

    state = state.copyWith(isUploadingPhoto: true, errorMessage: null);

    try {
      // 1. Upload photo to storage
      final photoUrl = await _storageRepo.uploadPhoto(
        roomId: roomId,
        file: imageFile,
      );

      // 2. Assign to opponent
      await _playerRepo.assignPhotoToPlayer(
        targetPlayerId: opponent.id,
        photoUrl: photoUrl,
      );

      state = state.copyWith(isUploadingPhoto: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploadingPhoto: false,
        errorMessage: 'Failed to upload photo: $e',
      );
      return false;
    }
  }

  /// Host Ends the Room
  Future<void> endRoom() async {
    if (!state.isHost) return;
    try {
      await _roomRepo.updateRoomStatus(roomId, SupabaseConstants.statusEnded);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to end room: $e');
    }
  }

  /// Host reveals both photos (end of round reveal)
  Future<void> revealPhotos() async {
    if (!state.isHost) return;
    try {
      await _roomRepo.updateRoomRevealed(roomId, true);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to reveal photos: $e');
    }
  }

  /// Host hides photos again (start new round of guessing)
  Future<void> hidePhotos() async {
    if (!state.isHost) return;
    try {
      await _roomRepo.updateRoomRevealed(roomId, false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to hide photos: $e');
    }
  }

  /// Host resets photos for both players to start a new round
  Future<void> resetPhotosForNextRound() async {
    if (!state.isHost) return;
    try {
      // 1. Hide photos
      await _roomRepo.updateRoomRevealed(roomId, false);
      // 2. Set room status back to waiting for photos
      await _roomRepo.updateRoomStatus(roomId, SupabaseConstants.statusWaiting);
      // 3. Clear photo_url for all players in the room
      await _playerRepo.resetRoomPhotos(roomId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to reset photos: $e');
    }
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _playersSubscription?.cancel();
    super.dispose();
  }
}

final gameControllerProvider =
    StateNotifierProvider.family<GameNotifier, GameState, String>(
        (ref, roomId) {
  final roomRepo = ref.watch(roomRepositoryProvider);
  final playerRepo = ref.watch(playerRepositoryProvider);
  final storageRepo = ref.watch(storageRepositoryProvider);
  final currentUserId = ref.watch(authControllerProvider).userId;

  return GameNotifier(
    roomId: roomId,
    roomRepo: roomRepo,
    playerRepo: playerRepo,
    storageRepo: storageRepo,
    currentUserId: currentUserId,
  );
});
