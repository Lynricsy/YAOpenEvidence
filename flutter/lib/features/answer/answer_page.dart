import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// TODO_STEP_PLACEHOLDER：本页在后续步骤实现。
class AnswerPage extends StatelessWidget {
  const AnswerPage({super.key, required this.answerId});

  final String answerId;

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(icon: Icons.article_outlined, title: '答案'),
  );
}
