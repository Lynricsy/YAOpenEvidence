import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// TODO_STEP_PLACEHOLDER：本页在后续步骤实现。
class PaperPage extends StatelessWidget {
  const PaperPage({super.key, required this.paperKey, this.pid});

  final String paperKey;
  final int? pid;

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(icon: Icons.description_outlined, title: '文献详情'),
  );
}
