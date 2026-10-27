import '../../../core/cloud/cloud_store.dart';
import '../models/user_role.dart';
import 'account_service.dart';

/// Autentikasi email dan kata sandi di server (Firebase Authentication).
/// Dipisah dari [CloudAccountService] agar aturan akun dapat diuji tanpa
/// Firebase.
abstract interface class AuthBackend {
  /// ID pengguna yang masih masuk dari sesi sebelumnya.
  Future<String?> currentUserId();

  /// Mengembalikan ID pengguna; melempar [AuthBackendException] bila gagal.
  Future<String> signIn(String email, String password);

  Future<String> createUser(String email, String password);

  Future<void> signOut();
}

/// Kegagalan dari server autentikasi, misalnya `invalid-credential`.
class AuthBackendException implements Exception {
  const AuthBackendException(this.code);

  final String code;

  @override
  String toString() => 'AuthBackendException($code)';
}

/// Akun di Firebase: kata sandi dikelola Firebase Authentication, profil dan
/// peran disimpan di koleksi `users`. Koleksi `login_ids` memetakan NIM dan
/// username ke email agar siswa dapat masuk dengan salah satunya.
class CloudAccountService implements AccountService {
  CloudAccountService({required this._auth, required this._cloud});

  static const usersCollection = 'users';
  static const loginIdsCollection = 'login_ids';

  final AuthBackend _auth;
  final CloudStore _cloud;

  @override
  String get storageNote =>
      'Akun tersimpan di Firebase dan dapat dipakai di perangkat lain.';

  @override
  Future<UserAccount?> restoreSession() async {
    try {
      final userId = await _auth.currentUserId();
      if (userId == null) return null;
      final account = await _profile(userId);
      if (account == null) await _auth.signOut();
      return account;
    } on Object {
      // Profil tidak dapat dibaca (misalnya offline): pengguna masuk ulang.
      return null;
    }
  }

  @override
  Future<UserAccount> signIn({
    required UserRole role,
    required String identifier,
    required String password,
  }) {
    return _connected(() async {
      final normalized = identifier.trim().toLowerCase();
      final byEmail = normalized.contains('@');
      final email = byEmail ? normalized : await _emailForLoginId(normalized);

      final String userId;
      try {
        userId = await _auth.signIn(email, password);
      } on AuthBackendException catch (error) {
        throw _describe(error, byEmail: byEmail);
      }

      final account = await _profile(userId);
      if (account == null || account.role != role) {
        await _auth.signOut();
        throw AccountException(
          role == UserRole.teacher
              ? 'Akun ini bukan akun guru pendamping.'
              : 'Akun ini terdaftar sebagai guru. Pilih tab Guru.',
          field: AccountField.identifier,
        );
      }
      return account;
    });
  }

  @override
  Future<void> register(StudentRegistration registration) {
    return _connected(() async {
      final nim = registration.nim.trim();
      final username = registration.username.trim().toLowerCase();
      final email = registration.email.trim().toLowerCase();
      if (await _cloud.get(loginIdsCollection, nim) != null) {
        throw const AccountException(
          'NIM sudah terdaftar.',
          field: AccountField.nim,
        );
      }
      if (await _cloud.get(loginIdsCollection, username) != null) {
        throw const AccountException(
          'Username sudah digunakan.',
          field: AccountField.username,
        );
      }

      final String userId;
      try {
        userId = await _auth.createUser(email, registration.password);
      } on AuthBackendException catch (error) {
        throw _describe(error, byEmail: true);
      }

      final account = UserAccount(
        id: userId,
        name: registration.fullName.trim(),
        role: UserRole.student,
        email: email,
        nim: nim,
        username: registration.username.trim(),
      );
      final login = {'email': email, 'uid': userId};
      await _cloud.set(usersCollection, userId, account.toJson());
      await _cloud.set(loginIdsCollection, nim, login);
      await _cloud.set(loginIdsCollection, username, login);
      // Sama seperti mode lokal: setelah mendaftar, siswa masuk sendiri.
      await _auth.signOut();
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<UserAccount?> _profile(String userId) async {
    final json = await _cloud.get(usersCollection, userId);
    return json == null ? null : UserAccount.tryFromJson(userId, json);
  }

  Future<String> _emailForLoginId(String loginId) async {
    final email = (await _cloud.get(loginIdsCollection, loginId))?['email'];
    if (email is! String) {
      throw const AccountException(
        'Akun siswa tidak ditemukan. Periksa data masuk.',
        field: AccountField.identifier,
      );
    }
    return email;
  }

  /// Menjalankan [action]; kesalahan selain [AccountException] (misalnya
  /// jaringan) diubah menjadi pesan yang dapat dipahami pengguna.
  Future<T> _connected<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AccountException {
      rethrow;
    } on Object {
      throw const AccountException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet lalu coba lagi.',
      );
    }
  }

  static AccountException _describe(
    AuthBackendException error, {
    required bool byEmail,
  }) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-email' => AccountException(
        byEmail
            ? 'Email atau kata sandi tidak sesuai.'
            : 'Kata sandi tidak sesuai.',
        field: AccountField.password,
      ),
      'email-already-in-use' => const AccountException(
        'Email sudah terdaftar.',
        field: AccountField.email,
      ),
      'weak-password' => const AccountException(
        'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.',
        field: AccountField.password,
      ),
      'too-many-requests' => const AccountException(
        'Terlalu banyak percobaan. Tunggu beberapa menit lalu coba lagi.',
      ),
      'user-disabled' => const AccountException(
        'Akun ini dinonaktifkan oleh administrator sekolah.',
      ),
      'network-request-failed' => const AccountException(
        'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
      ),
      _ => AccountException('Terjadi kesalahan (${error.code}). Coba lagi.'),
    };
  }
}
