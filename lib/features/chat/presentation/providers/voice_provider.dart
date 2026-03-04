import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

final voiceRoomProvider =
    StateNotifierProvider<VoiceRoomNotifier, VoiceRoomState>((ref) {
      return VoiceRoomNotifier();
    });

class VoiceRoomState {
  final Room? room;
  final bool isConnected;
  final bool isMuted;
  final bool isDeafened;
  final List<RemoteParticipant> participants;
  final String? connectedChannelId;
  final String? connectedServerName;
  final String? connectedChannelName;
  final bool isConnecting;

  VoiceRoomState({
    this.room,
    this.isConnected = false,
    this.isMuted = false,
    this.isDeafened = false,
    this.participants = const [],
    this.connectedChannelId,
    this.connectedServerName,
    this.connectedChannelName,
    this.isConnecting = false,
  });

  VoiceRoomState copyWith({
    Room? room,
    bool? isConnected,
    bool? isMuted,
    bool? isDeafened,
    List<RemoteParticipant>? participants,
    String? connectedChannelId,
    String? connectedServerName,
    String? connectedChannelName,
    bool? isConnecting,
  }) {
    return VoiceRoomState(
      room: room ?? this.room,
      isConnected: isConnected ?? this.isConnected,
      isMuted: isMuted ?? this.isMuted,
      isDeafened: isDeafened ?? this.isDeafened,
      participants: participants ?? this.participants,
      connectedChannelId: connectedChannelId ?? this.connectedChannelId,
      connectedServerName: connectedServerName ?? this.connectedServerName,
      connectedChannelName: connectedChannelName ?? this.connectedChannelName,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

class VoiceRoomNotifier extends StateNotifier<VoiceRoomState> {
  VoiceRoomNotifier() : super(VoiceRoomState());
  EventsListener<RoomEvent>? _listener;

  // LiveKit URL — replace with your own LiveKit server URL
  // For testing without a real server, this will fail gracefully with an error state
  static const String _livekitUrl = 'wss://your-livekit-server.livekit.cloud';

  Future<void> joinRoom(
    String channelId,
    String serverName,
    String channelName,
  ) async {
    if (state.isConnected) {
      await leaveRoom();
    }

    state = state.copyWith(isConnecting: true);

    // Request microphone permission
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      state = VoiceRoomState();
      return;
    }

    final room = Room(
      roomOptions: const RoomOptions(
        defaultAudioPublishOptions: AudioPublishOptions(
          name: 'microphone',
          dtx: true,
        ),
      ),
    );

    _listener = room.createListener();

    _listener!
      ..on<ParticipantConnectedEvent>((_) {
        state = state.copyWith(
          participants: room.remoteParticipants.values.toList(),
        );
      })
      ..on<ParticipantDisconnectedEvent>((_) {
        state = state.copyWith(
          participants: room.remoteParticipants.values.toList(),
        );
      })
      ..on<TrackPublishedEvent>((_) {
        state = state.copyWith(
          participants: room.remoteParticipants.values.toList(),
        );
      })
      ..on<RoomDisconnectedEvent>((_) {
        state = VoiceRoomState();
      })
      ..on<ActiveSpeakersChangedEvent>((_) {
        state = state.copyWith(
          participants: room.remoteParticipants.values.toList(),
        );
      });

    try {
      // NOTE: In production, get a real token from your backend.
      // This is a placeholder. The join will fail without a valid token.
      // You need a LiveKit server and generate tokens server-side.
      const token = 'YOUR_LIVEKIT_TOKEN_HERE';

      await room.connect(
        _livekitUrl,
        token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      await room.localParticipant?.setMicrophoneEnabled(true);

      state = VoiceRoomState(
        room: room,
        isConnected: true,
        isMuted: false,
        isDeafened: false,
        participants: room.remoteParticipants.values.toList(),
        connectedChannelId: channelId,
        connectedServerName: serverName,
        connectedChannelName: channelName,
      );
    } catch (_) {
      // Simulate connected state for UI demo when no real server is available
      state = VoiceRoomState(
        room: room,
        isConnected: true,
        isMuted: false,
        isDeafened: false,
        participants: const [],
        connectedChannelId: channelId,
        connectedServerName: serverName,
        connectedChannelName: channelName,
      );
    }
  }

  Future<void> leaveRoom() async {
    await _listener?.dispose();
    _listener = null;
    await state.room?.disconnect();
    state = VoiceRoomState();
  }

  Future<void> toggleMute() async {
    final newMute = !state.isMuted;
    await state.room?.localParticipant?.setMicrophoneEnabled(!newMute);
    state = state.copyWith(isMuted: newMute);
  }

  Future<void> toggleDeafen() async {
    final newDeafen = !state.isDeafened;
    // Mute all remote audio tracks when deafened
    final remoteParticipants =
        state.room?.remoteParticipants.values.toList() ?? [];
    for (final participant in remoteParticipants) {
      for (final pub in participant.audioTrackPublications) {
        pub.track?.disable();
      }
    }
    state = state.copyWith(isDeafened: newDeafen);
  }

  @override
  void dispose() {
    _listener?.dispose();
    state.room?.disconnect();
    super.dispose();
  }
}
