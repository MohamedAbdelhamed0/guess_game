import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Cross-platform utility for image picking and byte processing.
class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery with optimized resolution for fast upload
  static Future<XFile?> pickImageFromGallery({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from camera
  static Future<XFile?> pickImageFromCamera({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return image;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  /// Get bytes safely on all platforms (web & mobile)
  static Future<Uint8List?> getImageBytes(XFile file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error reading image bytes: $e');
      return null;
    }
  }

  /// Generate a unique storage file path
  static String generatePhotoPath(String roomId, String fileExtension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = fileExtension.replaceAll('.', '');
    return '$roomId/${timestamp}_photo.$ext';
  }
}
