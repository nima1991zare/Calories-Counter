import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'src/screens/home.dart';
import 'src/screens/onboarding.dart';
import 'src/state/app_state.dart';
import 'src/state/diary_state.dart';
import 'src/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // On desktop platforms sqflite needs the FFI (SQLite DLL) implementation.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const CalCounterApp());
}

class CalCounterApp extends StatelessWidget {
  const CalCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..load()),
        ChangeNotifierProvider(create: (_) => DiaryState()..init()),
      ],
      child: MaterialApp(
        title: 'CalCounter',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const _RootGate(),
      ),
    );
  }
}

/// Shows onboarding until the profile is set up, then the main app.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.loaded) {
      return const Scaffold(
        body: Center(
          child: Icon(Icons.local_fire_department,
              color: AppColors.primary, size: 64),
        ),
      );
    }
    return app.onboarded ? const HomeScreen() : const OnboardingScreen();
  }
}
