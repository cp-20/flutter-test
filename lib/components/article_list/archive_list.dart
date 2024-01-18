import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/article_list/article_list.dart';
import 'package:test_flutter_project/gateways/get_my_clips.dart';
import 'package:test_flutter_project/gateways/patch_clip.dart';

import 'common.dart';
import 'stack_list.dart';

class ArchiveList extends StatefulWidget {
  const ArchiveList({super.key});

  @override
  createState() => _ArchiveListState();
}

class _ArchiveListState extends State<ArchiveList>
    with SingleTickerProviderStateMixin {
  List<ArticleWithClip> articles = [];
  bool hasMore = true;
  late final AnimationController animation;
  late Future<void> future;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
    );
    future = loadMore();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  Future<void> loadMore([bool? replace]) async {
    final before = articles.isNotEmpty && (replace != true)
        ? articles.last.updatedAt
        : null;
    final (clips, finished) =
        await getMyClips(context, loadLimit, before, 'read');

    if (clips == null) {
      return;
    }

    final newArticles = clips.map((c) => ArticleWithClip(
          id: c.article.id,
          title: c.article.title,
          body: c.article.body,
          ogImageUrl: c.article.ogImageUrl,
          url: c.article.url,
          createdAt: c.article.createdAt,
          updatedAt: c.article.updatedAt,
          clip: c,
        ));

    if (replace == true) {
      setState(() {
        articles = newArticles.toList();
      });
    } else {
      setState(() {
        articles.addAll(newArticles);
      });
    }

    if (finished) {
      setState(() {
        hasMore = false;
      });
    }
  }

  Future<void> reload() async {
    setState(() {
      hasMore = true;
      loadMore(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            ],
          );
        } else if (snapshot.hasError) {
          return const Text("記事の取得中にエラーが発生しました");
        } else {
          return ArticleList(
            articles: articles,
            loadMore: loadMore,
            hasMore: hasMore,
            reload: reload,
            noContentWidget: const Center(
              child: Text('まだ何もありません', textAlign: TextAlign.center),
            ),
            onDismissed: (direction, article, remove, restore) {
              final clip = article.clip;

              final targetIndex = remove();
              setState(() {
                articles.removeAt(targetIndex);
              });

              restoreArticle() {
                restore();
                setState(() {
                  articles.insert(targetIndex, article);
                });
              }

              updateClip(context, clip.id, const ClipPatch(status: 0))
                  .then((newClip) {
                if (newClip == null) {
                  restoreArticle();
                  return;
                }
                notifySnackBar(context, '記事を未読にしました', () {
                  restoreArticle();
                  updateClip(context, clip.id, ClipPatch(status: clip.status));
                }, animation);
              });
            },
            dismissDirection: DismissDirection.endToStart,
            dismissBackground: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Icon(
                  Icons.markunread,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 32,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
