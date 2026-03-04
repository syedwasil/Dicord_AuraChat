import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/chat/data/chat_repository.dart';
import '../../../../features/chat/presentation/providers/chat_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UserSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  UserSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.length < 3) {
      return const Center(
        child: Text(
          'Type at least 3 characters to search',
          style: TextStyle(color: AuraTheme.textMuted),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(chatRepositoryProvider).searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No users found',
              style: TextStyle(color: AuraTheme.textMuted),
            ),
          );
        }

        final currentUser = ref.read(userProvider);

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isMe = user['uid'] == currentUser?.uid;

            return ListTile(
              onTap: isMe
                  ? null
                  : () async {
                      final dmId = await ref
                          .read(chatRepositoryProvider)
                          .getOrCreateDMChannel(currentUser!.uid, user['uid']);
                      ref.read(selectedServerIdProvider.notifier).state = null;
                      ref.read(selectedChannelIdProvider.notifier).state = dmId;
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
              leading: CircleAvatar(
                backgroundImage: user['photoURL'] != null
                    ? NetworkImage(user['photoURL'])
                    : null,
                child: user['photoURL'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                user['displayName'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user['email'] ?? '',
                style: const TextStyle(color: AuraTheme.textMuted),
              ),
              trailing: isMe
                  ? const Text(
                      'You',
                      style: TextStyle(color: AuraTheme.textMuted),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .sendFriendRequest(currentUser!.uid, user['uid']);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend request sent!'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraTheme.brandColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Add Friend',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AuraTheme.backgroundSecondary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AuraTheme.textMuted),
        border: InputBorder.none,
      ),
    );
  }
}
