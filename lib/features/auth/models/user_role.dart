enum UserRole { student, teacher }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.student => 'Siswa',
    UserRole.teacher => 'Guru Pendamping',
  };
}
