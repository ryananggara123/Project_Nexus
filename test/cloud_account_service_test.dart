import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/features/auth/data/account_service.dart';
import 'package:project_nexus/features/auth/data/cloud_account_service.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';

import 'support/memory_auth_backend.dart';

const StudentRegistration _ryan = (
  fullName: 'Ryan Anggara Deki',
  nim: '2413025074',
  username: 'RyanAnggara',
  email: 'Ryan@school.id',
  password: 'password123',
);

void main() {
  late MemoryCloudStore cloud;
  late MemoryAuthBackend auth;
  late CloudAccountService accounts;

  setUp(() {
    cloud = MemoryCloudStore();
    auth = MemoryAuthBackend();
    accounts = CloudAccountService(auth: auth, cloud: cloud);
  });

  Future<UserAccount> signIn(String identifier, {UserRole? role}) =>
      accounts.signIn(
        role: role ?? UserRole.student,
        identifier: identifier,
        password: 'password123',
      );

  test('registration stores the profile and login IDs on the server', () async {
    await accounts.register(_ryan);

    final users = cloud.documents(CloudAccountService.usersCollection);
    expect(users, hasLength(1));
    expect(users.single, {
      'fullName': 'Ryan Anggara Deki',
      'role': 'student',
      'email': 'ryan@school.id',
      'nim': '2413025074',
      'username': 'RyanAnggara',
    });
    // Kata sandi tidak pernah disimpan di Firestore.
    expect(users.single.values, isNot(contains('password123')));
    expect(
      await cloud.get(CloudAccountService.loginIdsCollection, '2413025074'),
      containsPair('email', 'ryan@school.id'),
    );
    expect(
      await cloud.get(CloudAccountService.loginIdsCollection, 'ryananggara'),
      containsPair('email', 'ryan@school.id'),
    );
    // Setelah mendaftar, siswa diminta masuk sendiri.
    expect(await auth.currentUserId(), isNull);
  });

  test('student signs in with NIM, username, or email', () async {
    await accounts.register(_ryan);

    for (final identifier in ['2413025074', 'ryananggara', 'RYAN@school.id']) {
      final account = await signIn(identifier);
      expect(account.name, 'Ryan Anggara Deki');
      expect(account.role, UserRole.student);
      expect(account.nim, '2413025074');
      await accounts.signOut();
    }
  });

  test('wrong password and unknown accounts give clear messages', () async {
    await accounts.register(_ryan);

    await expectLater(
      accounts.signIn(
        role: UserRole.student,
        identifier: '2413025074',
        password: 'salah123',
      ),
      throwsA(
        isA<AccountException>()
            .having((e) => e.message, 'message', 'Kata sandi tidak sesuai.')
            .having((e) => e.field, 'field', AccountField.password),
      ),
    );
    await expectLater(
      signIn('9999999999'),
      throwsA(
        isA<AccountException>().having(
          (e) => e.message,
          'message',
          'Akun siswa tidak ditemukan. Periksa data masuk.',
        ),
      ),
    );
    await expectLater(
      signIn('orang.lain@school.id'),
      throwsA(
        isA<AccountException>().having(
          (e) => e.message,
          'message',
          'Email atau kata sandi tidak sesuai.',
        ),
      ),
    );
  });

  test('NIM, username, and email can only be registered once', () async {
    await accounts.register(_ryan);

    Future<void> registerAgain({
      String nim = '1111111111',
      String username = 'akunbaru',
      String email = 'baru@school.id',
    }) => accounts.register((
      fullName: 'Akun Baru',
      nim: nim,
      username: username,
      email: email,
      password: 'password123',
    ));

    Matcher rejected(String message, AccountField field) => throwsA(
      isA<AccountException>()
          .having((e) => e.message, 'message', message)
          .having((e) => e.field, 'field', field),
    );

    await expectLater(
      registerAgain(nim: '2413025074'),
      rejected('NIM sudah terdaftar.', AccountField.nim),
    );
    await expectLater(
      registerAgain(username: 'ryanANGGARA'),
      rejected('Username sudah digunakan.', AccountField.username),
    );
    await expectLater(
      registerAgain(email: 'ryan@school.id'),
      rejected('Email sudah terdaftar.', AccountField.email),
    );
    expect(cloud.documents(CloudAccountService.usersCollection), hasLength(1));
  });

  test('teachers and students must use their own tab', () async {
    await accounts.register(_ryan);
    await auth.addTeacher(
      cloud,
      name: 'Budi Santoso',
      email: 'budi.santoso@school.id',
      password: 'password123',
    );

    final teacher = await signIn(
      'budi.santoso@school.id',
      role: UserRole.teacher,
    );
    expect(teacher.name, 'Budi Santoso');
    expect(teacher.role, UserRole.teacher);
    await accounts.signOut();

    await expectLater(
      signIn('budi.santoso@school.id'),
      throwsA(isA<AccountException>()),
    );
    await expectLater(
      signIn('ryan@school.id', role: UserRole.teacher),
      throwsA(
        isA<AccountException>().having(
          (e) => e.message,
          'message',
          'Akun ini bukan akun guru pendamping.',
        ),
      ),
    );
    // Login yang ditolak tidak meninggalkan sesi.
    expect(await auth.currentUserId(), isNull);
  });

  test('session is restored until the user signs out', () async {
    await accounts.register(_ryan);
    expect(await accounts.restoreSession(), isNull);

    await signIn('ryananggara');
    final restored = await accounts.restoreSession();
    expect(restored?.name, 'Ryan Anggara Deki');
    expect(restored?.email, 'ryan@school.id');

    await accounts.signOut();
    expect(await accounts.restoreSession(), isNull);
  });

  test('server errors become a connection message', () async {
    final offline = CloudAccountService(auth: auth, cloud: _OfflineCloud());
    await expectLater(
      offline.signIn(
        role: UserRole.student,
        identifier: '2413025074',
        password: 'password123',
      ),
      throwsA(
        isA<AccountException>().having(
          (e) => e.message,
          'message',
          contains('Tidak dapat terhubung ke server'),
        ),
      ),
    );
  });
}

class _OfflineCloud extends MemoryCloudStore {
  @override
  Future<Map<String, dynamic>?> get(String collection, String id) =>
      Future.error(StateError('unavailable'));
}
