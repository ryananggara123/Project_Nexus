class StudentDemoAccount {
  const StudentDemoAccount({
    required this.fullName,
    required this.nim,
    required this.username,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String nim;
  final String username;
  final String email;
  final String password;

  bool matchesIdentifier(String identifier) {
    final normalized = identifier.trim().toLowerCase();
    return nim.toLowerCase() == normalized ||
        username.toLowerCase() == normalized ||
        email.toLowerCase() == normalized;
  }
}
