import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/constants/supabase_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend
  if (SupabaseConstants.isConfigured) {
    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(
        url: SupabaseConstants.defaultSupabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConstants.defaultSupabaseAnonKey,
      );
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  } else {
    debugPrint(
      'Notice: Supabase credentials are using defaults. Please update lib/core/constants/supabase_constants.dart with your project URL and Anon Key.',
    );
  }

  runApp(
    const ProviderScope(
      child: GuessGameApp(),
    ),
  );
}
