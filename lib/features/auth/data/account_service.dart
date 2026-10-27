import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_database.dart';
import '../models/student_demo_account.dart';
import '../models/user_role.dart';

/// Akun yang sedang masuk.
class UserAccount {
  const UserAccount({
    required this.name,
    required this.role,
    required this.email,
    this.id,
    this.nim,
    this.username,
  });

  /// ID pengguna di Firebase Authentication; `null` pada mode lokal.
  final String? id;
  final String name;
  final UserRole role;
  final String email;
  final String? nim;
  final String? username;

  Map<String, dynamic> toJson() => {
    'fullName': name,
    'role': role.name,
    'email': email,
    'nim': nim,
    'username': username,
  };

  /// Membaca profil dari server; `null` bila datanya tidak lengkap.
  static UserAccount? tryFromJson(String id, Map<String, dynamic> json) {
    try {
      return UserAccount(
        id: id,
        name: json['fullName'] as String,
        role: UserRole.values.byName(json['role'] as String),
        email: json['email'] as String,
        nim: json['nim'] as String?,
        username: json['username'] as String?,
      );
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}

/// Data dari form registrasi siswa.
typedef StudentRegistration = ({
  String fullName,
  String nim,
  String username,
  String email,
  String password,
});

/// Kolom form yang menjadi penyebab kegagalan, agar pesan tampil di kolom itu.
enum AccountField { identifier, password, nim, username, email }

/// Kegagalan masuk atau mendaftar dengan pesan yang siap ditampilkan.
class AccountException implements Exception {
  const AccountException(this.message, {this.field});

  final String message;
  final AccountField? field;

  @override
  String toString() => message;
}

/// Layanan akun: masuk, mendaftar, memulihkan sesi, dan keluar.
abstract interface class AccountService {
  /// Keterangan singkat tempat akun disimpan, ditampilkan di form registrasi.
  String get storageNote;

  /// Akun dari sesi sebelumnya; `null` bila pengguna harus masuk lagi.
  Future<UserAccount?> restoreSession();

  Future<UserAccount> signIn({
    required UserRole role,
    required String identifier,
    required String password,
  });

  Future<void> register(StudentRegistration registration);

  Future<void> signOut();
}

/// Akun yang disimpan di database lokal perangkat (mode tanpa internet dan
/// pengujian). Bila belum ada akun siswa terdaftar, login demo diizinkan.
class LocalAccountService implements AccountService {
  LocalAccountService({this.database})
    : _accounts = [
        ...decodeAll(
          database?.readList(LocalDatabase.studentAccountsKey) ?? const [],
          StudentDemoAccount.tryFromJson,
        ),
      ];

  static const demoStudentName = 'Ryan Anggara Deki';
  static const _roleStorageKey = 'project_nexus_auth_role';
  static const _nameStorageKey = 'project_nexus_auth_name';
  static const _emailStorageKey = 'project_nexus_auth_email';

  final LocalDatabase? database;
  final List<StudentDemoAccount> _accounts;

  @override
  String get storageNote => 'Akun tersimpan di perangkat ini.';

  @override
  Future<UserAccount?> restoreSession() async {
    if (!kReleaseMode) return null;
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_roleStorageKey);
    final name = prefs.getString(_nameStorageKey);
    final email = prefs.getString(_emailStorageKey);
    if (roleName == null || name == null || email == null) return null;
    for (final role in UserRole.values) {
      if (role.name == roleName) {
        return UserAccount(name: name, role: role, email: email);
      }
    }
    return null;
  }

  @override
  Future<UserAccount> signIn({
    required UserRole role,
    required String identifier,
    required String password,
  }) async {
    final normalized = identifier.trim();
    final UserAccount account;
    if (role == UserRole.teacher) {
      account = UserAccount(
        name: normalized.toLowerCase() == 'siti.rahmawati@school.id'
            ? 'Siti Rahmawati'
            : 'Budi Santoso',
        role: role,
        email: normalized.toLowerCase(),
      );
    } else {
      StudentDemoAccount? student;
      for (final candidate in _accounts) {
        if (candidate.matchesIdentifier(normalized)) {
          student = candidate;
          break;
        }
      }
      if (student != null && !student.verifyPassword(password)) {
        throw const AccountException(
          'Kata sandi tidak sesuai.',
          field: AccountField.password,
        );
      }
      if (student == null && _accounts.isNotEmpty) {
        throw const AccountException(
          'Akun siswa tidak ditemukan. Periksa data masuk.',
          field: AccountField.identifier,
        );
      }
      account = UserAccount(
        name: student?.fullName ?? demoStudentName,
        role: role,
        email: student?.email ?? 'ryan@school.id',
        nim: student?.nim,
        username: student?.username,
      );
    }
    await _saveSession(account);
    return account;
  }

  @override
  Future<void> register(StudentRegistration registration) async {
    bool taken(bool Function(StudentDemoAccount account) test) =>
        _accounts.any(test);

    if (taken((account) => account.nim == registration.nim)) {
      throw const AccountException(
        'NIM sudah terdaftar.',
        field: AccountField.nim,
      );
    }
    if (taken(
      (account) =>
          account.username.toLowerCase() == registration.username.toLowerCase(),
    )) {
      throw const AccountException(
        'Username sudah digunakan.',
        field: AccountField.username,
      );
    }
    if (taken(
      (account) =>
          account.email.toLowerCase() == registration.email.toLowerCase(),
    )) {
      throw const AccountException(
        'Email sudah terdaftar.',
        field: AccountField.email,
      );
    }
    _accounts.add(
      StudentDemoAccount.register(
        fullName: registration.fullName,
        nim: registration.nim,
        username: registration.username,
        email: registration.email,
        password: registration.password,
      ),
    );
    await database?.writeList(LocalDatabase.studentAccountsKey, [
      for (final account in _accounts) account.toJson(),
    ]);
  }

  @override
  Future<void> signOut() async {
    if (!kReleaseMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleStorageKey);
    await prefs.remove(_nameStorageKey);
    await prefs.remove(_emailStorageKey);
  }

  /// Sesi hanya diingat pada build rilis agar pengujian selalu mulai dari login.
  Future<void> _saveSession(UserAccount account) async {
    if (!kReleaseMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleStorageKey, account.role.name);
    await prefs.setString(_nameStorageKey, account.name);
    await prefs.setString(_emailStorageKey, account.email);
  }
}
