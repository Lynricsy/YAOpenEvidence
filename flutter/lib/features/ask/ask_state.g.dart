// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ask_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 提问筛选条件，持久化到 `yaoe.filters`（写入前先 `normalized()`）。

@ProviderFor(AskFiltersController)
final askFiltersControllerProvider = AskFiltersControllerProvider._();

/// 提问筛选条件，持久化到 `yaoe.filters`（写入前先 `normalized()`）。
final class AskFiltersControllerProvider
    extends $NotifierProvider<AskFiltersController, AskFilters> {
  /// 提问筛选条件，持久化到 `yaoe.filters`（写入前先 `normalized()`）。
  AskFiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'askFiltersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$askFiltersControllerHash();

  @$internal
  @override
  AskFiltersController create() => AskFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AskFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AskFilters>(value),
    );
  }
}

String _$askFiltersControllerHash() =>
    r'3bf562440393ec37a62c06c20ffc03dc6569739f';

/// 提问筛选条件，持久化到 `yaoe.filters`（写入前先 `normalized()`）。

abstract class _$AskFiltersController extends $Notifier<AskFilters> {
  AskFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AskFilters, AskFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AskFilters, AskFilters>,
              AskFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 提问草稿（跨页面保留，例如从答案页「沿用筛选重新提问」跳回提问页）。

@ProviderFor(AskDraft)
final askDraftProvider = AskDraftProvider._();

/// 提问草稿（跨页面保留，例如从答案页「沿用筛选重新提问」跳回提问页）。
final class AskDraftProvider extends $NotifierProvider<AskDraft, String> {
  /// 提问草稿（跨页面保留，例如从答案页「沿用筛选重新提问」跳回提问页）。
  AskDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'askDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$askDraftHash();

  @$internal
  @override
  AskDraft create() => AskDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$askDraftHash() => r'5df7e97d28ac95e54e3b57ed7a5ddea4b9224aa3';

/// 提问草稿（跨页面保留，例如从答案页「沿用筛选重新提问」跳回提问页）。

abstract class _$AskDraft extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
