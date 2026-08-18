import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';

/// Remote data source handling photo uploads and URLs in Supabase Storage.
class StorageRemoteDataSource {
  final SupabaseClient? _client;

  StorageRemoteDataSource([this._client]);

  SupabaseClient get _safeClient {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception('Supabase client is not initialized. Please configure credentials.');
    }
  }

  /// Upload photo bytes to Supabase Storage and return the public URL.
  Future<String> uploadPhotoBytes({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/png',
  }) async {
    try {
      final storage = _safeClient.storage.from(SupabaseConstants.photoBucket);

      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

      final publicUrl = storage.getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading photo bytes to Supabase Storage: $e');
      rethrow;
    }
  }

  /// Delete a photo from storage
  Future<void> deletePhoto(String path) async {
    try {
      final storage = _safeClient.storage.from(SupabaseConstants.photoBucket);
      await storage.remove([path]);
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}
