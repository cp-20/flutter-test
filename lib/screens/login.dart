import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'package:test_flutter_project/supabase/auth.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(userProvider);

    useEffect(() {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }, [user]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text(user?.email ?? 'ログインしていません'),
          Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ElevatedButton(
              child: const Text('ログイン'),
              onPressed: () {
                signIn();
              },
            ),
          )
        ]),
      ),
    );
  }
}
