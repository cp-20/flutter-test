import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/sliver_animated_list_view.dart';
import 'package:test_flutter_project/components/infinity_list_view.dart';
import 'package:test_flutter_project/models/article.dart';

import 'article_list_item.dart';

class ArticleList<T extends Article> extends StatefulWidget {
  const ArticleList(
      {super.key,
      required this.articles,
      required this.loadMore,
      required this.hasMore,
      required this.reload,
      required this.onDismissed,
      required this.dismissDirection,
      this.dismissBackground,
      this.secondaryDismissBackground,
      required this.noContentWidget});

  final List<T> articles;
  final Future<void> Function() loadMore;
  final Future<void> Function() reload;
  final bool hasMore;
  final void Function(DismissDirection direction, T article,
      int Function() remove, int Function() restore) onDismissed;
  final DismissDirection dismissDirection;
  final Widget? dismissBackground;
  final Widget? secondaryDismissBackground;
  final Widget noContentWidget;

  @override
  createState() => _ArticleListState<T>();
}

class _ArticleListState<T extends Article> extends State<ArticleList<T>> {
  @override
  void initState() {
    super.initState();
  }

  Widget itemBuilder(BuildContext context, T article,
      Animation<double> animation, isRemoved, insert, remove) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: animation,
          child: Dismissible(
            key: Key(article.id.toString()),
            background: widget.dismissBackground,
            secondaryBackground: widget.secondaryDismissBackground,
            onDismissed: (direction) {
              final targetIndex =
                  widget.articles.indexWhere((a) => a.id == article.id);

              removeArticle() {
                // remove(targetIndex);
                setState(() {
                  widget.articles.removeAt(targetIndex);
                });
                return targetIndex;
              }

              restoreArticle() {
                insert(targetIndex, article);
                setState(() {
                  widget.articles.insert(targetIndex, article);
                });
                return targetIndex;
              }

              widget.onDismissed(
                  direction, article, removeArticle, restoreArticle);
            },
            direction: widget.dismissDirection,
            child: ArticleListItem(
              article: article,
            ),
          ),
        ),
        Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.reload,
      child: InfinityListView<T>(
        contents: widget.articles,
        hasMore: widget.hasMore,
        fetchContents: widget.loadMore,
        itemListBuilder: (context, scrollController, articles) {
          if (articles.isEmpty) {
            return widget.noContentWidget;
          }

          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAnimatedListView(items: articles, itemBuilder: itemBuilder),
              if (widget.hasMore)
                const SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ))
            ],
          );
        },
      ),
    );
  }
}
