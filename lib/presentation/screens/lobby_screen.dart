import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/lobby_controller.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/room_code_input.dart';

/// Lobby screen for player name entry, room creation, and joining via room key.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    if (authState.displayName.isNotEmpty) {
      _nameController.text = authState.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoom() async {
    final lobbyNotifier = ref.read(lobbyControllerProvider.notifier);
    final roomId = await lobbyNotifier.createRoom(_nameController.text);
    if (roomId != null && mounted) {
      context.go('/game/$roomId');
    }
  }

  Future<void> _handleJoinRoom() async {
    final lobbyNotifier = ref.read(lobbyControllerProvider.notifier);
    final roomId = await lobbyNotifier.joinRoom(
      _roomCodeController.text,
      _nameController.text,
    );
    if (roomId != null && mounted) {
      context.go('/game/$roomId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF1E1B4B),
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: ResponsiveLayout(
            maxContainerWidth: 650,
            mobile: _buildContent(context, lobbyState),
            desktop: _buildContent(context, lobbyState),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LobbyState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Supabase setup banner alert if not configured
          if (!SupabaseConstants.isConfigured) _buildConfigNotice(),

          const SizedBox(height: 10),

          // Logo & Game Title Banner
          _buildHeroHeader(),

          const SizedBox(height: 24),

          // Error message banner if any
          if (state.errorMessage != null)
            _buildErrorAlert(state.errorMessage!),

          // Player Profile Input Card
          _buildNameCard(),

          const SizedBox(height: 20),

          // Action Section: Create or Join
          _buildGameActionsCard(context, state),

          const SizedBox(height: 24),

          // Rules Summary Card
          _buildRulesCard(),

          const SizedBox(height: 24),

          // Appreciation Footer
          _buildAppreciationFooter(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildConfigNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentAmber.withAlpha(120)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.accentAmber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Supabase backend keys not set yet. Configure your Supabase project credentials in supabase_constants.dart.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        // App Icon / Logo Badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryNeon.withAlpha(80),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_alt_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Game Title
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'ULTIMATE GUESS',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          '2-Player Photo Guessing Arena',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryNeon,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorAlert(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.accentRose.withAlpha(35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentRose.withAlpha(120)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.accentRose),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            onPressed: () => ref.read(lobbyControllerProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_rounded, color: AppTheme.primaryNeon, size: 20),
              const SizedBox(width: 8),
              Text(
                'YOUR PLAYER NAME',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.primaryNeon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Enter your name (e.g. Alex, Sam)...',
              prefixIcon: Icon(Icons.person, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameActionsCard(BuildContext context, LobbyState state) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: CREATE ROOM
          Text(
            'HOST A NEW ROOM',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: state.isLoading ? null : _handleCreateRoom,
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Create New Game Room'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppTheme.primaryNeon,
            ),
          ),

          const SizedBox(height: 24),

          // Divider OR
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.white12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'OR JOIN WITH ROOM KEY',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white38,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white12)),
            ],
          ),

          const SizedBox(height: 20),

          // Section 2: JOIN ROOM WITH 6-CHAR CODE
          RoomCodeInput(
            controller: _roomCodeController,
            enabled: !state.isLoading,
            onSubmitted: _handleJoinRoom,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: state.isLoading ? null : _handleJoinRoom,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Join Game Room'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withAlpha(120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'HOW THE GAME WORKS',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.accentAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRuleStep('1', 'Create or join a 2-player room with the 6-character key.'),
          _buildRuleStep('2', 'Upload a secret photo for your OPPONENT to guess.'),
          _buildRuleStep('3', 'You will see their photo, but YOUR photo stays hidden.'),
          _buildRuleStep('4', 'Take turns asking yes/no questions to guess your photo!'),
          _buildRuleStep('5', 'Host awards points when a player guesses correctly.'),
        ],
      ),
    );
  }

  Widget _buildRuleStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppreciationFooter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'thank u hana for the idea',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white60,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.favorite_rounded,
              size: 14,
              color: AppTheme.accentRose,
            ),
          ],
        ),
      ),
    );
  }
}
