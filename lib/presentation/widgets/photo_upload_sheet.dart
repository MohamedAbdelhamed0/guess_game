import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/image_utils.dart';

/// Modal bottom sheet or dialog allowing user to pick and preview photo before uploading.
class PhotoUploadSheet extends StatefulWidget {
  final String opponentName;
  final Future<bool> Function(XFile file) onConfirmUpload;

  const PhotoUploadSheet({
    super.key,
    required this.opponentName,
    required this.onConfirmUpload,
  });

  static Future<void> show(
    BuildContext context, {
    required String opponentName,
    required Future<bool> Function(XFile file) onConfirmUpload,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoUploadSheet(
        opponentName: opponentName,
        onConfirmUpload: onConfirmUpload,
      ),
    );
  }

  @override
  State<PhotoUploadSheet> createState() => _PhotoUploadSheetState();
}

class _PhotoUploadSheetState extends State<PhotoUploadSheet> {
  XFile? _selectedFile;
  Uint8List? _previewBytes;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickFromGallery() async {
    final file = await ImageUtils.pickImageFromGallery();
    if (file != null) {
      final bytes = await ImageUtils.getImageBytes(file);
      setState(() {
        _selectedFile = file;
        _previewBytes = bytes;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final file = await ImageUtils.pickImageFromCamera();
    if (file != null) {
      final bytes = await ImageUtils.getImageBytes(file);
      setState(() {
        _selectedFile = file;
        _previewBytes = bytes;
        _errorMessage = null;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    final success = await widget.onConfirmUpload(_selectedFile!);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isUploading = false;
          _errorMessage = 'Upload failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        maxWidth: 600,
      ),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              'Pick a Secret Photo',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select what ${widget.opponentName} will have to guess!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // Error alert if any
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.accentRose.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentRose.withAlpha(120)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            // Image Preview or Selection Area
            if (_previewBytes != null)
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.secondaryNeon, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        _previewBytes!,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black87,
                          child: IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _isUploading ? null : _pickFromGallery,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: _pickFromGallery,
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (!kIsWeb)
                    Expanded(
                      child: _buildOptionButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: _pickFromCamera,
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_previewBytes != null)
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _upload,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_isUploading ? 'Uploading...' : 'Confirm Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTheme.secondaryNeon),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
