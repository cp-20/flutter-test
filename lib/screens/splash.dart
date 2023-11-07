import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_flutter_project/supabase/auth.dart';
import 'package:provider/provider.dart' as provider;

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user =
        provider.Provider.of<SupabaseAuthState>(context, listen: false).state.currentUser;
    Future.microtask(() {
      Navigator.of(context)
          .pushReplacementNamed(user != null ? '/home' : '/login');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
