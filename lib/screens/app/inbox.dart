import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/article_list/inbox_list.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: InboxList());
  }
}
