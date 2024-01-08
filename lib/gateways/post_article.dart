import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/clip.dart';

Future<Clip?> postArticle(BuildContext context, String articleUrl) async {
  final header = getAuthHeader(context);
  if (header == null) {
    return null;
  }

  final url = Uri.parse("$apiEndpoint/users/me/clips");

  final response = await http.post(
    url,
    body: json.encode({'type': 'url', 'articleUrl': articleUrl}),
    headers: {'Content-Type': 'application/json', ...header},
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    return null;
  }

  return Clip.fromJson(json.decode(response.body)['clip']);
}
