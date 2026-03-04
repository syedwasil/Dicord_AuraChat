import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/presentation/server_channel_drawer.dart';
import '../../chat/presentation/chat_view.dart';
import '../../chat/presentation/providers/chat_providers.dart';
import '../../navigation/presentation/widgets/member_list_sidebar.dart';
import '../../navigation/presentation/widgets/server_list.dart';
import '../../navigation/presentation/widgets/channel_list.dart';
import 'widgets/user_search_delegate.dart';
import '../../../core/theme.dart';

final showMemberListProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);
    final selectedChannel = ref.watch(selectedChannelProvider);
    final selectedServerId = ref.watch(selectedServerIdProvider);
    final showMemberList = ref.watch(showMemberListProvider);

    String title = 'AuraChat';
    if (selectedServerId == null) {
      title = 'Direct Messages';
    } else if (selectedChannel != null) {
      title = '# ${selectedChannel.name}';
    } else if (selectedServer != null) {
      title = selectedServer.name;
    }

    final bool isWide = MediaQuery.of(context).size.width > 700;

    if (isWide) {
      // Desktop / Tablet layout: side-by-side panels
      return Scaffold(
        backgroundColor: AuraTheme.backgroundPrimary,
        body: Row(
          children: [
            // Server list (icons sidebar)
            const ServerList(),

            // Channel list
            SizedBox(
              width: 240,
              child: Container(
                color: AuraTheme.backgroundSecondary,
                child: const ChannelList(),
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  _DesktopAppBar(
                    title: title,
                    selectedServerId: selectedServerId,
                    showMemberList: showMemberList,
                    onSearchTap: () => showSearch(
                      context: context,
                      delegate: UserSearchDelegate(ref),
                    ),
                    onMemberListToggle: () =>
                        ref.read(showMemberListProvider.notifier).state =
                            !showMemberList,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Expanded(child: ChatView()),
                        if (showMemberList && selectedServerId != null) ...[
                          const VerticalDivider(
                            width: 1,
                            color: AuraTheme.backgroundTertiary,
                          ),
                          const MemberListSidebar(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout: drawer-based
    return Scaffold(
      backgroundColor: AuraTheme.backgroundPrimary,
      drawer: const ServerChannelDrawer(),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AuraTheme.backgroundSecondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search users',
            onPressed: () {
              showSearch(context: context, delegate: UserSearchDelegate(ref));
            },
          ),
          if (selectedServerId != null)
            IconButton(
              icon: Icon(
                Icons.people_alt_rounded,
                color: showMemberList
                    ? AuraTheme.brandLight
                    : AuraTheme.textMuted,
              ),
              tooltip: 'Members',
              onPressed: () {
                ref.read(showMemberListProvider.notifier).state =
                    !showMemberList;
              },
            ),
        ],
      ),
      body: Row(
        children: [
          const Expanded(child: ChatView()),
          if (showMemberList && selectedServerId != null) ...[
            const VerticalDivider(
              width: 1,
              color: AuraTheme.backgroundTertiary,
            ),
            const MemberListSidebar(),
          ],
        ],
      ),
    );
  }
}

class _DesktopAppBar extends StatelessWidget {
  final String title;
  final String? selectedServerId;
  final bool showMemberList;
  final VoidCallback onSearchTap;
  final VoidCallback onMemberListToggle;

  const _DesktopAppBar({
    required this.title,
    required this.selectedServerId,
    required this.showMemberList,
    required this.onSearchTap,
    required this.onMemberListToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AuraTheme.backgroundPrimary,
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
          const SizedBox(width: 16),
          if (title.startsWith('#'))
            const Icon(Icons.tag_rounded, color: AuraTheme.textMuted, size: 20)
          else
            const SizedBox.shrink(),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          _AppBarButton(
            icon: Icons.search_rounded,
            tooltip: 'Search users',
            onTap: onSearchTap,
          ),
          if (selectedServerId != null)
            _AppBarButton(
              icon: Icons.people_alt_rounded,
              tooltip: 'Member list',
              isActive: showMemberList,
              onTap: onMemberListToggle,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _AppBarButton({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<_AppBarButton> {
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
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AuraTheme.backgroundModifierActive
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.isActive
                  ? AuraTheme.brandLight
                  : (_isHovered ? AuraTheme.textNormal : AuraTheme.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}
