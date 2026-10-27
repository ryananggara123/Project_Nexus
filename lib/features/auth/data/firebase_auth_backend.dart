import 'package:firebase_auth/firebase_auth.dart';

import 'cloud_account_service.dart';

/// [AuthBackend] yang memakai Firebase Authentication. Sesi login disimpan
/// otomatis oleh Firebase (IndexedDB di web, penyimpanan aman di Android).
class FirebaseAuthBackend implements AuthBackend {
  FirebaseAuthBackend(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<String?> currentUserId() async {
    // Di web, sesi tersimpan baru terbaca setelah status awal dikirim.
    final user = await _auth.authStateChanges().first;
    return user?.uid;
  }

  @override
  Future<String> signIn(String email, String password) => _run(() async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  });

  @override
  Future<String> createUser(String email, String password) => _run(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  });

  @override
  Future<void> signOut() => _auth.signOut();

  static Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthBackendException(error.code);
    }
  }
}
