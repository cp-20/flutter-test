import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_flutter_project/models/clip.dart' as models;
import 'package:test_flutter_project/screens/webview.dart';

class ClipListTile extends StatelessWidget {
  const ClipListTile({super.key, required this.clip});

  final models.Clip clip;

  @override
  Widget build(BuildContext context) {
    final article = clip.article;
    if (article == null) return nil;

    final imageUrl = article.ogImageUrl;
    final ogImage = imageUrl != null ? Image.network(imageUrl) : null;

    final host = Uri.parse(article.url).host;

    return TextButton(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(url: article.url, title: article.title)),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        host,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      if (ogImage != null) ogImage,
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.end,
                children: [
                  IconButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        print('star button pressed');
                      },
                      icon: const Icon(Icons.star_border)),
                  IconButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        if (clip.article == null) return;
                        Share.share(clip.article!.url, subject: clip.article!.title);
                      },
                      icon: const Icon(Icons.share)),
                  IconButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        print('more button pressed');
                      },
                      icon: const Icon(Icons.more_horiz)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
