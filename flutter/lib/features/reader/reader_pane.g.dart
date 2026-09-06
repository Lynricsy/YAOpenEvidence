// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_pane.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。

@ProviderFor(ReaderTarget)
final readerTargetProvider = ReaderTargetFamily._();

/// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。
final class ReaderTargetProvider
    extends $NotifierProvider<ReaderTarget, CitationRef?> {
  /// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。
  ReaderTargetProvider._({
    required ReaderTargetFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'readerTargetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerTargetHash();

  @override
  String toString() {
    return r'readerTargetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReaderTarget create() => ReaderTarget();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CitationRef? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CitationRef?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderTargetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerTargetHash() => r'f7f92f372bb9a05c81405b372085930c8fc61e66';

/// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。

final class ReaderTargetFamily extends $Family
    with
        $ClassFamilyOverride<
          ReaderTarget,
          CitationRef?,
          CitationRef?,
          CitationRef?,
          String
        > {
  ReaderTargetFamily._()
    : super(
        retry: null,
        name: r'readerTargetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。

  ReaderTargetProvider call(String answerId) =>
      ReaderTargetProvider._(argument: answerId, from: this);

  @override
  String toString() => r'readerTargetProvider';
}

/// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。

abstract class _$ReaderTarget extends $Notifier<CitationRef?> {
  late final _$args = ref.$arg as String;
  String get answerId => _$args;

  CitationRef? build(String answerId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CitationRef?, CitationRef?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CitationRef?, CitationRef?>,
              CitationRef?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 取第 n 篇材料：详情 404 时回退原文快照，都 404 则视为缺失。

@ProviderFor(readerMaterial)
final readerMaterialProvider = ReaderMaterialFamily._();

/// 取第 n 篇材料：详情 404 时回退原文快照，都 404 则视为缺失。

final class ReaderMaterialProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReaderMaterial>,
          ReaderMaterial,
          FutureOr<ReaderMaterial>
        >
    with $FutureModifier<ReaderMaterial>, $FutureProvider<ReaderMaterial> {
  /// 取第 n 篇材料：详情 404 时回退原文快照，都 404 则视为缺失。
  ReaderMaterialProvider._({
    required ReaderMaterialFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'readerMaterialProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerMaterialHash();

  @override
  String toString() {
    return r'readerMaterialProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ReaderMaterial> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReaderMaterial> create(Ref ref) {
    final argument = this.argument as (String, int);
    return readerMaterial(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderMaterialProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerMaterialHash() => r'cec03b30b56b74027000d3b528e485b06542b9f2';

/// 取第 n 篇材料：详情 404 时回退原文快照，都 404 则视为缺失。

final class ReaderMaterialFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReaderMaterial>, (String, int)> {
  ReaderMaterialFamily._()
    : super(
        retry: null,
        name: r'readerMaterialProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 取第 n 篇材料：详情 404 时回退原文快照，都 404 则视为缺失。

  ReaderMaterialProvider call(String answerId, int n) =>
      ReaderMaterialProvider._(argument: (answerId, n), from: this);

  @override
  String toString() => r'readerMaterialProvider';
}
