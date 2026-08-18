import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Styled input field specifically designed for entering 6-character room keys
class RoomCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const RoomCodeInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      maxLength: 6,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        UpperCaseTextFormatter(),
      ],
      style: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 8,
        color: AppTheme.secondaryNeon,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '• • • • • •',
        hintStyle: TextStyle(
          color: Colors.white.withAlpha(50),
          letterSpacing: 6,
          fontSize: 24,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Icon(Icons.vpn_key_rounded, color: AppTheme.secondaryNeon),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () {
                  controller.clear();
                  if (onChanged != null) onChanged!('');
                },
              )
            : null,
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
    );
  }
}

/// Helper formatter to ensure all entered characters are uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Copyable Room Code Badge widget for in-game display and sharing
class RoomCodeBadge extends StatelessWidget {
  final String roomCode;

  const RoomCodeBadge({
    super.key,
    required this.roomCode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: roomCode));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accentGreen),
                const SizedBox(width: 10),
                Text('Room Code "$roomCode" copied to clipboard!'),
              ],
            ),
            backgroundColor: AppTheme.surfaceDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight.withAlpha(200),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.secondaryNeon.withAlpha(120),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.vpn_key_rounded,
              size: 16,
              color: AppTheme.secondaryNeon,
            ),
            const SizedBox(width: 8),
            Text(
              'ROOM: ',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            Text(
              roomCode,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppTheme.secondaryNeon,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.copy_rounded,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
