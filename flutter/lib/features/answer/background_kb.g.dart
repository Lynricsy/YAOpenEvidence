// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_kb.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 后台写库任务的状态。
///
/// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
/// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
/// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
/// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。

@ProviderFor(BackgroundKbWatcher)
final backgroundKbWatcherProvider = BackgroundKbWatcherFamily._();

/// 后台写库任务的状态。
///
/// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
/// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
/// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
/// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。
final class BackgroundKbWatcherProvider
    extends $AsyncNotifierProvider<BackgroundKbWatcher, BackgroundKb?> {
  /// 后台写库任务的状态。
  ///
  /// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
  /// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
  /// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
  /// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。
  BackgroundKbWatcherProvider._({
    required BackgroundKbWatcherFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'backgroundKbWatcherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$backgroundKbWatcherHash();

  @override
  String toString() {
    return r'backgroundKbWatcherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BackgroundKbWatcher create() => BackgroundKbWatcher();

  @override
  bool operator ==(Object other) {
    return other is BackgroundKbWatcherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$backgroundKbWatcherHash() =>
    r'd12c4695189d63252d90c699ff97af3567d6b2fe';

/// 后台写库任务的状态。
///
/// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
/// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
/// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
/// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。

final class BackgroundKbWatcherFamily extends $Family
    with
        $ClassFamilyOverride<
          BackgroundKbWatcher,
          AsyncValue<BackgroundKb?>,
          BackgroundKb?,
          FutureOr<BackgroundKb?>,
          String
        > {
  BackgroundKbWatcherFamily._()
    : super(
        retry: null,
        name: r'backgroundKbWatcherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 后台写库任务的状态。
  ///
  /// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
  /// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
  /// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
  /// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。

  BackgroundKbWatcherProvider call(String jobId) =>
      BackgroundKbWatcherProvider._(argument: jobId, from: this);

  @override
  String toString() => r'backgroundKbWatcherProvider';
}

/// 后台写库任务的状态。
///
/// 写库排在答案之后：ask 任务成功时 worker 才另建 `kind=answer_kb` 的子任务，
/// 任务号挂在父任务的 `result.kb_job_id` 上，所以要先读父任务再读子任务。
/// 返回 null 表示还查不到子任务（父任务没挂出任务号）；请求失败收敛为
/// [BackgroundKb.unknown]，由节点显示「状态暂时无法读取」。

abstract class _$BackgroundKbWatcher extends $AsyncNotifier<BackgroundKb?> {
  late final _$args = ref.$arg as String;
  String get jobId => _$args;

  FutureOr<BackgroundKb?> build(String jobId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BackgroundKb?>, BackgroundKb?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BackgroundKb?>, BackgroundKb?>,
              AsyncValue<BackgroundKb?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
