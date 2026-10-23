import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/storage/local_database.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProjectNexusApp(database: await _openDatabase()));
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

class ProjectNexusApp extends StatelessWidget {
  const ProjectNexusApp({this.database, super.key});

  final LocalDatabase? database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectNexus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(database: database),
    );
  }
}
