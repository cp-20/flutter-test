import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

final supabase = Supabase.instance.client;

Future<void> initAuth() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

class SupabaseAuthState extends ChangeNotifier {
  SupabaseAuthState(this.state);

  GoTrueClient state;

  void setState(GoTrueClient newAuthState) {
    state = newAuthState;
    notifyListeners();
  }
}

class AuthProvider extends StatefulWidget {
  const AuthProvider({super.key, required this.child});

  final Widget child;

  @override
  createState() => _AuthProviderState();
}

class _AuthProviderState extends State<AuthProvider> {
  SupabaseAuthState state = SupabaseAuthState(supabase.auth);

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((event) {
      state.setState(supabase.auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SupabaseAuthState>.value(
      value: state,
      child: widget.child,
    );
  }
}

Future<void> signInWithGitHub() async {
  try {
    await supabase.auth.signInWithOAuth(OAuthProvider.github,
        redirectTo: 'read-stack://login-callback');
  } on AuthException {
    // ...
  } on Exception {
    // ..
  }
}

Future<void> signInWithGoogle() async {
  try {
    await supabase.auth.signInWithOAuth(OAuthProvider.google,
        redirectTo: 'read-stack://login-callback');
  } on AuthException {
    // ...
  } on Exception {
    // ..
  }
}

Future<void> signOut() async {
  try {
    await supabase.auth.signOut();
  } on AuthException {
    // ...
  } on Exception {
    // ...
  }
}
