// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kb_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kbStats)
final kbStatsProvider = KbStatsProvider._();

final class KbStatsProvider
    extends $FunctionalProvider<AsyncValue<KbStats>, KbStats, FutureOr<KbStats>>
    with $FutureModifier<KbStats>, $FutureProvider<KbStats> {
  KbStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kbStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kbStatsHash();

  @$internal
  @override
  $FutureProviderElement<KbStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KbStats> create(Ref ref) {
    return kbStats(ref);
  }
}

String _$kbStatsHash() => r'ec0143ed8b172d4c17a403d641da72b532ee9441';

@ProviderFor(KbSearchController)
final kbSearchControllerProvider = KbSearchControllerProvider._();

final class KbSearchControllerProvider
    extends $NotifierProvider<KbSearchController, AsyncValue<KbSearchResult?>> {
  KbSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kbSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kbSearchControllerHash();

  @$internal
  @override
  KbSearchController create() => KbSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<KbSearchResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<KbSearchResult?>>(value),
    );
  }
}

String _$kbSearchControllerHash() =>
    r'33d32d6030dbb8c7ed8798931f0d5f06068e7a85';

abstract class _$KbSearchController
    extends $Notifier<AsyncValue<KbSearchResult?>> {
  AsyncValue<KbSearchResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<KbSearchResult?>, AsyncValue<KbSearchResult?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<KbSearchResult?>,
                AsyncValue<KbSearchResult?>
              >,
              AsyncValue<KbSearchResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(KbReindexJob)
final kbReindexJobProvider = KbReindexJobProvider._();

final class KbReindexJobProvider extends $NotifierProvider<KbReindexJob, Job?> {
  KbReindexJobProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kbReindexJobProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kbReindexJobHash();

  @$internal
  @override
  KbReindexJob create() => KbReindexJob();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Job? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Job?>(value),
    );
  }
}

String _$kbReindexJobHash() => r'f75d9e6010643b50531c655429168626bfdbe409';

abstract class _$KbReindexJob extends $Notifier<Job?> {
  Job? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Job?, Job?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Job?, Job?>,
              Job?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
