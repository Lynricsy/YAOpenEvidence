import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/logic/ask_filters.dart';
import '../../core/session/prefs.dart';

part 'ask_state.g.dart';

/// 提问筛选条件，持久化到 `yaoe.filters`（写入前先 `normalized()`）。
@Riverpod(keepAlive: true)
class AskFiltersController extends _$AskFiltersController {
  @override
  AskFilters build() {
    final stored = ref.watch(prefsProvider).getJson(PrefKeys.filters);
    if (stored == null) return const AskFilters();
    try {
      return AskFilters.fromJson(stored).normalized();
    } catch (_) {
      // 旧版本残留或手改坏了：回落默认值，不让提问页开不起来。
      return const AskFilters();
    }
  }

  Future<void> set(AskFilters filters) async {
    final normalized = filters.normalized();
    state = normalized;
    await ref.read(prefsProvider).setJson(PrefKeys.filters, normalized.toJson());
  }

  Future<void> reset() => set(const AskFilters());
}

/// 提问草稿（跨页面保留，例如从答案页「沿用筛选重新提问」跳回提问页）。
@Riverpod(keepAlive: true)
class AskDraft extends _$AskDraft {
  @override
  String build() => '';

  void set(String text) => state = text;

  void clear() => state = '';
}
