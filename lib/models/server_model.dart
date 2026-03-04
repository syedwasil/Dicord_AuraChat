class AuraServer {
  final String id;
  final String name;
  final String imageUrl;
  final String ownerId;
  final List<String> memberIds;

  AuraServer({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.ownerId,
    required this.memberIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'memberIds': memberIds,
    };
  }

  factory AuraServer.fromMap(Map<String, dynamic> map, String id) {
    return AuraServer(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
    );
  }
}
