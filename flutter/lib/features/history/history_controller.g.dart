// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryController)
final historyControllerProvider = HistoryControllerProvider._();

final class HistoryControllerProvider
    extends $AsyncNotifierProvider<HistoryController, Page<AnswerSummary>> {
  HistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyControllerHash();

  @$internal
  @override
  HistoryController create() => HistoryController();
}

String _$historyControllerHash() => r'4a50fb37923abdf508d502ff204491e62e198d0c';

abstract class _$HistoryController extends $AsyncNotifier<Page<AnswerSummary>> {
  FutureOr<Page<AnswerSummary>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Page<AnswerSummary>>, Page<AnswerSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Page<AnswerSummary>>, Page<AnswerSummary>>,
              AsyncValue<Page<AnswerSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
