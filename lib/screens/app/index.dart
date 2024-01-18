import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:test_flutter_project/screens/app/archive.dart';
import 'package:test_flutter_project/supabase/auth.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:test_flutter_project/components/add_clip_button.dart';
import 'inbox.dart';
import 'stack.dart';
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
      return null;
    }, [user]);

    return Scaffold(
        body: [
          const InboxPage(),
          const StackPage(),
          const ArchivePage(),
          const SettingsPage()
        ][currentPageIndex],
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
              selectedIcon: Icon(Icons.inbox),
              icon: Icon(Icons.inbox_outlined),
              label: '受信箱',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmarks_rounded),
              icon: Icon(Icons.bookmarks_outlined),
              label: 'スタック',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.archive),
              icon: Icon(Icons.archive_outlined),
              label: 'アーカイブ',
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
