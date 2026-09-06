import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/session/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 偏好在启动时读入内存，之后各处同步访问（主题、筛选、侧栏状态都要在首帧可用）。
  final prefs = await Prefs.open();
  runApp(
    ProviderScope(
      // 4xx 不可自动重试：重试一律由 UI 按钮触发。
      retry: (_, _) => null,
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
}
