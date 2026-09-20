// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 分栏比例（答案区占比，0.40–0.60），持久化到 `picoseek.reader-layout`。

@ProviderFor(ReaderLayout)
final readerLayoutProvider = ReaderLayoutProvider._();

/// 分栏比例（答案区占比，0.40–0.60），持久化到 `picoseek.reader-layout`。
final class ReaderLayoutProvider
    extends $NotifierProvider<ReaderLayout, double> {
  /// 分栏比例（答案区占比，0.40–0.60），持久化到 `picoseek.reader-layout`。
  ReaderLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerLayoutHash();

  @$internal
  @override
  ReaderLayout create() => ReaderLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$readerLayoutHash() => r'6e29cba7ed1598172eaa72f380430bc27153d3d1';

/// 分栏比例（答案区占比，0.40–0.60），持久化到 `picoseek.reader-layout`。

abstract class _$ReaderLayout extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
