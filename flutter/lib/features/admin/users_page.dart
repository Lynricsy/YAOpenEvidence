import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// TODO_STEP_PLACEHOLDER：本页在后续步骤实现。
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(icon: Icons.group_outlined, title: '用户管理'),
  );
}
