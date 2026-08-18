import 'package:image_picker/image_picker.dart';
import '../../core/utils/image_utils.dart';
import '../data_sources/storage_remote_data_source.dart';

/// Repository for uploading game photos and managing URLs.
class StorageRepository {
  final StorageRemoteDataSource _storageDataSource;

  StorageRepository({StorageRemoteDataSource? storageDataSource})
      : _storageDataSource = storageDataSource ?? StorageRemoteDataSource();

  /// Upload an XFile (works on web, android, and ios) and returns the public URL
  Future<String> uploadPhoto({
    required String roomId,
    required XFile file,
  }) async {
    final bytes = await ImageUtils.getImageBytes(file);
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Failed to read image data.');
    }

    final ext = file.name.split('.').lastOrNull ?? 'png';
    final path = ImageUtils.generatePhotoPath(roomId, ext);

    final contentType = switch (ext.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/png',
    };

    return _storageDataSource.uploadPhotoBytes(
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Delete photo by path
  Future<void> deletePhoto(String path) =>
      _storageDataSource.deletePhoto(path);
}
