import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/clip.dart';

class ClipPatch {
  const ClipPatch({this.status, this.progress, this.comment});

  final int? status;
  final int? progress;
  final String? comment;

  toJson() {
    Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (progress != null) data['progress'] = progress;
    if (comment != null) data['comment'] = comment;

    return data;
  }
}

Future<Clip?> updateClip(
    BuildContext context, int clipId, ClipPatch patch) async {
  final cookie = getCookie(context);
  if (cookie == null) {
    return null;
  }

  final url = Uri.parse("$apiEndpoint/users/me/clips/$clipId");

  final response = await http.patch(
    url,
    body: json.encode({'clip': patch.toJson()}),
    headers: {
      'Content-Type': 'application/json',
      'Cookie': cookie,
    },
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    return null;
  }

  return Clip.fromJson(json.decode(response.body)['clip']);
}
