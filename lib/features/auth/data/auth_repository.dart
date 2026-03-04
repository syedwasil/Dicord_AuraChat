import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': user.displayName ?? user.email?.split('@').first,
      'email': user.email,
      'photoURL': user.photoURL,
      'friendIds': [],
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'displayName': name,
    });
    await _auth.currentUser?.reload();
  }

  Future<void> updatePhotoURL(String? photoURL) async {
    await _auth.currentUser?.updatePhotoURL(photoURL);
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'photoURL': photoURL,
    });
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
