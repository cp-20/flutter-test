import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/clip_list/clip_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool unreadOnly = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TabSwitchButton(
                active: unreadOnly,
                label: '未読のみ',
                onPressed: () => setState(() => unreadOnly = true),
                icon: const Icon(Icons.article_outlined),
              ),
              TabSwitchButton(
                active: !unreadOnly,
                label: '全ての記事',
                onPressed: () => setState(() => unreadOnly = false),
                icon: const Icon(Icons.article),
              ),
            ],
          ),
        ),
        Expanded(
            child: Visibility(
                visible: unreadOnly,
                replacement: const ClipList(
                  unreadOnly: false,
                ),
                child: const ClipList(
                  unreadOnly: true,
                ))),
      ],
    ));
  }
}

class TabSwitchButton extends StatelessWidget {
  const TabSwitchButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed,
      required this.active});

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(active
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surface),
          foregroundColor: MaterialStateProperty.all<Color>(active
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : Theme.of(context).colorScheme.onSurface),
        ),
        onPressed: onPressed,
        child: Wrap(spacing: 8, children: [
          Text(label,
              style: TextStyle(
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          icon
        ]),
      ),
    ));
  }
}
