// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LibraryController)
final libraryControllerProvider = LibraryControllerProvider._();

final class LibraryControllerProvider
    extends $AsyncNotifierProvider<LibraryController, Page<PaperMeta>> {
  LibraryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryControllerHash();

  @$internal
  @override
  LibraryController create() => LibraryController();
}

String _$libraryControllerHash() => r'2d1986b578526dade73e2e171a34a7e275a68704';

abstract class _$LibraryController extends $AsyncNotifier<Page<PaperMeta>> {
  FutureOr<Page<PaperMeta>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Page<PaperMeta>>, Page<PaperMeta>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Page<PaperMeta>>, Page<PaperMeta>>,
              AsyncValue<Page<PaperMeta>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paperFulltext)
final paperFulltextProvider = PaperFulltextFamily._();

final class PaperFulltextProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  PaperFulltextProvider._({
    required PaperFulltextFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paperFulltextProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paperFulltextHash();

  @override
  String toString() {
    return r'paperFulltextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return paperFulltext(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaperFulltextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paperFulltextHash() => r'ef98c6c451428af53cf636f3ef1104b684ab89cd';

final class PaperFulltextFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  PaperFulltextFamily._()
    : super(
        retry: null,
        name: r'paperFulltextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaperFulltextProvider call(String key) =>
      PaperFulltextProvider._(argument: key, from: this);

  @override
  String toString() => r'paperFulltextProvider';
}

@ProviderFor(paperFacts)
final paperFactsProvider = PaperFactsFamily._();

final class PaperFactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Fact>>,
          List<Fact>,
          FutureOr<List<Fact>>
        >
    with $FutureModifier<List<Fact>>, $FutureProvider<List<Fact>> {
  PaperFactsProvider._({
    required PaperFactsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paperFactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paperFactsHash();

  @override
  String toString() {
    return r'paperFactsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Fact>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Fact>> create(Ref ref) {
    final argument = this.argument as String;
    return paperFacts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaperFactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paperFactsHash() => r'eae692e6517591fe46e6d3b7133620265e1e9043';

final class PaperFactsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Fact>>, String> {
  PaperFactsFamily._()
    : super(
        retry: null,
        name: r'paperFactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaperFactsProvider call(String key) =>
      PaperFactsProvider._(argument: key, from: this);

  @override
  String toString() => r'paperFactsProvider';
}

@ProviderFor(paperMeta)
final paperMetaProvider = PaperMetaFamily._();

final class PaperMetaProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaperMeta>,
          PaperMeta,
          FutureOr<PaperMeta>
        >
    with $FutureModifier<PaperMeta>, $FutureProvider<PaperMeta> {
  PaperMetaProvider._({
    required PaperMetaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paperMetaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paperMetaHash();

  @override
  String toString() {
    return r'paperMetaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaperMeta> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PaperMeta> create(Ref ref) {
    final argument = this.argument as String;
    return paperMeta(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaperMetaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paperMetaHash() => r'db043d951c6a52820113c50a007c0fc1f82913ba';

final class PaperMetaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PaperMeta>, String> {
  PaperMetaFamily._()
    : super(
        retry: null,
        name: r'paperMetaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaperMetaProvider call(String key) =>
      PaperMetaProvider._(argument: key, from: this);

  @override
  String toString() => r'paperMetaProvider';
}
