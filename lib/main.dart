import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test_flutter_project/screens/app/index.dart';

import 'package:test_flutter_project/screens/splash.dart';
import 'package:test_flutter_project/screens/login.dart';
import 'package:test_flutter_project/supabase/auth.dart';
import 'package:test_flutter_project/features/sharing.dart';
import 'color_schemes.g.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  initAuth();

  runApp(AuthProvider(
      child: MaterialApp(
    theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
    initialRoute: '/',
    routes: <String, WidgetBuilder>{
      '/': (_) => const SharingIntent(
            child: SplashPage(),
          ),
      '/login': (_) => const SharingIntent(child: LoginPage()),
      '/home': (_) => const SharingIntent(child: MainApp()),
    },
  )));
}
