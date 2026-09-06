// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_sidebar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 侧栏折叠状态。null = 尚未选择，由窗口宽度决定。

@ProviderFor(SidebarCollapsed)
final sidebarCollapsedProvider = SidebarCollapsedProvider._();

/// 侧栏折叠状态。null = 尚未选择，由窗口宽度决定。
final class SidebarCollapsedProvider
    extends $NotifierProvider<SidebarCollapsed, bool?> {
  /// 侧栏折叠状态。null = 尚未选择，由窗口宽度决定。
  SidebarCollapsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarCollapsedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarCollapsedHash();

  @$internal
  @override
  SidebarCollapsed create() => SidebarCollapsed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }
}

String _$sidebarCollapsedHash() => r'36ff8c1121059b44a0df67763c4601a98bcc85f6';

/// 侧栏折叠状态。null = 尚未选择，由窗口宽度决定。

abstract class _$SidebarCollapsed extends $Notifier<bool?> {
  bool? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool?, bool?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool?, bool?>,
              bool?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 侧栏「最近问答」5 条。`answersVersion` 变化时重取。

@ProviderFor(recentAnswers)
final recentAnswersProvider = RecentAnswersProvider._();

/// 侧栏「最近问答」5 条。`answersVersion` 变化时重取。

final class RecentAnswersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnswerSummary>>,
          List<AnswerSummary>,
          FutureOr<List<AnswerSummary>>
        >
    with
        $FutureModifier<List<AnswerSummary>>,
        $FutureProvider<List<AnswerSummary>> {
  /// 侧栏「最近问答」5 条。`answersVersion` 变化时重取。
  RecentAnswersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentAnswersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentAnswersHash();

  @$internal
  @override
  $FutureProviderElement<List<AnswerSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AnswerSummary>> create(Ref ref) {
    return recentAnswers(ref);
  }
}

String _$recentAnswersHash() => r'47b07cacfa1e02cc7f1d12f0b669525a8d418bb0';
