import 'package:flutter/material.dart';
import 'package:test_flutter_project/gateways/get_my_clips.dart';
import 'package:test_flutter_project/gateways/patch_clip.dart';
import 'package:test_flutter_project/models/clip.dart' as models;
import 'package:flutter_hooks/flutter_hooks.dart';

import 'clip_list_tile.dart';
import 'clip_card.dart';

enum ClipListType {
  card,
  listTile,
}

class ClipList extends StatefulHookWidget {
  const ClipList(
      {super.key, required this.unreadOnly, this.type = ClipListType.listTile});

  final bool unreadOnly;
  final ClipListType type;

  @override
  createState() => _ClipListState();
}

class _ClipListState extends State<ClipList> {
  late Future<void> future;
  List<models.Clip> clipContents = [];
  final int loadLimit = 10;

  Future<bool> fetchContents([int? cursor]) async {
    final clips =
        await getMyClips(context, loadLimit, cursor, widget.unreadOnly);
    if (clips == null) {
      return true;
    }
    if (clips.clips.isEmpty) {
      return false;
    }

    setState(() {
      clipContents = clipContents.followedBy(clips.clips).toSet().toList();
    });
    return true;
  }

  Future<bool> updateClipStatus(int clipId, int status) async {
    final clip = await updateClip(context, clipId, ClipPatch(status: status));
    if (clip == null) return false;

    return true;
  }

  DismissDirectionCallback? dismissHandlerGenerator(int clipId) {
    if (!widget.unreadOnly) return null;

    final targetIndex =
        clipContents.indexWhere((element) => element.id == clipId);
    if (targetIndex == -1) return null;

    return (_) {
      updateClipStatus(clipContents[targetIndex].id, 2);
      setState(() {
        clipContents.removeAt(targetIndex);
      });
    };
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      setState(() {
        clipContents = [];
        future = fetchContents();
      });
      return null;
    }, [widget.unreadOnly]);

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return const Text("エラーが発生しました");
        } else {
          return InfinityListView(
            contents: clipContents,
            fetchContents: fetchContents,
            type: widget.type,
            dismissHandlerGenerator: dismissHandlerGenerator,
          );
        }
      },
    );
  }
}

class InfinityListView extends StatefulWidget {
  final List<models.Clip> contents;
  final Future<bool> Function(int?) fetchContents;
  final ClipListType type;
  final DismissDirectionCallback? Function(int) dismissHandlerGenerator;

  const InfinityListView(
      {super.key,
      required this.contents,
      required this.fetchContents,
      required this.type,
      required this.dismissHandlerGenerator});

  @override
  State<InfinityListView> createState() => _InfinityListViewState();
}

class _InfinityListViewState extends State<InfinityListView> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {
        _isLoading = true;

        final hasMore = await widget.fetchContents(widget.contents.last.id);

        setState(() {
          _isLoading = false;
          _hasMore = hasMore;
        });

        if (!hasMore) {
          _scrollController.dispose();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: _hasMore ? widget.contents.length + 1 : widget.contents.length,
      separatorBuilder: (BuildContext context, int index) {
        if (widget.type == ClipListType.card) {
          return const SizedBox(height: 8);
        }
        return Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1));
      },
      itemBuilder: (BuildContext context, int index) {
        if (_hasMore && widget.contents.length == index) {
          return const SizedBox(
            height: 50,
            width: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final clip = widget.contents[index];
        if (widget.type == ClipListType.card) {
          return Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ClipCard(clip: clip));
        }

        return Dismissible(
          key: Key('clip-${clip.id}'),
          background: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.markunread,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
          ),
          onDismissed: widget.dismissHandlerGenerator(clip.id),
          child: ClipListTile(
            clip: clip,
            dismissHandler: widget.dismissHandlerGenerator(clip.id),
          ),
        );
      },
    );
  }
}
