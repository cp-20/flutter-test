import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_flutter_project/screens/splash.dart';
import 'package:test_flutter_project/screens/login.dart';
import 'package:test_flutter_project/screens/home.dart';
import 'package:test_flutter_project/supabase/auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initAuth();

  runApp(ProviderScope(
      child: MaterialApp(
    initialRoute: '/',
    routes: <String, WidgetBuilder>{
      '/': (_) => const SplashPage(),
      '/login': (_) => const LoginPage(),
      '/home': (_) => const HomePage(),
    },
  )));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;

  @override
  void initState() {
    super.initState();

    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> value) {
      setState(() {
        list = value;
      });
      print("Shared: getMedia Stream ${value.map((f) => f.value).join(",")}");
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> value) {
      print("Shared: getInitialMedia ${value.map((f) => f.value).join(",")}");
      setState(() {
        list = value;
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Center(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Sharing data: \n${list?.join("\n\n")}\n')),
        ),
      ],
    ));
  }
}
