import 'dart:convert';

import 'package:crypto/crypto.dart';

class StudentDemoAccount {
  const StudentDemoAccount({
    required this.fullName,
    required this.nim,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  /// Membuat akun baru dari form registrasi. Kata sandi langsung di-hash
  /// sehingga teks aslinya tidak pernah disimpan.
  factory StudentDemoAccount.register({
    required String fullName,
    required String nim,
    required String username,
    required String email,
    required String password,
  }) {
    return StudentDemoAccount(
      fullName: fullName,
      nim: nim,
      username: username,
      email: email,
      passwordHash: hashPassword(nim, password),
    );
  }

  final String fullName;
  final String nim;
  final String username;
  final String email;
  final String passwordHash;

  /// SHA-256 dari kata sandi dengan NIM sebagai salt, agar dua akun dengan
  /// kata sandi yang sama tetap menghasilkan hash berbeda.
  static String hashPassword(String nim, String password) => sha256
      .convert(
        utf8.encode('projectnexus:${nim.trim().toLowerCase()}:$password'),
      )
      .toString();

  bool verifyPassword(String password) =>
      hashPassword(nim, password) == passwordHash;

  bool matchesIdentifier(String identifier) {
    final normalized = identifier.trim().toLowerCase();
    return nim.toLowerCase() == normalized ||
        username.toLowerCase() == normalized ||
        email.toLowerCase() == normalized;
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'nim': nim,
    'username': username,
    'email': email,
    'passwordHash': passwordHash,
  };

  /// Membaca akun dari database; `null` bila datanya tidak lengkap atau rusak.
  static StudentDemoAccount? tryFromJson(Map<String, dynamic> json) {
    try {
      return StudentDemoAccount(
        fullName: json['fullName'] as String,
        nim: json['nim'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
      );
    } on TypeError {
      return null;
    }
  }
}
