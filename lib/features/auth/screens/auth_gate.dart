import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import '../../competitions/models/competition_store.dart';
import '../../dashboard/models/profile_photo_store.dart';
import '../../discussion/models/team_chat_store.dart';
import '../../talent/models/talent_store.dart';
import '../../dashboard/models/project_workflow_store.dart';
import '../../dashboard/models/team_work_store.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../notifications/models/notification_store.dart';
import '../data/account_service.dart';
import '../models/user_role.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({this.database, this.cloud, this.accounts, super.key});

  /// Database lokal. Bila kosong, data hanya disimpan di memori.
  final LocalDatabase? database;

  /// Server untuk sinkronisasi realtime. Bila kosong, aplikasi berjalan lokal.
  final CloudStore? cloud;

  /// Layanan akun. Bila kosong, akun disimpan di database lokal.
  final AccountService? accounts;

  static const splashDuration = Duration(milliseconds: 1800);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserAccount? _account;
  bool _splashDone = false;
  bool _restoring = true;
  Timer? _splashTimer;
  late final AccountService _accounts =
      widget.accounts ?? LocalAccountService(database: widget.database);
  late final NotificationStore _notificationStore = NotificationStore(
    database: widget.database,
  );
  late final ProjectWorkflowStore _projectStore = ProjectWorkflowStore(
    database: widget.database,
    notifications: _notificationStore,
  );
  late final ProfilePhotoStore _photoStore = ProfilePhotoStore(
    database: widget.database,
  );
  late final CompetitionStore _competitionStore = CompetitionStore(
    database: widget.database,
  );
  late final TeamWorkStore _teamStore = TeamWorkStore(
    database: widget.database,
  );
  late final TalentStore _talentStore = TalentStore(database: widget.database);
  late final TeamChatStore _chatStore = TeamChatStore(
    database: widget.database,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_restoreSession());
    _splashTimer = Timer(AuthGate.splashDuration, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _projectStore.dispose();
    _teamStore.dispose();
    _photoStore.dispose();
    _competitionStore.dispose();
    _talentStore.dispose();
    _chatStore.dispose();
    _notificationStore.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final account = await _accounts.restoreSession();
    if (!mounted) return;
    setState(() => _restoring = false);
    if (account != null) _enter(account);
  }

  /// Masuk ke dashboard. Pada mode cloud, data mulai disinkronkan setelah
  /// login karena aturan keamanan server hanya mengizinkan pengguna yang masuk.
  void _enter(UserAccount account) {
    final cloud = widget.cloud;
    if (cloud != null) {
      _projectStore.startSync(cloud);
      _teamStore.startSync(cloud);
      _photoStore.startSync(cloud);
      _competitionStore.startSync(cloud);
      _talentStore.startSync(cloud);
      _chatStore.startSync(cloud);
      _notificationStore.startSync(cloud, account.name);
    }
    setState(() => _account = account);
  }

  Future<void> _leave() async {
    _projectStore.stopSync();
    _teamStore.stopSync();
    _photoStore.stopSync();
    _competitionStore.stopSync();
    _talentStore.stopSync();
    _chatStore.stopSync();
    _notificationStore.stopSync();
    await _accounts.signOut();
    if (!mounted) return;
    setState(() => _account = null);
  }

  @override
  Widget build(BuildContext context) {
    // Splash tetap tampil sampai sesi sebelumnya selesai diperiksa.
    if (!_splashDone || _restoring) return const SplashScreen();

    final account = _account;
    if (account == null) {
      return LoginScreen(accounts: _accounts, onSignedIn: _enter);
    }

    final isTeacher = account.role == UserRole.teacher;
    return ProfilePhotoScope(
      store: _photoStore,
      child: DashboardScreen(
        role: account.role,
        studentName: isTeacher ? null : account.name,
        teacherName: isTeacher ? account.name : null,
        email: account.email,
        projectStore: _projectStore,
        teamStore: _teamStore,
        notificationStore: _notificationStore,
        competitionStore: _competitionStore,
        talentStore: _talentStore,
        chatStore: _chatStore,
        onLogout: _leave,
      ),
    );
  }
}
