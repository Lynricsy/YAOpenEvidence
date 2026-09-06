// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiteratureController)
final literatureControllerProvider = LiteratureControllerProvider._();

final class LiteratureControllerProvider
    extends
        $NotifierProvider<
          LiteratureController,
          AsyncValue<LiteratureSearchResult?>
        > {
  LiteratureControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'literatureControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$literatureControllerHash();

  @$internal
  @override
  LiteratureController create() => LiteratureController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<LiteratureSearchResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<LiteratureSearchResult?>>(
        value,
      ),
    );
  }
}

String _$literatureControllerHash() =>
    r'2cea0b45d3ce3d270be3a149c94edff77742de74';

abstract class _$LiteratureController
    extends $Notifier<AsyncValue<LiteratureSearchResult?>> {
  AsyncValue<LiteratureSearchResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<LiteratureSearchResult?>,
              AsyncValue<LiteratureSearchResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<LiteratureSearchResult?>,
                AsyncValue<LiteratureSearchResult?>
              >,
              AsyncValue<LiteratureSearchResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
