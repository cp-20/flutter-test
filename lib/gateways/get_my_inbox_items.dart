import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/inbox_item.dart';

Future<(List<InboxItemWithArticle>?, bool)> getMyInboxItems(
    BuildContext context, int loadLimit, DateTime? before) async {
  final header = getAuthHeader(context);

  if (header == null) {
    return (null, false);
  }

  final url = (() {
    var baseUrl = "$apiEndpoint/users/me/inboxes?limit=$loadLimit";
    if (before != null) {
      baseUrl += "&before=${Uri.encodeComponent(before.toIso8601String())}";
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

  final rawItems = body['items'] as List<dynamic>;
  final items = rawItems.map((e) => InboxItemWithArticle.fromJson(e)).toList();

  return (items, finished);
}
