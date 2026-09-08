// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_meta.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 分区筛选的依据；空表意味着 Q1–Q4 不会生效。

@ProviderFor(rankTables)
final rankTablesProvider = RankTablesProvider._();

/// 分区筛选的依据；空表意味着 Q1–Q4 不会生效。

final class RankTablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<RankTables>,
          RankTables,
          FutureOr<RankTables>
        >
    with $FutureModifier<RankTables>, $FutureProvider<RankTables> {
  /// 分区筛选的依据；空表意味着 Q1–Q4 不会生效。
  RankTablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rankTablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rankTablesHash();

  @$internal
  @override
  $FutureProviderElement<RankTables> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RankTables> create(Ref ref) {
    return rankTables(ref);
  }
}

String _$rankTablesHash() => r'299598fe3ff446cb71ebf10f5b4e0be607dc53b9';

/// 机构订阅登录态；决定付费全文能不能取到。

@ProviderFor(paywallStatus)
final paywallStatusProvider = PaywallStatusProvider._();

/// 机构订阅登录态；决定付费全文能不能取到。

final class PaywallStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaywallStatus>,
          PaywallStatus,
          FutureOr<PaywallStatus>
        >
    with $FutureModifier<PaywallStatus>, $FutureProvider<PaywallStatus> {
  /// 机构订阅登录态；决定付费全文能不能取到。
  PaywallStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paywallStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paywallStatusHash();

  @$internal
  @override
  $FutureProviderElement<PaywallStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaywallStatus> create(Ref ref) {
    return paywallStatus(ref);
  }
}

String _$paywallStatusHash() => r'5bad50377c11c61f2a9734eaaa88a6e006dcd03a';
