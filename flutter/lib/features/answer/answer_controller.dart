import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/answers_version.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/models/answers.dart';
import '../../core/session/session_controller.dart';
import 'job_live_monitor.dart';

part 'answer_controller.g.dart';

/// 单个答案的状态机：SSE 终态或轮询驱动重取。
@riverpod
class AnswerController extends _$AnswerController {
  Timer? _poll;

  /// 已请求取消但后端还没落终态：按钮保持禁用，避免重复 202。
  bool cancelRequested = false;

  @override
  Future<Answer> build(String answerId) async {
    ref.onDispose(() => _poll?.cancel());
    final answer = await ref.watch(apiClientProvider).answer(answerId);

    final jobId = answer.jobId;
    if (answer.status.isActive && jobId != null) {
      // 事件流拿到终态后立刻重取，正文/来源随之出现。
      ref.listen(jobLiveMonitorProvider(jobId), (previous, next) {
        if (previous?.live.terminal == null && next.live.terminal != null) {
          reload();
        }
      });
      _startPolling(jobId);
    } else {
      _poll?.cancel();
      _poll = null;
    }
    return answer;
  }

  /// 兜底轮询：SSE 未连上时每 5 s 静默重取一次。
  void _startPolling(String jobId) {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) {
      final current = state.value;
      if (current == null || !current.status.isActive) return;
      final connection = ref.read(jobLiveMonitorProvider(jobId)).connection;
      if (connection == SseConnection.open) return;
      reload();
    });
  }

  /// 静默重取：不切 loading，失败保留旧数据（进行中页面不该闪空）。
  Future<void> reload() async {
    try {
      final answer = await ref.read(apiClientProvider).answer(answerId);
      state = AsyncData(answer);
      if (!answer.status.isActive) {
        cancelRequested = false;
        _poll?.cancel();
        _poll = null;
      }
    } on ApiError {
      // 网络抖动：下个周期再试。
    }
  }

  /// 取消任务。409 表示后端已进终态，直接重取。
  Future<void> cancel() async {
    final answer = state.value;
    final jobId = answer?.jobId;
    if (jobId == null) return;
    try {
      await ref.read(apiClientProvider).cancelJob(jobId);
      cancelRequested = true;
      state = AsyncData(answer!);
    } on ApiError catch (error) {
      if (error.status == 409) {
        await reload();
        return;
      }
      rethrow;
    }
  }

  /// 删除答案（仅终态）。成功后由调用方跳转。
  Future<void> delete() async {
    await ref.read(apiClientProvider).deleteAnswer(answerId);
    ref.read(answersVersionProvider.notifier).bump();
  }
}

/// 旧版答案（`ready` 但没有 `body_md`）的正文：取渲染稿 Markdown。
@riverpod
Future<String> legacyAnswerMarkdown(Ref ref, String answerId) =>
    ref.watch(apiClientProvider).answerMarkdown(answerId);
