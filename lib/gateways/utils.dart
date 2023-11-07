import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter_project/supabase/auth.dart';

String? getCookie(BuildContext context) {
  final auth = Provider.of<SupabaseAuthState>(context, listen: false);
  final user = auth.state.currentUser;
  final session = auth.state.currentSession;
  final appId = dotenv.env['SUPABASE_APP_ID'];
  if (user == null || session == null || appId == null) {
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

  final cookie = 'sb-$appId-auth-token=$tokenCookieValue';

  return cookie;
}

String? getUserId(BuildContext context) {
  final auth = Provider.of<SupabaseAuthState>(context, listen: false);
  final user = auth.state.currentUser;
  final userId = user?.id;
  return userId;
}
