import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/article_list/article_list.dart';
import 'package:test_flutter_project/gateways/get_my_clips.dart';
import 'package:test_flutter_project/gateways/move_clip_to_inbox.dart';
import 'package:test_flutter_project/gateways/move_inbox_item_to_stack.dart';
import 'package:test_flutter_project/gateways/patch_clip.dart';
import 'package:test_flutter_project/models/article.dart';
import 'package:test_flutter_project/models/clip.dart';

import 'common.dart';

class ArticleWithClip extends Article {
  ArticleWithClip(
      {required super.id,
      required super.title,
      required super.body,
      required super.ogImageUrl,
      required super.url,
      required super.createdAt,
      required super.updatedAt,
      required this.clip});

  final ClipWithArticle clip;

  @override
  bool operator ==(Object other) {
    return other is ArticleWithClip && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class StackList extends StatefulWidget {
  const StackList({super.key});

  @override
  createState() => _StackListState();
}

class _StackListState extends State<StackList>
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
        await getMyClips(context, loadLimit, before, 'unread');

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
        articles.addAll(newArticles.toList());
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
              ),
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
              child: Text('まだ何もありません\n右下のボタンから記事を追加できます',
                  textAlign: TextAlign.center),
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

              if (direction == DismissDirection.startToEnd) {
                updateClip(context, clip.id, const ClipPatch(status: 2))
                    .then((newClip) {
                  if (newClip == null) {
                    restoreArticle();
                    return;
                  }
                  notifySnackBar(context, '記事を既読にしました', () {
                    restoreArticle();
                    updateClip(
                        context, clip.id, ClipPatch(status: clip.status));
                  }, animation);
                });
              } else if (direction == DismissDirection.endToStart) {
                moveToInbox(context, clip.id).then((newItem) {
                  if (newItem == null) {
                    restoreArticle();
                    return;
                  }
                  notifySnackBar(context, '記事を受信箱に戻しました', () {
                    restoreArticle();
                    moveToStack(context, newItem.id);
                  }, animation);
                });
              }
            },
            dismissDirection: DismissDirection.startToEnd,
            dismissBackground: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Icon(
                  Icons.mark_email_read,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 32,
                ),
              ),
            ),
            secondaryDismissBackground: Container(
              color: Theme.of(context).colorScheme.secondary,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Icon(
                  Icons.move_to_inbox,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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
