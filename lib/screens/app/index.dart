import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:test_flutter_project/supabase/auth.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:test_flutter_project/components/add_clip_button.dart';
import 'home.dart';
import 'settings.dart';

class MainApp extends StatefulHookWidget {
  const MainApp({super.key});

  @override
  createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final User? user =
        Provider.of<SupabaseAuthState>(context).state.currentUser;

    useEffect(() {
      if (user == null) {
        Future.microtask(
            () => Navigator.of(context).pushReplacementNamed('/login'));
      }
    }, [user]);

    return Scaffold(
        body: [const HomePage(), const SettingsPage()][currentPageIndex],
        floatingActionButton: const AddClipButton(),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmarks_rounded),
              icon: Icon(Icons.bookmarks_outlined),
              label: 'スタック',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ));
  }
}
