import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../models/server_model.dart';
import '../../../models/channel_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance, FirebaseStorage.instance);
});

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ChatRepository(this._firestore, this._storage);

  // --- Storage ---

  Future<String> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('chat_images').child(fileName);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // --- Servers ---

  Stream<List<AuraServer>> getServers(String userId) {
    return _firestore
        .collection('servers')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuraServer.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> createServer(AuraServer server) async {
    final docRef = await _firestore.collection('servers').add(server.toMap());
    // Create a default #general channel
    await createChannel(
      AuraChannel(
        id: '',
        name: 'general',
        serverId: docRef.id,
        type: ChannelType.text,
      ),
    );
    return docRef.id;
  }

  // --- Channels ---

  Stream<List<AuraChannel>> getChannels(String serverId) {
    return _firestore
        .collection('channels')
        .where('serverId', isEqualTo: serverId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuraChannel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> createChannel(AuraChannel channel) async {
    final docRef = await _firestore.collection('channels').add(channel.toMap());
    return docRef.id;
  }

  // --- Messages ---

  Stream<List<AuraMessage>> getMessages(String channelId) {
    return _firestore
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuraMessage.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(String channelId, AuraMessage message) async {
    await _firestore
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .add(message.toMap());
  }

  // --- Global User Search & Friends ---

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // Simple prefix search using Firestore query
    final snapshot = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => {...doc.data(), 'uid': doc.id}).toList();
  }

  Future<void> sendFriendRequest(String fromId, String toId) async {
    await _firestore.collection('friend_requests').add({
      'fromId': fromId,
      'toId': toId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getPendingRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('toId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  Future<void> respondToFriendRequest(
    String requestId,
    String fromId,
    String toId,
    bool accept,
  ) async {
    if (accept) {
      await _firestore.runTransaction((transaction) async {
        transaction.update(
          _firestore.collection('friend_requests').doc(requestId),
          {'status': 'accepted'},
        );

        final fromRef = _firestore.collection('users').doc(fromId);
        final toRef = _firestore.collection('users').doc(toId);

        transaction.update(fromRef, {
          'friendIds': FieldValue.arrayUnion([toId]),
        });
        transaction.update(toRef, {
          'friendIds': FieldValue.arrayUnion([fromId]),
        });
      });
    } else {
      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'declined',
      });
    }
  }

  // --- Direct Messaging ---

  Future<String> getOrCreateDMChannel(String user1Id, String user2Id) async {
    final participantIds = [user1Id, user2Id]..sort();

    final existing = await _firestore
        .collection('dm_channels')
        .where('participantIds', isEqualTo: participantIds)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final docRef = await _firestore.collection('dm_channels').add({
      'participantIds': participantIds,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Stream<List<Map<String, dynamic>>> getDMChannels(String userId) {
    return _firestore
        .collection('dm_channels')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  Stream<List<AuraUser>> getFriends(List<String> friendIds) {
    if (friendIds.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuraUser.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
