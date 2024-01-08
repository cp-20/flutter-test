import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter_project/gateways/post_article.dart';

class AddClipButton extends StatelessWidget {
  const AddClipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final articleUrl = data?.text;
        if (articleUrl == null) {
          return;
        }

        print(articleUrl);

        if (!context.mounted) return;
        final future = postArticle(context, articleUrl);

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
      },
      label: const Text('記事の追加'),
      icon: const Icon(Icons.add),
    );
  }
}
