import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter_project/supabase/auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<SupabaseAuthState>(context).state.currentUser;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('ログアウト'),
          subtitle:
              Text(user?.email != null ? '現在${user?.email}としてログインしています' : ''),
          onTap: () {
            signOut();
          },
        ),
      ],
    );
  }
}
