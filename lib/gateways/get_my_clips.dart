import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/clip.dart';

Future<(List<ClipWithArticle>?, bool)> getMyClips(
    BuildContext context, int loadLimit, DateTime? before,
    [String? readStatus]) async {
  final header = getAuthHeader(context);

  if (header == null) {
    return (null, false);
  }

  final url = (() {
    var baseUrl = "$apiEndpoint/users/me/clips?limit=$loadLimit";
    if (before != null) {
      baseUrl += "&before=${Uri.encodeComponent(before.toIso8601String())}";
    }
    if (readStatus != null) {
      baseUrl += "&readStatus=$readStatus";
    }
    return baseUrl;
  })();
  final uri = Uri.parse(url);

  final response = await http.get(
    uri,
    headers: {'Content-Type': 'application/json', ...header},
  );

  if (response.statusCode != 200) {
    return (null, false);
  }

  final body = json.decode(response.body);

  final finished = body['finished'] as bool;

  final rawClips = body['clips'] as List<dynamic>;
  final clips = rawClips.map((e) => ClipWithArticle.fromJson(e)).toList();

  return (clips, finished);
}
