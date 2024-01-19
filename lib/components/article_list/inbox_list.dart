import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/article_list/article_list.dart';
import 'package:test_flutter_project/gateways/get_my_inbox_items.dart';
import 'package:test_flutter_project/gateways/move_inbox_item_to_stack.dart';
import 'package:test_flutter_project/models/article.dart';
import 'package:test_flutter_project/models/inbox_item.dart';

import 'common.dart';

class ArticleWithInboxItem extends Article {
  ArticleWithInboxItem(
      {required super.id,
      required super.title,
      required super.body,
      required super.ogImageUrl,
      required super.url,
      required super.createdAt,
      required super.updatedAt,
      required this.item});

  final InboxItem item;

  @override
  bool operator ==(Object other) {
    return other is ArticleWithInboxItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class InboxList extends StatefulWidget {
  const InboxList({super.key});

  @override
  createState() => _InboxListState();
}

class _InboxListState extends State<InboxList>
    with SingleTickerProviderStateMixin {
  List<ArticleWithInboxItem> articles = [];
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
    final (items, finished) = await getMyInboxItems(context, loadLimit, before);

    if (items == null) {
      return;
    }

    final newArticles = items.map((item) => ArticleWithInboxItem(
          id: item.article.id,
          title: item.article.title,
          body: item.article.body,
          ogImageUrl: item.article.ogImageUrl,
          url: item.article.url,
          createdAt: item.article.createdAt,
          updatedAt: item.article.updatedAt,
          item: item,
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
              child: Text('まだ何もありません', textAlign: TextAlign.center),
            ),
            onDismissed: (direction, article, remove, restore) {
              final item = article.item;

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

              moveToStack(context, item.id).then((newClip) {
                if (newClip == null) {
                  restoreArticle();
                  return;
                }
                notifySnackBar(context, '記事をスタックに移しました', () {
                  restoreArticle();
                  moveToStack(context, newClip.id);
                }, animation);
              });
            },
            dismissDirection: DismissDirection.startToEnd,
            dismissBackground: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Icon(
                  Icons.drive_file_move,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
