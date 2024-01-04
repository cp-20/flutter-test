import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/clip.dart';

class Clips {
  final List<Clip> clips;

  Clips({required this.clips});

  factory Clips.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['clips'];
    final clips = list.map((e) => Clip.fromJson(e)).toList();
    return Clips(clips: clips);
  }
}

Future<Clips?> getMyClips(BuildContext context, int loadLimit, int? cursor,
    [bool? unreadOnly]) async {
  final cookie = getCookie(context);

  if (cookie == null) {
    return null;
  }

  final url = (() {
    var baseUrl = "$apiEndpoint/users/me/clips?limit=$loadLimit";
    if (cursor != null) baseUrl += "&cursor=$cursor";
    if (unreadOnly != null) {
      baseUrl += "&unreadOnly=$unreadOnly";
    }
    return baseUrl;
  })();
  final uri = Uri.parse(url);

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Cookie': cookie,
    },
  );

  if (response.statusCode != 200) {
    return null;
  }

  return Clips.fromJson(json.decode(response.body));
}
