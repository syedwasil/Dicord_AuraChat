import 'package:cloud_firestore/cloud_firestore.dart';

class AuraMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final DateTime timestamp;

  final String? imageUrl;

  AuraMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
    };
  }

  factory AuraMessage.fromMap(Map<String, dynamic> map, String id) {
    return AuraMessage(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatarUrl: map['senderAvatarUrl'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }
}
