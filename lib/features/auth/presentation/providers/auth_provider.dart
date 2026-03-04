import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final auraUserProvider = StreamProvider<AuraUser?>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map(
        (snap) => snap.exists ? AuraUser.fromMap(snap.data()!, snap.id) : null,
      );
});
