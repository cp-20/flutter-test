import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/inbox_item.dart';

Future<InboxItem?> moveToInbox(BuildContext context, int clipId) async {
  final header = getAuthHeader(context);
  if (header == null) {
    return null;
  }

  final url = Uri.parse("$apiEndpoint/users/me/clips/$clipId/move-to-inbox");

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      ...header,
    },
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    return null;
  }

  return InboxItem.fromJson(json.decode(response.body)['item']);
}
