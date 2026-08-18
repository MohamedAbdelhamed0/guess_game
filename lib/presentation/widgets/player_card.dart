import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/player_model.dart';

/// Interactive Player Card displaying either opponent's photo or current user's mystery box.
class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isCurrentUser;
  final bool isRevealed;
  final VoidCallback? onUploadPhoto;
  final bool isUploading;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isCurrentUser,
    this.isRevealed = false,
    this.onUploadPhoto,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = player.hasPhoto;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrentUser
              ? AppTheme.primaryNeon.withAlpha(120)
              : AppTheme.secondaryNeon.withAlpha(120),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser ? AppTheme.primaryNeon : AppTheme.secondaryNeon)
                .withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: Avatar + Name + Tags
          _buildHeader(context),

          // 2. Photo / Mystery Box Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildPhotoSection(context, hasPhoto),
            ),
          ),

          // 3. Footer: Score and Status
          _buildFooter(context, hasPhoto),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(150),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          // Avatar Icon
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentUser
                ? AppTheme.primaryNeon.withAlpha(60)
                : AppTheme.secondaryNeon.withAlpha(60),
            child: Icon(
              isCurrentUser ? Icons.person_rounded : Icons.person_outline_rounded,
              color: isCurrentUser ? AppTheme.primaryNeon : AppTheme.secondaryNeon,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Name and Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNeon.withAlpha(50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryNeon,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isCurrentUser ? 'Your Mystery Card' : "Opponent's Photo",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Host Badge
          if (player.isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentAmber.withAlpha(120),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppTheme.accentAmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'HOST',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, bool hasPhoto) {
    if (isCurrentUser) {
      // CURRENT USER CARD: Mystery Card!
      if (!hasPhoto) {
        return _buildWaitingPlaceholder(
          icon: Icons.hourglass_top_rounded,
          title: 'Waiting for Photo',
          subtitle: 'Opponent is picking a photo for you to guess...',
        );
      }

      // If revealed, show the actual photo!
      if (isRevealed) {
        return _buildRevealedPhoto();
      }

      return Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mysteryGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.accentPurple.withAlpha(150), width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withAlpha(60),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'MYSTERY PHOTO',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ask yes/no questions to guess what photo is on your head!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // OPPONENT CARD: Show the photo that current user picked for them!
      if (!hasPhoto) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.secondaryNeon.withAlpha(80),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 48,
                  color: AppTheme.secondaryNeon,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pick a Photo for ${player.displayName}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose an object, character, or thing for them to guess',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: isUploading ? null : onUploadPhoto,
                  icon: isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_file_rounded),
                  label: Text(isUploading ? 'Uploading...' : 'Choose Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryNeon,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Display the actual photo for opponent
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: player.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.surfaceLight,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondaryNeon,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceLight,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                ),
              ),
            ),
            // Bottom label banner
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.visibility_rounded,
                      size: 14,
                      color: AppTheme.secondaryNeon,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${player.displayName} needs to guess this!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildWaitingPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white38),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the actual photo with a "REVEALED!" banner when host triggers reveal
  Widget _buildRevealedPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: player.photoUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppTheme.surfaceLight,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentGreen,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppTheme.surfaceLight,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
              ),
            ),
          ),
          // REVEALED banner overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen.withAlpha(220),
                    AppTheme.accentGreen.withAlpha(180),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REVEALED! This was your mystery photo!',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool hasPhoto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(120),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                hasPhoto ? Icons.check_circle_rounded : Icons.pending_rounded,
                size: 16,
                color: hasPhoto ? AppTheme.accentGreen : AppTheme.accentAmber,
              ),
              const SizedBox(width: 6),
              Text(
                hasPhoto ? 'Photo Ready' : 'Photo Pending',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasPhoto ? AppTheme.accentGreen : AppTheme.accentAmber,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.military_tech_rounded,
                size: 18,
                color: AppTheme.accentAmber,
              ),
              const SizedBox(width: 4),
              Text(
                'Score: ${player.score}',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
