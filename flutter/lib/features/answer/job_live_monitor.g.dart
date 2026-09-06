// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_live_monitor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 单个任务的事件流监听器：断线重连 + 事件归约。
///
/// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
/// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。

@ProviderFor(JobLiveMonitor)
final jobLiveMonitorProvider = JobLiveMonitorFamily._();

/// 单个任务的事件流监听器：断线重连 + 事件归约。
///
/// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
/// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。
final class JobLiveMonitorProvider
    extends $NotifierProvider<JobLiveMonitor, JobLiveState> {
  /// 单个任务的事件流监听器：断线重连 + 事件归约。
  ///
  /// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
  /// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。
  JobLiveMonitorProvider._({
    required JobLiveMonitorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'jobLiveMonitorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$jobLiveMonitorHash();

  @override
  String toString() {
    return r'jobLiveMonitorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JobLiveMonitor create() => JobLiveMonitor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobLiveState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobLiveState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JobLiveMonitorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobLiveMonitorHash() => r'1499098670a8ea387e62b400f74a44ca963027a8';

/// 单个任务的事件流监听器：断线重连 + 事件归约。
///
/// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
/// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。

final class JobLiveMonitorFamily extends $Family
    with
        $ClassFamilyOverride<
          JobLiveMonitor,
          JobLiveState,
          JobLiveState,
          JobLiveState,
          String
        > {
  JobLiveMonitorFamily._()
    : super(
        retry: null,
        name: r'jobLiveMonitorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 单个任务的事件流监听器：断线重连 + 事件归约。
  ///
  /// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
  /// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。

  JobLiveMonitorProvider call(String jobId) =>
      JobLiveMonitorProvider._(argument: jobId, from: this);

  @override
  String toString() => r'jobLiveMonitorProvider';
}

/// 单个任务的事件流监听器：断线重连 + 事件归约。
///
/// 重连策略与 Apple 端 `JobLiveMonitor` 一致：退避 1→2→4→8→10 s 封顶；
/// 重连前先 `me()` 探活，401 直接收摊（会话已失效，重试只会刷 401）。

abstract class _$JobLiveMonitor extends $Notifier<JobLiveState> {
  late final _$args = ref.$arg as String;
  String get jobId => _$args;

  JobLiveState build(String jobId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<JobLiveState, JobLiveState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JobLiveState, JobLiveState>,
              JobLiveState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
