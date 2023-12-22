import 'package:flutter/material.dart';

class InfinityListView<T> extends StatefulWidget {
  final List<T> contents;
  final Future<bool> Function() fetchContents;
  final Widget Function(BuildContext, ScrollController, List<T>, bool)
      itemListBuilder;

  const InfinityListView({
    super.key,
    required this.contents,
    required this.fetchContents,
    required this.itemListBuilder,
  });

  @override
  State<InfinityListView<T>> createState() => _InfinityListViewState<T>();
}

class _InfinityListViewState<T> extends State<InfinityListView<T>> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (!_hasMore) return;
      if (_isLoading) return;

      final position = _scrollController.position.pixels;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (position < maxScrollExtent * 0.95) return;

      _isLoading = true;

      final hasMore = await widget.fetchContents();

      setState(() {
        _isLoading = false;
        _hasMore = hasMore;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.itemListBuilder(
        context, _scrollController, widget.contents, _hasMore);
  }
}
