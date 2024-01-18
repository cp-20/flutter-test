import 'package:flutter/material.dart';

class InfinityListView<T> extends StatefulWidget {
  const InfinityListView({
    super.key,
    required this.contents,
    required this.hasMore,
    required this.fetchContents,
    required this.itemListBuilder,
  });

  final List<T> contents;
  final bool hasMore;
  final Future<void> Function() fetchContents;
  final Widget Function(BuildContext, ScrollController, List<T>)
      itemListBuilder;

  @override
  State<InfinityListView<T>> createState() => _InfinityListViewState<T>();
}

class _InfinityListViewState<T> extends State<InfinityListView<T>> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (!widget.hasMore) return;
      if (_isLoading) return;

      final position = _scrollController.position.pixels;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (position < maxScrollExtent * 0.95) return;

      _isLoading = true;

      await widget.fetchContents();

      setState(() {
        _isLoading = false;
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
    return widget.itemListBuilder(context, _scrollController, widget.contents);
  }
}
