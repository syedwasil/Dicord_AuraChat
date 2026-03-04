enum ChannelType { text, voice }

class AuraChannel {
  final String id;
  final String name;
  final String serverId;
  final ChannelType type;

  AuraChannel({
    required this.id,
    required this.name,
    required this.serverId,
    this.type = ChannelType.text,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'serverId': serverId, 'type': type.name};
  }

  factory AuraChannel.fromMap(Map<String, dynamic> map, String id) {
    return AuraChannel(
      id: id,
      name: map['name'] ?? '',
      serverId: map['serverId'] ?? '',
      type: map['type'] == 'voice' ? ChannelType.voice : ChannelType.text,
    );
  }
}
