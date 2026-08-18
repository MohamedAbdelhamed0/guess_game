import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/supabase_constants.dart';
import '../data/data_sources/player_remote_data_source.dart';
import '../data/data_sources/room_remote_data_source.dart';
import '../data/data_sources/storage_remote_data_source.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/room_repository.dart';
import '../data/repositories/storage_repository.dart';

// ============================================================================
// Core Dependency Providers
// ============================================================================

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    debugPrint('Supabase client not yet initialized: $e');
    return null;
  }
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RoomRepository(
    roomDataSource: RoomRemoteDataSource(client),
    playerDataSource: PlayerRemoteDataSource(client),
  );
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PlayerRepository(
    playerDataSource: PlayerRemoteDataSource(client),
  );
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StorageRepository(
    storageDataSource: StorageRemoteDataSource(client),
  );
});

// ============================================================================
// Auth State & Controller
// ============================================================================

class AuthState {
  final String userId;
  final String displayName;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.userId,
    required this.displayName,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    String? userId,
    String? displayName,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient? _client;

  AuthNotifier(this._client)
      : super(AuthState(
          userId: const Uuid().v4(),
          displayName: '',
        )) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      if (_client != null && SupabaseConstants.isConfigured) {
        final currentSession = _client.auth.currentSession;
        if (currentSession != null) {
          state = state.copyWith(
            userId: currentSession.user.id,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }

        // Try anonymous sign-in
        final authResponse = await _client.auth.signInAnonymously();
        if (authResponse.user != null) {
          state = state.copyWith(
            userId: authResponse.user!.id,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Auth initialization note: $e');
    }

    // Fallback: Use persistent local UUID
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
    );
  }

  void setDisplayName(String name) {
    state = state.copyWith(displayName: name.trim());
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthNotifier(client);
});
