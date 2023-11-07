import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:test_flutter_project/models/clip.dart' as models;

class ClipCard extends StatelessWidget {
  const ClipCard({super.key, required this.clip});

  final models.Clip clip;

  @override
  Widget build(BuildContext context) {
    final article = clip.article;
    if (article == null) return nil;

    final imageUrl = article.ogImageUrl;
    final ogImage = imageUrl != null ? Image.network(imageUrl) : null;

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            if (ogImage != null) ogImage,
            Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.body.replaceAll('\n', ''),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )
                    ])),
          ],
        ));
  }
}
