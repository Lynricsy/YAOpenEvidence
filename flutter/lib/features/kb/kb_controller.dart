import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/endpoints.dart';
import '../../core/models/jobs.dart';
import '../../core/models/kb.dart';
import '../../core/session/session_controller.dart';

part 'kb_controller.g.dart';

@riverpod
Future<KbStats> kbStats(Ref ref) => ref.watch(apiClientProvider).kbStats();

@riverpod
class KbSearchController extends _$KbSearchController {
  String query = '';
  KbKind? kind;
  int topK = 8;
  int _request = 0;

  @override
  AsyncValue<KbSearchResult?> build() => const AsyncData(null);

  void setKind(KbKind? value) => kind = value;

  void setTopK(int value) {
    if (const [5, 8, 15, 30].contains(value)) topK = value;
  }

  Future<void> search(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    query = trimmed;
    final request = ++_request;
    final client = ref.read(apiClientProvider);
    state = const AsyncLoading();
    try {
      final result = await client.kbSearch(q: query, kind: kind, topK: topK);
      if (ref.mounted && request == _request) state = AsyncData(result);
    } catch (error, stack) {
      if (ref.mounted && request == _request) state = AsyncError(error, stack);
    }
  }
}

@Riverpod(keepAlive: true)
class KbReindexJob extends _$KbReindexJob {
  @override
  Job? build() {
    ref.watch(currentUserProvider);
    return null;
  }

  void set(Job? job) => state = job;
}
