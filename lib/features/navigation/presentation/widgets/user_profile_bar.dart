import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/voice_provider.dart';

class UserProfileBar extends ConsumerWidget {
  const UserProfileBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final voiceState = ref.watch(voiceRoomProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      decoration: BoxDecoration(
        color: AuraTheme.backgroundTertiary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AuraTheme.brandColor,
                  radius: 17,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                          (user?.displayName?.isNotEmpty == true)
                              ? user!.displayName![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AuraTheme.onlineColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AuraTheme.backgroundTertiary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // User info
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'New User',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    voiceState.isConnected ? '🔊 Voice Connected' : 'Online',
                    style: TextStyle(
                      color: voiceState.isConnected
                          ? AuraTheme.onlineColor
                          : AuraTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mic button
          _IconActionButton(
            icon: voiceState.isMuted
                ? Icons.mic_off_rounded
                : Icons.mic_rounded,
            color: voiceState.isMuted
                ? AuraTheme.dangerColor
                : AuraTheme.textMuted,
            tooltip: voiceState.isMuted ? 'Unmute' : 'Mute',
            onTap: voiceState.isConnected
                ? () => ref.read(voiceRoomProvider.notifier).toggleMute()
                : null,
          ),

          // Deafen button
          _IconActionButton(
            icon: voiceState.isDeafened
                ? Icons.headset_off_rounded
                : Icons.headset_rounded,
            color: voiceState.isDeafened
                ? AuraTheme.dangerColor
                : AuraTheme.textMuted,
            tooltip: voiceState.isDeafened ? 'Undeafen' : 'Deafen',
            onTap: voiceState.isConnected
                ? () => ref.read(voiceRoomProvider.notifier).toggleDeafen()
                : null,
          ),

          // Settings button
          _IconActionButton(
            icon: Icons.settings_rounded,
            color: AuraTheme.textMuted,
            tooltip: 'User Settings',
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isHovered && widget.onTap != null
                  ? AuraTheme.backgroundModifierActive
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.onTap == null
                  ? AuraTheme.textMuted.withValues(alpha: 0.4)
                  : (_isHovered ? Colors.white : widget.color),
            ),
          ),
        ),
      ),
    );
  }
}
