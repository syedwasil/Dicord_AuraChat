import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _userCacheProvider = StateProvider<Map<String, Map<String, dynamic>>>(
  (ref) => {},
);

class MemberListSidebar extends ConsumerWidget {
  const MemberListSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);

    if (selectedServer == null) return const SizedBox.shrink();

    return Container(
      width: 240,
      color: AuraTheme.backgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'MEMBERS — ${selectedServer.memberIds.length}',
              style: const TextStyle(
                color: AuraTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: selectedServer.memberIds.length,
              itemBuilder: (context, index) {
                final memberId = selectedServer.memberIds[index];
                final currentUser = ref.read(userProvider);
                return _MemberItem(
                  userId: memberId,
                  isMe: memberId == currentUser?.uid,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberItem extends ConsumerStatefulWidget {
  final String userId;
  final bool isMe;

  const _MemberItem({required this.userId, this.isMe = false});

  @override
  ConsumerState<_MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends ConsumerState<_MemberItem> {
  bool _isHovered = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final cache = ref.read(_userCacheProvider);
    if (cache.containsKey(widget.userId)) {
      if (mounted) setState(() => _userData = cache[widget.userId]);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        ref.read(_userCacheProvider.notifier).state = {
          ...ref.read(_userCacheProvider),
          widget.userId: data,
        };
        setState(() => _userData = data);
      }
    } catch (_) {
      // silently fail, show truncated ID
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _userData?['displayName'] as String? ??
        'User ${widget.userId.substring(0, 5)}';
    final photoURL = _userData?['photoURL'] as String?;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: _isHovered
              ? AuraTheme.backgroundModifierHover.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AuraTheme.brandColor,
                  backgroundImage: photoURL != null
                      ? NetworkImage(photoURL)
                      : null,
                  child: photoURL == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
                        color: AuraTheme.backgroundSecondary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isMe ? '$displayName (you)' : displayName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.isMe
                          ? AuraTheme.brandLight
                          : AuraTheme.textMuted,
                      fontSize: 13,
                      fontWeight: widget.isMe
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
