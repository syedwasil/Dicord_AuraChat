import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme.dart';
import 'widgets/message_list.dart';
import 'providers/chat_providers.dart';
import '../data/chat_repository.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../models/message_model.dart';
import '../../../models/channel_model.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final user = ref.read(userProvider);
    final channelId = ref.read(selectedChannelIdProvider);
    if (user == null || channelId == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final message = AuraMessage(
      id: '',
      text: text,
      senderId: user.uid,
      senderName: user.displayName ?? user.email ?? 'Unknown',
      senderAvatarUrl: user.photoURL,
      timestamp: DateTime.now(),
    );

    try {
      await ref.read(chatRepositoryProvider).sendMessage(channelId, message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    final user = ref.read(userProvider);
    final channelId = ref.read(selectedChannelIdProvider);
    if (user == null || channelId == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Uploading image...')));

    try {
      final imageUrl = await ref
          .read(chatRepositoryProvider)
          .uploadImage(File(image.path));

      final message = AuraMessage(
        id: '',
        text: '',
        senderId: user.uid,
        senderName: user.displayName ?? user.email ?? 'Unknown',
        senderAvatarUrl: user.photoURL,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      await ref.read(chatRepositoryProvider).sendMessage(channelId, message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChannel = ref.watch(selectedChannelProvider);

    if (selectedChannel == null) {
      return _buildWelcomeView();
    }

    // If it's a voice channel, show voice channel UI
    if (selectedChannel.type == ChannelType.voice) {
      return _buildVoiceChannelView(selectedChannel.name);
    }

    return Column(
      children: [
        const Expanded(child: MessageList()),
        _buildMessageInput(selectedChannel.name),
      ],
    );
  }

  Widget _buildWelcomeView() {
    return Container(
      color: AuraTheme.backgroundPrimary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AuraTheme.brandGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraTheme.brandColor.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to AuraChat!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a channel from the sidebar\nto start chatting.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuraTheme.textMuted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceChannelView(String channelName) {
    return Container(
      color: AuraTheme.backgroundPrimary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AuraTheme.onlineColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AuraTheme.onlineColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                size: 48,
                color: AuraTheme.onlineColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              channelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Voice Channel',
              style: TextStyle(color: AuraTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Click the channel in the sidebar to join.',
              style: TextStyle(color: AuraTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(String channelName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: AuraTheme.backgroundPrimary,
      child: Container(
        decoration: BoxDecoration(
          color: AuraTheme.backgroundInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AuraTheme.backgroundModifierActive,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Attach button
            Tooltip(
              message: 'Add attachment',
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: AuraTheme.textMuted,
                  size: 22,
                ),
                onPressed: _sendImage,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                constraints: const BoxConstraints(),
              ),
            ),

            // Text field
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  color: AuraTheme.textNormal,
                  fontSize: 15,
                ),
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message #$channelName',
                  hintStyle: const TextStyle(
                    color: AuraTheme.textMuted,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            // Emoji placeholder
            Tooltip(
              message: 'Emoji (coming soon)',
              child: IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: AuraTheme.textMuted,
                  size: 22,
                ),
                onPressed: () {},
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
              ),
            ),

            // Send button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: AuraTheme.brandGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AuraTheme.brandColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _sendMessage,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
