/// Central constants for Supabase configurations, tables, storage buckets, and defaults.
abstract class SupabaseConstants {
  // Configurable Supabase credentials.
  // Defaults can be provided via --dart-define or directly in this file.
  static const String defaultSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vuoywocxaxmqjuoohlvn.supabase.co',
  );

  static const String defaultSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_N0fu3cJGE_EVh9fD5m9nEw_roy5ZiFS',
  );

  // Database Tables
  static const String roomsTable = 'rooms';
  static const String playersTable = 'players';

  // Storage Buckets
  static const String photoBucket = 'game-photos';

  // Realtime Channels
  static const String channelPrefix = 'game-room-';

  // Room Status values
  static const String statusWaiting = 'waiting';
  static const String statusPlaying = 'playing';
  static const String statusEnded = 'ended';

  // Max players in a room
  static const int maxPlayersPerRoom = 2;

  // Code generation characters (excluding ambiguous chars: O, 0, I, 1, L)
  static const String roomCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int roomCodeLength = 6;

  /// Helper to check if credentials have been customized
  static bool get isConfigured {
    return !defaultSupabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID') &&
        !defaultSupabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY');
  }
}
