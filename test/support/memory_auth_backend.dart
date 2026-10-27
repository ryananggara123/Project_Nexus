import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/features/auth/data/cloud_account_service.dart';

/// Firebase Authentication tiruan untuk pengujian.
class MemoryAuthBackend implements AuthBackend {
  final Map<String, ({String uid, String password})> _users = {};
  String? _currentUserId;
  int _nextId = 0;

  @override
  Future<String?> currentUserId() async => _currentUserId;

  @override
  Future<String> signIn(String email, String password) async {
    final user = _users[email.toLowerCase()];
    if (user == null || user.password != password) {
      throw const AuthBackendException('invalid-credential');
    }
    return _currentUserId = user.uid;
  }

  @override
  Future<String> createUser(String email, String password) async {
    if (_users.containsKey(email.toLowerCase())) {
      throw const AuthBackendException('email-already-in-use');
    }
    if (password.length < 6) throw const AuthBackendException('weak-password');
    final uid = 'uid-${++_nextId}';
    _users[email.toLowerCase()] = (uid: uid, password: password);
    return _currentUserId = uid;
  }

  @override
  Future<void> signOut() async => _currentUserId = null;

  /// Membuat akun guru seperti yang dilakukan administrator sekolah.
  Future<void> addTeacher(
    MemoryCloudStore cloud, {
    required String name,
    required String email,
    required String password,
  }) async {
    final uid = await createUser(email, password);
    await cloud.set(CloudAccountService.usersCollection, uid, {
      'fullName': name,
      'role': 'teacher',
      'email': email,
    });
    await signOut();
  }
}
