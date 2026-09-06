import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// TODO_STEP_PLACEHOLDER：本页在后续步骤实现。
class KbPage extends StatelessWidget {
  const KbPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(icon: Icons.storage_outlined, title: '知识库'),
  );
}
