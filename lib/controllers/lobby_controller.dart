import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/room_repository.dart';
import 'auth_controller.dart';

class LobbyState {
  final bool isLoading;
  final String? errorMessage;
  final String? createdRoomCode;
  final String? activeRoomId;

  const LobbyState({
    this.isLoading = false,
    this.errorMessage,
    this.createdRoomCode,
    this.activeRoomId,
  });

  LobbyState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? createdRoomCode,
    String? activeRoomId,
  }) {
    return LobbyState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      createdRoomCode: createdRoomCode ?? this.createdRoomCode,
      activeRoomId: activeRoomId ?? this.activeRoomId,
    );
  }
}

class LobbyNotifier extends StateNotifier<LobbyState> {
  final RoomRepository _roomRepo;
  final Ref _ref;

  LobbyNotifier(this._roomRepo, this._ref) : super(const LobbyState());

  /// Create a new game room
  Future<String?> createRoom(String displayName) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your name.');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authState = _ref.read(authControllerProvider);
      _ref.read(authControllerProvider.notifier).setDisplayName(name);

      final result = await _roomRepo.createRoom(
        hostId: authState.userId,
        hostName: name,
      );

      state = state.copyWith(
        isLoading: false,
        createdRoomCode: result.room.roomCode,
        activeRoomId: result.room.id,
      );

      return result.room.id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create room: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return null;
    }
  }

  /// Join an existing game room by code
  Future<String?> joinRoom(String roomCode, String displayName) async {
    final name = displayName.trim();
    final code = roomCode.trim().toUpperCase();

    if (name.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your name.');
      return null;
    }

    if (code.length != 6) {
      state = state.copyWith(errorMessage: 'Please enter a valid 6-character room code.');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authState = _ref.read(authControllerProvider);
      _ref.read(authControllerProvider.notifier).setDisplayName(name);

      final result = await _roomRepo.joinRoom(
        roomCode: code,
        userId: authState.userId,
        displayName: name,
      );

      state = state.copyWith(
        isLoading: false,
        activeRoomId: result.room.id,
      );

      return result.room.id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to join room: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = const LobbyState();
  }
}

final lobbyControllerProvider =
    StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  final roomRepo = ref.watch(roomRepositoryProvider);
  return LobbyNotifier(roomRepo, ref);
});
