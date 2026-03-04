import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'message_bubble.dart';
import '../providers/chat_providers.dart';

import '../../../../core/theme.dart';
import '../../../../models/channel_model.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider);
    final selectedChannel = ref.watch(selectedChannelProvider);

    // Don't show message list for voice channels
    if (selectedChannel?.type == ChannelType.voice) {
      return const SizedBox.shrink();
    }

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return const _EmptyChannelView();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final bool isConsecutive =
                index + 1 < messages.length &&
                messages[index].senderId == messages[index + 1].senderId &&
                messages[index].timestamp
                        .difference(messages[index + 1].timestamp)
                        .inMinutes
                        .abs() <
                    5;

            return MessageBubble(
              key: ValueKey(message.id.isEmpty ? index : message.id),
              sender: message.senderName,
              text: message.text,
              timestamp: _formatTimestamp(message.timestamp),
              avatarUrl: message.senderAvatarUrl,
              imageUrl: message.imageUrl,
              isConsecutive: isConsecutive,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AuraTheme.brandColor,
        ),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AuraTheme.dangerColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Error loading messages',
              style: TextStyle(color: AuraTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      final hour = timestamp.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final m = timestamp.minute.toString().padLeft(2, '0');
      return 'Today at $h:$m $ampm';
    } else if (diff.inDays == 1) {
      final hour = timestamp.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final m = timestamp.minute.toString().padLeft(2, '0');
      return 'Yesterday at $h:$m $ampm';
    }
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }
}

class _EmptyChannelView extends StatelessWidget {
  const _EmptyChannelView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AuraTheme.brandColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tag_rounded,
                size: 32,
                color: AuraTheme.brandLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'This is the beginning of this channel!\nSay hi to get things started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuraTheme.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
