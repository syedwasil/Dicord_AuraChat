import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../../models/channel_model.dart';

class CreateChannelDialog extends ConsumerStatefulWidget {
  final String serverId;
  const CreateChannelDialog({super.key, required this.serverId});

  @override
  ConsumerState<CreateChannelDialog> createState() =>
      _CreateChannelDialogState();
}

class _CreateChannelDialogState extends ConsumerState<CreateChannelDialog> {
  final _nameController = TextEditingController();
  String _type = 'text';
  bool _isLoading = false;

  Future<void> _createChannel() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    final channel = AuraChannel(
      id: '',
      serverId: widget.serverId,
      name: name.replaceAll(' ', '-').toLowerCase(),
      type: _type == 'voice' ? ChannelType.voice : ChannelType.text,
    );

    try {
      await ref.read(chatRepositoryProvider).createChannel(channel);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuraTheme.backgroundPrimary,
      title: const Text(
        'Create Channel',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type Selector
          _buildTypeOption(
            icon: Icons.tag,
            title: 'Text',
            subtitle: 'Send messages, images, and GIFs',
            value: 'text',
          ),
          const SizedBox(height: 8),
          _buildTypeOption(
            icon: Icons.volume_up,
            title: 'Voice',
            subtitle: 'Hang out together with voice and video',
            value: 'voice',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'CHANNEL NAME',
              prefixText: _type == 'text' ? '# ' : '🔊 ',
              prefixStyle: const TextStyle(color: AuraTheme.textMuted),
              labelStyle: const TextStyle(
                color: AuraTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: AuraTheme.backgroundTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createChannel,
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraTheme.brandColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Create Channel',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AuraTheme.backgroundTertiary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AuraTheme.brandColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AuraTheme.textMuted,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AuraTheme.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AuraTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _type,
              onChanged: (v) => setState(() => _type = v!),
              activeColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
