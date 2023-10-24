import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;
  String? catchLink;
  String? parameter;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) {
      //さっき設定したスキームをキャッチしてここが走る。
      catchLink = link;
      parameter = getQueryParameter(link);
      setState(() {});
    }, onError: (err) {
      print(err);
    });
  }

  String? getQueryParameter(String? link) {
    if (link == null) return null;
    final uri = Uri.parse(link);
    //flutterUniversity://user/?name=matsumaruのmatsumaru部分を取得
    String? name = uri.queryParameters['name'];
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'リンク：$catchLink',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'パラメーター：$parameter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}