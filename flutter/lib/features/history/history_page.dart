import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// TODO_STEP_PLACEHOLDER：本页在后续步骤实现。
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(icon: Icons.history, title: '历史'),
  );
}
