import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_repository.dart';
import '../../../../models/server_model.dart';
import '../../../../models/channel_model.dart';
import '../../../../models/message_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// --- State Providers ---

/// The currently selected server ID
final selectedServerIdProvider = StateProvider<String?>((ref) => null);

/// The currently selected channel ID
final selectedChannelIdProvider = StateProvider<String?>((ref) => null);

// --- Stream Providers ---

/// Stream of all servers the current user is a member of
final serversProvider = StreamProvider<List<AuraServer>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return const Stream.empty();

  return ref.watch(chatRepositoryProvider).getServers(user.uid);
});

/// Stream of channels for the currently selected server
final channelsProvider = StreamProvider<List<AuraChannel>>((ref) {
  final serverId = ref.watch(selectedServerIdProvider);
  if (serverId == null) return const Stream.empty();

  return ref.watch(chatRepositoryProvider).getChannels(serverId);
});

/// Stream of messages for the currently selected channel
final messagesProvider = StreamProvider<List<AuraMessage>>((ref) {
  final channelId = ref.watch(selectedChannelIdProvider);
  if (channelId == null) return const Stream.empty();

  return ref.watch(chatRepositoryProvider).getMessages(channelId);
});

/// Stream of DM channels for the current user
final dmChannelsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return const Stream.empty();

  return ref.watch(chatRepositoryProvider).getDMChannels(user.uid);
});

// --- Derived Providers ---

/// Helper to get the actual server object from the selected ID
final selectedServerProvider = Provider<AuraServer?>((ref) {
  final servers = ref.watch(serversProvider).value ?? [];
  final selectedId = ref.watch(selectedServerIdProvider);
  if (selectedId == null) return null;

  try {
    return servers.firstWhere((s) => s.id == selectedId);
  } catch (_) {
    return null;
  }
});

/// Helper to get the actual channel object from the selected ID
final selectedChannelProvider = Provider<AuraChannel?>((ref) {
  final channels = ref.watch(channelsProvider).value ?? [];
  final selectedId = ref.watch(selectedChannelIdProvider);
  if (selectedId == null) return null;

  try {
    return channels.firstWhere((c) => c.id == selectedId);
  } catch (_) {
    return null;
  }
});
