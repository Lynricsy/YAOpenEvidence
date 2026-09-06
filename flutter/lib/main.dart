import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // 4xx 不可自动重试：重试一律由 UI 按钮触发。
    ProviderScope(retry: (_, _) => null, child: const _Bootstrap()),
  );
}

/// 临时启动壳：步骤 4 会替换为 `app/app.dart` 的 `App`。
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'YAOpenEvidence',
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
