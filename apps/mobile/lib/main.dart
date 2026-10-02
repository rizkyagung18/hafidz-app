import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/app.dart';
import 'package:hafidz_app/core/database/local_databases.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final databases = await openLocalDatabases();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localDatabasesProvider.overrideWithValue(databases),
      ],
      child: const HafidzApp(),
    ),
  );
}
