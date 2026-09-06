// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answers_version.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 问答列表版本号。创建/删除答案后 `bump()`，侧栏「最近问答」与历史页
/// `ref.watch` 它以触发重取（避免各页面互相持有 provider 引用）。

@ProviderFor(AnswersVersion)
final answersVersionProvider = AnswersVersionProvider._();

/// 问答列表版本号。创建/删除答案后 `bump()`，侧栏「最近问答」与历史页
/// `ref.watch` 它以触发重取（避免各页面互相持有 provider 引用）。
final class AnswersVersionProvider
    extends $NotifierProvider<AnswersVersion, int> {
  /// 问答列表版本号。创建/删除答案后 `bump()`，侧栏「最近问答」与历史页
  /// `ref.watch` 它以触发重取（避免各页面互相持有 provider 引用）。
  AnswersVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'answersVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$answersVersionHash();

  @$internal
  @override
  AnswersVersion create() => AnswersVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$answersVersionHash() => r'5a3b6d6b30be1186b676b5d3d01b35aba848a6e1';

/// 问答列表版本号。创建/删除答案后 `bump()`，侧栏「最近问答」与历史页
/// `ref.watch` 它以触发重取（避免各页面互相持有 provider 引用）。

abstract class _$AnswersVersion extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
