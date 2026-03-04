import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'widgets/user_search_delegate.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/presentation/providers/chat_providers.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../models/user_model.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      backgroundColor: AuraTheme.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            onPressed: () {
              showSearch(context: context, delegate: UserSearchDelegate(ref));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _PendingRequestsSection(userId: user.uid),
          const Divider(color: AuraTheme.backgroundTertiary),
          const Expanded(child: _FriendsList()),
        ],
      ),
    );
  }
}

class _PendingRequestsSection extends ConsumerWidget {
  final String userId;
  const _PendingRequestsSection({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsStream = ref.watch(pendingRequestsProvider(userId));

    return requestsStream.when(
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'PENDING REQUESTS — ${requests.length}',
                style: const TextStyle(
                  color: AuraTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...requests.map(
              (req) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text(
                  'Friend Request',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  req['fromId'],
                  style: const TextStyle(color: AuraTheme.textMuted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => ref
                          .read(chatRepositoryProvider)
                          .respondToFriendRequest(
                            req['id'],
                            req['fromId'],
                            userId,
                            true,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => ref
                          .read(chatRepositoryProvider)
                          .respondToFriendRequest(
                            req['id'],
                            req['fromId'],
                            userId,
                            false,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FriendsList extends ConsumerWidget {
  const _FriendsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auraUserAsync = ref.watch(auraUserProvider);

    return auraUserAsync.when(
      data: (auraUser) {
        if (auraUser == null || auraUser.friendIds.isEmpty) {
          return const Center(
            child: Text(
              'No friends yet. Add some!',
              style: TextStyle(color: AuraTheme.textMuted),
            ),
          );
        }

        final friendsStream = ref.watch(
          friendsListProvider(auraUser.friendIds),
        );

        return friendsStream.when(
          data: (friends) => ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.photoURL != null
                      ? NetworkImage(friend.photoURL!)
                      : null,
                  child: friend.photoURL == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  friend.displayName ?? 'Unknown',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
                onTap: () async {
                  final currentUser = ref.read(userProvider);
                  final dmId = await ref
                      .read(chatRepositoryProvider)
                      .getOrCreateDMChannel(currentUser!.uid, friend.uid);
                  ref.read(selectedServerIdProvider.notifier).state = null;
                  ref.read(selectedChannelIdProvider.notifier).state = dmId;
                  if (context.mounted) {
                    context.go(
                      '/',
                    ); // Go back to main chat view with DM selected
                  }
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, __) => Center(child: Text('Error: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }
}

final friendsListProvider = StreamProvider.family<List<AuraUser>, List<String>>(
  (ref, friendIds) {
    return ref.watch(chatRepositoryProvider).getFriends(friendIds);
  },
);

final pendingRequestsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      return ref.watch(chatRepositoryProvider).getPendingRequests(userId);
    });
