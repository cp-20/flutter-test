import 'package:flutter/material.dart';
import 'package:test_flutter_project/components/article_list/archive_list.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: ArchiveList());
  }
}
