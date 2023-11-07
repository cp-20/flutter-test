import 'package:test_flutter_project/gateways/const.dart';
import 'package:test_flutter_project/models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<User?> getMe() async {
  final url = Uri.parse("$apiEndpoint/users/me");
  final response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  return User.fromJson(json.decode(response.body));
}
