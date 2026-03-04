import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../providers/voice_provider.dart';

class VoiceControlsBar extends ConsumerWidget {
  const VoiceControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceRoomProvider);

    if (!voiceState.isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AuraTheme.onlineColor.withValues(alpha: 0.15),
            AuraTheme.backgroundTertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(
            color: AuraTheme.onlineColor.withValues(alpha: 0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AuraTheme.onlineColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Voice Connected',
                style: TextStyle(
                  color: AuraTheme.onlineColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${voiceState.connectedChannelName ?? 'Voice'} · ${voiceState.connectedServerName ?? 'AuraChat'}',
            style: const TextStyle(color: AuraTheme.textMuted, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _VoiceActionButton(
                icon: voiceState.isMuted
                    ? Icons.mic_off_rounded
                    : Icons.mic_rounded,
                label: voiceState.isMuted ? 'Unmute' : 'Mute',
                isActive: !voiceState.isMuted,
                isWarning: voiceState.isMuted,
                onTap: () => ref.read(voiceRoomProvider.notifier).toggleMute(),
              ),
              const SizedBox(width: 6),
              _VoiceActionButton(
                icon: voiceState.isDeafened
                    ? Icons.headset_off_rounded
                    : Icons.headset_rounded,
                label: voiceState.isDeafened ? 'Undeafen' : 'Deafen',
                isActive: !voiceState.isDeafened,
                isWarning: voiceState.isDeafened,
                onTap: () =>
                    ref.read(voiceRoomProvider.notifier).toggleDeafen(),
              ),
              const Spacer(),
              _VoiceActionButton(
                icon: Icons.call_end_rounded,
                label: 'Disconnect',
                isActive: false,
                isDanger: true,
                onTap: () => ref.read(voiceRoomProvider.notifier).leaveRoom(),
              ),
            ],
          ),
          if (voiceState.participants.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${voiceState.participants.length + 1} in channel',
              style: const TextStyle(color: AuraTheme.textMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isWarning;
  final bool isDanger;
  final VoidCallback onTap;

  const _VoiceActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isWarning = false,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  State<_VoiceActionButton> createState() => _VoiceActionButtonState();
}

class _VoiceActionButtonState extends State<_VoiceActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;

    if (widget.isDanger) {
      bgColor = _isHovered
          ? AuraTheme.dangerColor.withValues(alpha: 0.9)
          : AuraTheme.dangerColor.withValues(alpha: 0.15);
      iconColor = AuraTheme.dangerColor;
    } else if (widget.isWarning) {
      bgColor = _isHovered
          ? AuraTheme.dangerColor.withValues(alpha: 0.2)
          : AuraTheme.dangerColor.withValues(alpha: 0.1);
      iconColor = AuraTheme.dangerColor;
    } else {
      bgColor = _isHovered
          ? AuraTheme.backgroundModifierActive
          : AuraTheme.backgroundModifierHover.withValues(alpha: 0.4);
      iconColor = AuraTheme.textNormal;
    }

    return Tooltip(
      message: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _isHovered && widget.isDanger ? Colors.white : iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
