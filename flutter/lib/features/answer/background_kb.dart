import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/logic/ask_rail.dart';
import '../../core/session/session_controller.dart';

part 'background_kb.g.dart';

/// 后台写库任务的状态。
///
/// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
/// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
/// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
/// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。
@riverpod
class BackgroundKbWatcher extends _$BackgroundKbWatcher {
  Timer? _poll;

  @override
  Future<BackgroundKb?> build(String jobId) async {
    ref.onDispose(_stopPolling);
    final kb = await _fetch(ref.watch(apiClientProvider));
    _schedule(kb);
    return kb;
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  /// 子任务还在排队或写入时每 5 s 轮询一次，进终态就停。
  void _schedule(BackgroundKb? kb) {
    _stopPolling();
    if (kb == null || !kb.status.isActive) return;
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final kb = await _fetch(ref.read(apiClientProvider));
    state = AsyncData(kb);
    _schedule(kb);
  }

  Future<BackgroundKb?> _fetch(ApiClient api) async {
    try {
      final parent = await api.job(jobId);
      final kbJobId = parent.result?['kb_job_id'];
      if (kbJobId is! String || kbJobId.isEmpty) return null;
      final job = await api.job(kbJobId);
      return BackgroundKb(
        status: KbStatus.of(job.status),
        current: job.progress?.current ?? 0,
        total: job.progress?.total ?? 0,
      );
    } on ApiError {
      return BackgroundKb.unknown;
    }
  }
}
