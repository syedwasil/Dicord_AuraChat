import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../../models/channel_model.dart';
import 'user_profile_bar.dart';
import '../../../chat/presentation/widgets/voice_controls_bar.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/widgets/user_search_delegate.dart';
import '../../../chat/presentation/providers/voice_provider.dart';
import 'create_channel_dialog.dart';

class ChannelList extends ConsumerWidget {
  const ChannelList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);
    final channelsAsync = ref.watch(channelsProvider);
    final selectedChannelId = ref.watch(selectedChannelIdProvider);
    final voiceState = ref.watch(voiceRoomProvider);

    if (selectedServer == null) {
      final dmChannelsAsync = ref.watch(dmChannelsProvider);

      return Column(
        children: [
          _ChannelListHeader(
            title: 'Direct Messages',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, size: 18),
                tooltip: 'Find or start a conversation',
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: UserSearchDelegate(ref),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                _ChannelItem(
                  name: 'Friends',
                  icon: Icons.people_alt_rounded,
                  isSelected: false,
                  onTap: () => context.push('/friends'),
                ),
                const SizedBox(height: 8),
                _buildCategory(
                  context,
                  'DIRECT MESSAGES',
                  onAddPressed: () {
                    showSearch(
                      context: context,
                      delegate: UserSearchDelegate(ref),
                    );
                  },
                ),
                dmChannelsAsync.when(
                  data: (channels) => Column(
                    children: channels.map((dm) {
                      final otherId = (dm['participantIds'] as List).firstWhere(
                        (id) => id != ref.read(userProvider)?.uid,
                        orElse: () => '',
                      );

                      return _ChannelItem(
                        name: 'User @$otherId',
                        isDM: true,
                        isSelected: selectedChannelId == dm['id'],
                        onTap: () {
                          ref.read(selectedServerIdProvider.notifier).state =
                              null;
                          ref.read(selectedChannelIdProvider.notifier).state =
                              dm['id'];
                        },
                      );
                    }).toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (err, __) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VoiceControlsBar(),
          const UserProfileBar(),
        ],
      );
    }

    return Column(
      children: [
        // Server Header
        _ServerHeader(serverName: selectedServer.name),

        // Channel List
        Expanded(
          child: channelsAsync.when(
            data: (channels) {
              final textChannels = channels
                  .where((c) => c.type == ChannelType.text)
                  .toList();
              final voiceChannels = channels
                  .where((c) => c.type == ChannelType.voice)
                  .toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _buildCategory(
                    context,
                    'TEXT CHANNELS',
                    onAddPressed: () => showDialog(
                      context: context,
                      builder: (context) =>
                          CreateChannelDialog(serverId: selectedServer.id),
                    ),
                  ),
                  ...textChannels.map(
                    (channel) => _ChannelItem(
                      name: channel.name,
                      isSelected: selectedChannelId == channel.id,
                      onTap: () =>
                          ref.read(selectedChannelIdProvider.notifier).state =
                              channel.id,
                    ),
                  ),

                  // Voice Channels
                  if (voiceChannels.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildCategory(
                      context,
                      'VOICE CHANNELS',
                      onAddPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            CreateChannelDialog(serverId: selectedServer.id),
                      ),
                    ),
                    ...voiceChannels.map((channel) {
                      final isVoiceConnected =
                          voiceState.isConnected &&
                          voiceState.connectedChannelId == channel.id;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ChannelItem(
                            name: channel.name,
                            isVoice: true,
                            isSelected: isVoiceConnected,
                            onTap: () {
                              if (isVoiceConnected) {
                                ref
                                    .read(voiceRoomProvider.notifier)
                                    .leaveRoom();
                              } else {
                                ref
                                    .read(voiceRoomProvider.notifier)
                                    .joinRoom(
                                      channel.id,
                                      selectedServer.name,
                                      channel.name,
                                    );
                              }
                            },
                            trailing: isVoiceConnected
                                ? const _VoiceLiveIndicator()
                                : null,
                          ),
                          if (voiceState.participants.isNotEmpty &&
                              isVoiceConnected)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 32.0,
                                bottom: 4.0,
                              ),
                              child: Column(
                                children: voiceState.participants
                                    .map(
                                      (p) => _ChannelParticipant(
                                        name: p.identity,
                                        isSpeaking: p.isSpeaking,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading channels',
                    style: TextStyle(color: AuraTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const VoiceControlsBar(),
        const UserProfileBar(),
      ],
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title, {
    VoidCallback? onAddPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 4.0,
        left: 8.0,
        right: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AuraTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          if (onAddPressed != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: onAddPressed,
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.add, color: AuraTheme.textMuted, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServerHeader extends StatelessWidget {
  final String serverName;
  const _ServerHeader({required this.serverName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AuraTheme.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              serverName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Icon(Icons.expand_more_rounded, color: AuraTheme.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _ChannelListHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  const _ChannelListHeader({required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: AuraTheme.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _ChannelItem extends StatefulWidget {
  final String name;
  final bool isSelected;
  final bool isVoice;
  final bool isDM;
  final IconData? icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ChannelItem({
    required this.name,
    this.isSelected = false,
    this.isVoice = false,
    this.isDM = false,
    this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  State<_ChannelItem> createState() => _ChannelItemState();
}

class _ChannelItemState extends State<_ChannelItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: widget.onTap,
          onHover: (h) => setState(() => _isHovered = h),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AuraTheme.backgroundModifierActive
                  : (_isHovered
                        ? AuraTheme.backgroundModifierHover.withValues(
                            alpha: 0.6,
                          )
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? AuraTheme.textNormal
                        : AuraTheme.textMuted,
                    size: 22,
                  )
                else if (widget.isDM)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AuraTheme.brandColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 14,
                      color: AuraTheme.brandLight,
                    ),
                  )
                else
                  Icon(
                    widget.isVoice
                        ? Icons.volume_up_rounded
                        : Icons.tag_rounded,
                    color: widget.isSelected
                        ? AuraTheme.textNormal
                        : AuraTheme.textMuted,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : (_isHovered
                                ? AuraTheme.textNormal
                                : AuraTheme.textMuted),
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceLiveIndicator extends StatelessWidget {
  const _VoiceLiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AuraTheme.onlineColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: AuraTheme.onlineColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ChannelParticipant extends StatelessWidget {
  final String name;
  final bool isSpeaking;

  const _ChannelParticipant({required this.name, this.isSpeaking = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isSpeaking
                  ? AuraTheme.onlineColor.withValues(alpha: 0.3)
                  : AuraTheme.backgroundModifierActive,
              shape: BoxShape.circle,
              border: isSpeaking
                  ? Border.all(color: AuraTheme.onlineColor, width: 1.5)
                  : null,
            ),
            child: Icon(
              Icons.person,
              size: 12,
              color: isSpeaking ? AuraTheme.onlineColor : AuraTheme.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSpeaking ? AuraTheme.onlineColor : AuraTheme.textMuted,
                fontSize: 13,
                fontWeight: isSpeaking ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isSpeaking)
            const Icon(Icons.mic, size: 12, color: AuraTheme.onlineColor),
        ],
      ),
    );
  }
}
