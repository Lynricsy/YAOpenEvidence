import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/session/prefs.dart';

part 'theme_controller.g.dart';

/// 主题模式，持久化到 `picoseek.theme`。
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final raw = ref.watch(prefsProvider).getString(PrefKeys.theme);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(prefsProvider).setString(PrefKeys.theme, mode.name);
  }
}
