import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter_project/supabase/auth.dart';

String? getCookie(BuildContext context) {
  final auth = Provider.of<SupabaseAuthState>(context, listen: false);
  final user = auth.state.currentUser;
  final session = auth.state.currentSession;
  final authCookieName = dotenv.env['AUTH_COOKIE_NAME'];
  if (user == null || session == null || authCookieName == null) {
    return null;
  }

  final tokenArray = [
    session.accessToken,
    session.refreshToken,
    session.providerToken,
    session.providerRefreshToken,
    null
  ];
  final tokenCookieValue = Uri.encodeComponent(json.encode(tokenArray));

  final cookie = '$authCookieName=$tokenCookieValue';

  return cookie;
}

String? getUserId(BuildContext context) {
  final auth = Provider.of<SupabaseAuthState>(context, listen: false);
  final user = auth.state.currentUser;
  final userId = user?.id;
  return userId;
}
