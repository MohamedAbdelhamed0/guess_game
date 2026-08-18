import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Full-screen interactive image viewer with pinch-to-zoom, double-tap-to-zoom,
/// smooth pan gestures, and quick zoom control buttons.
class FullScreenImageViewer extends StatefulWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? title;
  final String? subtitle;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.title,
    this.subtitle,
    this.heroTag,
  }) : assert(imageUrl != null || imageBytes != null, 'Must provide either imageUrl or imageBytes');

  /// Convenience method to display the full-screen photo viewer dialog with smooth transitions.
  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    Uint8List? imageBytes,
    String? title,
    String? subtitle,
    String? heroTag,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Image Viewer',
      barrierColor: Colors.black.withAlpha(230),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FullScreenImageViewer(
          imageUrl: imageUrl,
          imageBytes: imageBytes,
          title: title,
          subtitle: subtitle,
          heroTag: heroTag,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  Animation<Matrix4>? _animation;

  Offset? _doubleTapPosition;
  double _currentScale = 1.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateTransformation(Matrix4 target) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.reset();
    _animationController.forward();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.2) {
      // Zoom back out to 100%
      _animateTransformation(Matrix4.identity());
    } else {
      // Zoom in to 2.5x centered around tap point
      final position = _doubleTapPosition ?? Offset.zero;
      const targetScale = 2.5;
      final x = position.dx;
      final y = position.dy;

      final target = Matrix4.diagonal3Values(targetScale, targetScale, 1.0)
        ..setTranslationRaw(x * (1 - targetScale), y * (1 - targetScale), 0.0);

      _animateTransformation(target);
    }
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.4).clamp(1.0, 6.0);
    final target = Matrix4.diagonal3Values(newScale, newScale, 1.0);
    _animateTransformation(target);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.4).clamp(1.0, 6.0);
    final target = (newScale <= 1.05)
        ? Matrix4.identity()
        : Matrix4.diagonal3Values(newScale, newScale, 1.0);
    _animateTransformation(target);
  }

  void _resetZoom() {
    _animateTransformation(Matrix4.identity());
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Backdrop with Blur
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_currentScale <= 1.05) {
                  Navigator.of(context).pop();
                } else {
                  _resetZoom();
                }
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  color: AppTheme.backgroundDark.withAlpha(235),
                ),
              ),
            ),
          ),

          // Interactive Zoomable Image Area
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
              onTap: _toggleControls,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.8,
                maxScale: 6.0,
                panEnabled: true,
                scaleEnabled: true,
                boundaryMargin: const EdgeInsets.all(200),
                clipBehavior: Clip.none,
                child: Center(
                  child: widget.heroTag != null
                      ? Hero(
                          tag: widget.heroTag!,
                          child: _buildImageContent(),
                        )
                      : _buildImageContent(),
                ),
              ),
            ),
          ),

          // Top Header Bar (Title + Close + Reset Zoom)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(200),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    // Close Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight.withAlpha(180),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null)
                            Text(
                              widget.title!,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    // Zoom percentage badge or reset button
                    if (_currentScale > 1.05)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _resetZoom,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryNeon.withAlpha(40),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.secondaryNeon,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.restart_alt_rounded,
                                  size: 16,
                                  color: AppTheme.secondaryNeon,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(_currentScale * 100).toInt()}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryNeon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Bottom Toolbar (Zoom In / Out / Reset / Hint)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showControls ? 0 : -120,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(220),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating Glass Control Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withAlpha(220),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.secondaryNeon.withAlpha(100),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryNeon.withAlpha(40),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Zoom Out Button
                          IconButton(
                            icon: const Icon(Icons.remove_rounded),
                            color: Colors.white,
                            iconSize: 22,
                            tooltip: 'Zoom Out',
                            onPressed: _zoomOut,
                          ),

                          // Current Scale Label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(_currentScale * 100).toInt()}%',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Zoom In Button
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            color: Colors.white,
                            iconSize: 22,
                            tooltip: 'Zoom In',
                            onPressed: _zoomIn,
                          ),

                          const SizedBox(width: 4),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white24,
                          ),
                          const SizedBox(width: 4),

                          // Fit Screen / Reset Button
                          IconButton(
                            icon: const Icon(Icons.fit_screen_rounded),
                            color: _currentScale > 1.05 ? AppTheme.secondaryNeon : Colors.white70,
                            iconSize: 20,
                            tooltip: 'Fit to Screen',
                            onPressed: _resetZoom,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Gesture Tip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 14,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pinch or double-tap to zoom • Drag to pan',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (widget.imageBytes != null) {
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      fit: BoxFit.contain,
      placeholder: (context, url) => Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.secondaryNeon,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentRose.withAlpha(120)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_rounded, size: 56, color: AppTheme.accentRose),
          const SizedBox(height: 12),
          Text(
            'Failed to load image',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The photo could not be fetched or displayed.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
