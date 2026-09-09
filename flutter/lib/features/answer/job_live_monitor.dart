import 'dart:async';
import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/api/sse.dart';
import '../../core/logic/job_live.dart';
import '../../core/session/session_controller.dart';

part 'job_live_monitor.freezed.dart';
part 'job_live_monitor.g.dart';

/// SSE 连接状态（答案页指示灯）。
enum SseConnection {
  idle,
  connecting,
  open,
  reconnecting,
  closed;

  /// 只有「在等」和「出问题了」值得占一行字；连接正常是默认预期，说出来是噪音。
  String? get label => switch (this) {
    SseConnection.connecting => '连接中',
    SseConnection.reconnecting => '重连中',
    SseConnection.idle || SseConnection.open || SseConnection.closed => null,
  };
}

@freezed
abstract class JobLiveState with _$JobLiveState {
  const factory JobLiveState({
    @Default(JobLive.empty) JobLive live,
    @Default(SseConnection.idle) SseConnection connection,
    @Default('0-0') String lastEventId,
  }) = _JobLiveState;
}

/// 单个任务的事件流监听器：断线重连 + 事件归约。
///
/// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
/// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。
@riverpod
class JobLiveMonitor extends _$JobLiveMonitor {
  static const _fatalStatuses = {401, 403, 404, 422};

  bool _cancelled = false;
  StreamSubscription<SseEvent>? _subscription;
  Completer<void>? _gate;

  @override
  JobLiveState build(String jobId) {
    ref.onDispose(_stop);
    Future(() => _run(jobId));
    return const JobLiveState();
  }

  void _stop() {
    _cancelled = true;
    _subscription?.cancel();
    _subscription = null;
    if (_gate?.isCompleted == false) _gate!.complete();
  }

  Future<void> _run(String jobId) async {
    final client = ref.read(apiClientProvider);
    var delay = const Duration(seconds: 1);

    while (!_cancelled) {
      state = state.copyWith(connection: SseConnection.connecting);
      var fatal = false;
      final gate = Completer<void>();
      _gate = gate;
      try {
        final stream = client.events(
          jobId: jobId,
          lastEventId: state.lastEventId,
          onOpen: () {
            if (!_cancelled) {
              state = state.copyWith(connection: SseConnection.open);
            }
          },
        );
        _subscription = stream.listen(
          _onEvent,
          onError: gate.completeError,
          onDone: () {
            if (!gate.isCompleted) gate.complete();
          },
          cancelOnError: true,
        );
        await gate.future;
      } on ApiError catch (error) {
        fatal = _fatalStatuses.contains(error.status);
      } catch (_) {
        // 传输层异常：按可重连处理。
      } finally {
        await _subscription?.cancel();
        _subscription = null;
        _gate = null;
      }

      if (_cancelled) return;
      // 终态已到达或错误不可恢复：收摊。
      if (fatal || state.live.terminal != null) {
        state = state.copyWith(connection: SseConnection.closed);
        return;
      }

      state = state.copyWith(connection: SseConnection.reconnecting);
      try {
        await client.me();
      } on ApiError catch (error) {
        if (error.status == 401) {
          state = state.copyWith(connection: SseConnection.closed);
          return;
        }
      }
      if (_cancelled) return;
      await Future<void>.delayed(delay);
      delay = Duration(
        milliseconds: math.min(delay.inMilliseconds * 2, 10000),
      );
    }
  }

  void _onEvent(SseEvent event) {
    if (_cancelled) return;
    final live = state.live.applying(event);
    state = state.copyWith(
      live: live,
      lastEventId: event.id ?? state.lastEventId,
    );
    if (live.terminal != null) {
      // 终态帧到达后主动断流，不等服务端关闭。
      _subscription?.cancel();
      _subscription = null;
      if (_gate?.isCompleted == false) _gate!.complete();
    }
  }
}
