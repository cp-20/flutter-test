import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SliverAnimatedListView<T> extends StatefulHookWidget {
  const SliverAnimatedListView(
      {super.key, required this.items, required this.itemBuilder});

  final List<T> items;
  final Widget Function(BuildContext, T, Animation<double>, bool,
      void Function(int, T), void Function(int)) itemBuilder;

  @override
  State<SliverAnimatedListView<T>> createState() =>
      _SliverAnimatedListViewState<T>();
}

class _SliverAnimatedListViewState<T> extends State<SliverAnimatedListView<T>> {
  late final _listKey = GlobalKey<SliverAnimatedListState>();
  late ListModel<T> _list;
  late final int initialItemCount;

  @override
  void initState() {
    super.initState();
    _list = ListModel<T>(
      listKey: _listKey,
      initialItems: List.from(widget.items),
      removedItemBuilder: _buildRemovedItem,
    );
    initialItemCount = widget.items.length;
  }

  void _insert(int index, T newItem) {
    _list.insert(index, newItem);
  }

  void _remove(int index) {
    _list.removeAt(index);
  }

  void _removeImmediately(int index) {
    _list._items.removeAt(index);
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return widget.itemBuilder(
        context, _list[index], animation, false, _insert, _removeImmediately);
  }

  Widget _buildRemovedItem(
      T item, BuildContext context, Animation<double> animation) {
    return widget.itemBuilder(
        context, item, animation, true, _insert, _removeImmediately);
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      for (int i = 0; i < widget.items.length; i++) {
        final item = widget.items[i];
        if (!_list._items.contains(item)) {
          _insert(i, item);
        }
      }
      for (int i = 0; i < _list.length; i++) {
        final item = _list[i];
        if (!widget.items.contains(item)) _remove(i);
      }

      return null;
    }, [widget.items]);

    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _list.length,
      itemBuilder: _buildItem,
    );
  }
}

typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  SliverAnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    listKey.currentState
        ?.insertItem(index, duration: const Duration(milliseconds: 100));
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList?.removeItem(
        index,
        duration: const Duration(milliseconds: 100),
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
