import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/logic/job_live.dart';
import '../../core/models/jobs.dart';
import '../../core/models/kb.dart';
import '../../core/session/session_controller.dart';

part 'kb_controller.g.dart';

/// 任务行的终态 -> 事件流的 [Terminal]；非终态返回 null。
///
/// SSE 断流时只能靠 `GET /v1/jobs/{id}` 兜底，这里把两条路径收敛到同一种表示，
/// 终态文案就只有一处。
Terminal? jobTerminal(Job job) => switch (job.status) {
  JobStatus.succeeded => Succeeded(
    items: job.result?['items'] as int?,
    papers: job.result?['papers'] as int?,
  ),
  JobStatus.failed => Failed(
    code: job.error?.code ?? 'internal_error',
    message: job.error?.message ?? '',
  ),
  JobStatus.cancelled => const Cancelled(),
  JobStatus.queued || JobStatus.running => null,
};

/// 索引重建结束后给主人看的一句话。
String reindexTerminalMessage(Terminal terminal) => switch (terminal) {
  Succeeded() => '索引重建完成',
  Cancelled() => '索引重建已取消',
  Failed(:final code, :final message) => message.isEmpty
      ? jobErrorMessage(code)
      : '${jobErrorMessage(code)}：$message',
};

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
