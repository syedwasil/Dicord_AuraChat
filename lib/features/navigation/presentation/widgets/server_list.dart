import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import 'create_server_dialog.dart';

class ServerList extends ConsumerWidget {
  const ServerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serversProvider);
    final selectedServerId = ref.watch(selectedServerIdProvider);

    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AuraTheme.backgroundTertiary,
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Home Icon (Direct Messages)
          _ServerIcon(
            icon: Icons.chat_bubble_rounded,
            tooltip: 'Direct Messages',
            isSelected: selectedServerId == null,
            onTap: () {
              ref.read(selectedServerIdProvider.notifier).state = null;
              ref.read(selectedChannelIdProvider.notifier).state = null;
            },
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 6.0,
            ),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AuraTheme.backgroundModifierActive,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Server List
          Expanded(
            child: serversAsync.when(
              data: (servers) => ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final server = servers[index];
                  return _ServerIcon(
                    imageUrl: server.imageUrl,
                    name: server.name,
                    tooltip: server.name,
                    isSelected: selectedServerId == server.id,
                    onTap: () {
                      ref.read(selectedServerIdProvider.notifier).state =
                          server.id;
                      ref.read(selectedChannelIdProvider.notifier).state = null;
                    },
                  );
                },
              ),
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, stack) => const Icon(Icons.error, color: Colors.red),
            ),
          ),

          // Add Server Button
          _ServerIcon(
            icon: Icons.add_rounded,
            iconColor: AuraTheme.onlineColor,
            tooltip: 'Create a Server',
            isSelected: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const CreateServerDialog(),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ServerIcon extends StatefulWidget {
  final String? imageUrl;
  final String? name;
  final String? tooltip;
  final IconData? icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServerIcon({
    this.imageUrl,
    this.name,
    this.tooltip,
    this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ServerIcon> createState() => _ServerIconState();
}

class _ServerIconState extends State<_ServerIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      preferBelow: false,
      verticalOffset: 0,
      margin: const EdgeInsets.only(left: 72),
      decoration: BoxDecoration(
        color: AuraTheme.backgroundInput,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: SizedBox(
              width: 72,
              child: Row(
                children: [
                  // Selection pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 4,
                    height: widget.isSelected ? 40 : (_isHovered ? 20 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  // Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AuraTheme.brandColor
                          : (_isHovered
                                ? AuraTheme.brandDark
                                : AuraTheme.backgroundSecondary),
                      borderRadius: BorderRadius.circular(
                        (widget.isSelected || _isHovered) ? 16 : 24,
                      ),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: AuraTheme.brandColor.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        (widget.isSelected || _isHovered) ? 16 : 24,
                      ),
                      child: widget.icon != null
                          ? Icon(
                              widget.icon,
                              color: widget.iconColor ?? Colors.white,
                              size: 24,
                            )
                          : (widget.imageUrl != null &&
                                widget.imageUrl!.isNotEmpty)
                          ? Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  widget.name != null
                                      ? widget.name![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                widget.name != null
                                    ? widget.name![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
