import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

const redirectTo = 'read-stack://login-callback';

Future<void> signInWithGitHub() async {
  try {
    await supabase.auth.signInWithOAuth(OAuthProvider.github,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.inAppBrowserView);
  } on AuthException {
    // ...
  } on Exception {
    // ..
  }
}

Future<void> signInWithGoogle() async {
  try {
    await supabase.auth.signInWithOAuth(OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.inAppBrowserView);
  } on AuthException {
    // ...
  } on Exception {
    // ..
  }
}

Future<AuthResponse> signInWithApple() async {
  final rawNonce = supabase.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw const AuthException(
        'Could not find ID Token from generated credential.');
  }

  return supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );
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
