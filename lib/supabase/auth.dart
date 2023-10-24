import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const supabaseUrl = 'https://qpzeybucecxdukidxczn.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwemV5YnVjZWN4ZHVraWR4Y3puIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg0NjI0MzcsImV4cCI6MjAwNDAzODQzN30.xwJ_1UU18kKH6wqHdqpIoTlsnTGkC_y7liiLMIfTZ8s';

final supabase = supabase_flutter.Supabase.instance.client;

final userProvider = StateProvider((ref) => supabase.auth.currentUser);
final sessionProvider = StateProvider((ref) => supabase.auth.currentSession);

Future<void> initAuth() async {
  await supabase_flutter.Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: supabase_flutter.AuthFlowType.pkce);

  StateProvider((ref) {
    supabase.auth.onAuthStateChange.listen((event) {
      ref.read(userProvider.notifier).state = supabase.auth.currentUser;
      ref.read(sessionProvider.notifier).state = supabase.auth.currentSession;
    });
  });
}

Future<void> signIn() async {
  try {
    await supabase.auth.signInWithOAuth(supabase_flutter.Provider.github,
        redirectTo: 'read-stack://login-callback');
  } on supabase_flutter.AuthException catch (error) {
    // ...
  } on Exception catch (error) {
    // ..
  }
}

Future<void> logout() async {
  try {
    await supabase.auth.signOut();
  } on supabase_flutter.AuthException catch (error) {
    // ...
  } on Exception catch (error) {
    // ...
  }
}
