import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:nil/nil.dart';
import 'package:test_flutter_project/gateways/post_article.dart';

class SharingIntent extends StatefulWidget {
  const SharingIntent({super.key, required this.child});

  final Widget? child;

  @override
  createState() => _SharingIntentState();
}

class _SharingIntentState extends State<SharingIntent> {
  late StreamSubscription _intentDataStreamSubscription;
  String? lastLink;

  addLinksToStack(List<SharedFile> links) {
    if (links.isEmpty) return;
    final link = links[0].value;
    if (link == null) return;
    if (!link.startsWith('http://') && !link.startsWith('https://')) return;

    if (link == lastLink) return;
    lastLink = link;

    final future = postArticle(context, link);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("記事の登録"),
            content: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 64,
                    height: 64,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Text("記事の登録中にエラーが発生しました");
                } else {
                  final clip = snapshot.data;
                  final article = snapshot.data?.article;
                  if (clip == null || article == null) {
                    return const Text("記事の登録中にエラーが発生しました");
                  }
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: article.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        const TextSpan(
                          text: 'を追加しました',
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            actions: [
              TextButton(
                child: const Text("閉じる"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _intentDataStreamSubscription = FlutterSharingIntent.instance
          .getMediaStream()
          .listen((List<SharedFile> links) {
        addLinksToStack(links);
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });

      FlutterSharingIntent.instance
          .getInitialSharing()
          .then((List<SharedFile> links) {
        addLinksToStack(links);
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? nil;
  }
}
