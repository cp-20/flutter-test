import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/article_list/stack_list.dart';

class StackPage extends StatelessWidget {
  const StackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: StackList());
  }
}
