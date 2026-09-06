import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

/// TODO_STEP_PLACEHOLDER：本页在后续步骤实现。
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(icon: Icons.local_library_outlined, title: '文献库'),
  );
}
