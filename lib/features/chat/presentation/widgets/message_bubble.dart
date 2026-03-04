import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class MessageBubble extends StatefulWidget {
  final String sender;
  final String text;
  final String timestamp;
  final String? avatarUrl;
  final String? imageUrl;
  final bool isConsecutive;
  final bool isOwnMessage;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.avatarUrl,
    this.imageUrl,
    this.isConsecutive = false,
    this.isOwnMessage = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _fadeController;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacityAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: _isHovered
                ? AuraTheme.backgroundModifierHover.withValues(alpha: 0.3)
                : Colors.transparent,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: widget.isConsecutive ? 2.0 : 16.0,
              bottom: 2.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar area (40px wide)
                SizedBox(
                  width: 40,
                  child: widget.isConsecutive
                      ? (_isHovered
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  widget.timestamp.split(' ').last,
                                  style: const TextStyle(
                                    color: AuraTheme.textMuted,
                                    fontSize: 9,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox.shrink())
                      : _buildAvatar(),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isConsecutive) _buildHeader(),
                      if (!widget.isConsecutive) const SizedBox(height: 2),
                      if (widget.text.isNotEmpty) _buildMessageText(),
                      if (widget.imageUrl != null) _buildImageAttachment(),
                    ],
                  ),
                ),

                // Hover action buttons
                if (_isHovered) _buildHoverActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AuraTheme.brandColor,
      backgroundImage: widget.avatarUrl != null
          ? NetworkImage(widget.avatarUrl!)
          : null,
      child: widget.avatarUrl == null
          ? Text(
              widget.sender.isNotEmpty ? widget.sender[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.sender,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.timestamp,
          style: const TextStyle(color: AuraTheme.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMessageText() {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: SelectableText(
        widget.text,
        style: const TextStyle(
          color: AuraTheme.textNormal,
          fontSize: 15,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildImageAttachment() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 350),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            widget.imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  color: AuraTheme.backgroundTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: AuraTheme.brandColor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AuraTheme.backgroundTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined, color: AuraTheme.textMuted),
                  SizedBox(width: 8),
                  Text(
                    'Image failed to load',
                    style: TextStyle(color: AuraTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoverActions() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AuraTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AuraTheme.backgroundModifierActive, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HoverAction(icon: Icons.mood, tooltip: 'React'),
          _HoverAction(icon: Icons.reply_rounded, tooltip: 'Reply'),
          _HoverAction(icon: Icons.more_horiz, tooltip: 'More'),
        ],
      ),
    );
  }
}

class _HoverAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;

  const _HoverAction({required this.icon, required this.tooltip});

  @override
  State<_HoverAction> createState() => _HoverActionState();
}

class _HoverActionState extends State<_HoverAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AuraTheme.backgroundModifierActive
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? AuraTheme.textNormal : AuraTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
