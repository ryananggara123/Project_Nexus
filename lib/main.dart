import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/cloud/cloud_store.dart';
import 'core/cloud/firestore_cloud_store.dart';
import 'core/storage/local_database.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/account_service.dart';
import 'features/auth/data/cloud_account_service.dart';
import 'features/auth/data/firebase_auth_backend.dart';
import 'features/auth/screens/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await _openDatabase();
  final firebase = await _connectFirebase();
  runApp(
    ProjectNexusApp(
      database: database,
      cloud: firebase?.cloud,
      accounts: firebase?.accounts,
    ),
  );
}

/// Membuka database lokal. Bila gagal (misalnya penyimpanan browser diblokir),
/// aplikasi tetap berjalan dengan data di memori.
Future<LocalDatabase?> _openDatabase() async {
  try {
    await Hive.initFlutter();
    return await LocalDatabase.openHive();
  } on Object catch (error) {
    debugPrint('Database lokal tidak dapat dibuka: $error');
    return null;
  }
}

/// Menghubungkan ke Firebase. Bila platform belum dikonfigurasi (misalnya
/// Windows desktop), aplikasi tetap berjalan dengan akun dan data lokal.
Future<({CloudStore cloud, AccountService accounts})?>
_connectFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final cloud = FirestoreCloudStore(FirebaseFirestore.instance);
    return (
      cloud: cloud,
      accounts: CloudAccountService(
        auth: FirebaseAuthBackend(FirebaseAuth.instance),
        cloud: cloud,
      ),
    );
  } on Object catch (error) {
    debugPrint('Firebase tidak tersedia, memakai mode lokal: $error');
    return null;
  }
}

class ProjectNexusApp extends StatelessWidget {
  const ProjectNexusApp({this.database, this.cloud, this.accounts, super.key});

  final LocalDatabase? database;
  final CloudStore? cloud;
  final AccountService? accounts;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectNexus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(database: database, cloud: cloud, accounts: accounts),
    );
  }
}
