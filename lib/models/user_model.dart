class AuraUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final List<String> friendIds;

  AuraUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.friendIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'friendIds': friendIds,
    };
  }

  factory AuraUser.fromMap(Map<String, dynamic> map, String uid) {
    return AuraUser(
      uid: uid,
      displayName: map['displayName'],
      email: map['email'],
      photoURL: map['photoURL'],
      friendIds: List<String>.from(map['friendIds'] ?? []),
    );
  }
}
