import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/gateways/utils.dart';
import 'package:test_flutter_project/models/clip.dart';
import 'package:test_flutter_project/models/article.dart';

class ArticleAndClip {
  const ArticleAndClip({required this.article, required this.clip});

  final Article article;
  final Clip clip;

  factory ArticleAndClip.fromJson(Map<String, dynamic> json) {
    final article = Article.fromJson(json['article']);
    final clip = Clip.fromJson(json['clip']);
    return ArticleAndClip(article: article, clip: clip);
  }
}

Future<ArticleAndClip?> postArticle(
    BuildContext context, String articleUrl) async {
  final cookie = getCookie(context);
  final userId = getUserId(context);
  if (cookie == null || userId == null) {
    return null;
  }

  final url = Uri.parse("$apiEndpoint/users/$userId/clips");

  final response = await http.post(
    url,
    body: {'type': 'url', 'articleUrl': articleUrl},
    headers: {
      'Cookie': cookie,
    },
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    return null;
  }

  return ArticleAndClip.fromJson(json.decode(response.body));
}
