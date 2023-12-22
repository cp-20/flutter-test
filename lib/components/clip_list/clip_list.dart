import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/sliver_animated_list_view.dart';
import 'package:test_flutter_project/components/infinity_list_view.dart';
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
  final int loadLimit = 20;

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
          return InfinityListView<models.Clip>(
            contents: clipContents,
            fetchContents: () => fetchContents(clipContents.last.id),
            itemListBuilder: (context, scrollController, clips, hasMore) {
              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverAnimatedListView(
                    items: clips,
                    itemBuilder:
                        (context, clip, animation, isRemoved, insert, remove) {
                      if (widget.type == ClipListType.card) {
                        return Column(
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: ClipCard(clip: clip)),
                            const SizedBox(height: 8),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          SizeTransition(
                            sizeFactor: animation,
                            child: DismissibleView(
                              itemKey: Key('clip-${clip.id}'),
                              onDismissed: (direction) {
                                  final targetIndex = clipContents.indexWhere(
                                      (element) => element.id == clip.id);

                                  final targetClip = clipContents[targetIndex];
                                  updateClipStatus(
                                      clipContents[targetIndex].id, 2);
                                  remove(targetIndex);
                                  setState(() {
                                    clipContents.removeAt(targetIndex);
                                  });

                                  final snackBar = SnackBar(
                                    action: SnackBarAction(
                                      label: '元に戻す',
                                      onPressed: () {},
                                    ),
                                    content: const Text('記事を既読にしました'),
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    // margin: const EdgeInsets.all(16),
                                    // behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    animation: CurvedAnimation(
                                      curve: Curves.easeIn,
                                      reverseCurve: Curves.easeOut,
                                      parent: animation.drive(Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      )),
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar)
                                      .closed
                                      .then((reason) {
                                    if (reason != SnackBarClosedReason.action) {
                                      return;
                                    }

                                    insert(targetIndex, targetClip);
                                    updateClipStatus(
                                        clipContents[targetIndex].id,
                                        targetClip.status);
                                    setState(() {
                                      clipContents.insert(
                                          targetIndex, targetClip);
                                    });
                                  });
                              },
                              child: ClipListTile(
                                clip: clip,
                              ),
                            ),
                          ),
                          Divider(
                              height: 1,
                              thickness: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.1)),
                        ],
                      );
                    },
                  ),
                  if (hasMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                ],
              );
            },
          );
        }
      },
    );
  }
}

class DismissibleView extends StatelessWidget {
  const DismissibleView({
    super.key,
    required this.itemKey,
    required this.child,
    required this.onDismissed,
  });

  final Key itemKey;
  final Widget child;
  final DismissDirectionCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
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
      // secondaryBackground: Container(
      //   color: Theme.of(context).colorScheme.errorContainer,
      //   alignment: Alignment.centerRight,
      //   child: Padding(
      //     padding: const EdgeInsets.only(right: 16),
      //     child: Icon(
      //       Icons.archive,
      //       color: Theme.of(context).colorScheme.onErrorContainer,
      //       size: 32,
      //     ),
      //   ),
      // ),
      onDismissed: onDismissed,
      child: child,
    );
  }
}
