// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 单个答案的状态机：SSE 终态或轮询驱动重取。

@ProviderFor(AnswerController)
final answerControllerProvider = AnswerControllerFamily._();

/// 单个答案的状态机：SSE 终态或轮询驱动重取。
final class AnswerControllerProvider
    extends $AsyncNotifierProvider<AnswerController, Answer> {
  /// 单个答案的状态机：SSE 终态或轮询驱动重取。
  AnswerControllerProvider._({
    required AnswerControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'answerControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$answerControllerHash();

  @override
  String toString() {
    return r'answerControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AnswerController create() => AnswerController();

  @override
  bool operator ==(Object other) {
    return other is AnswerControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$answerControllerHash() => r'95821e10e0490f909017ebfef5f7d084489c3edf';

/// 单个答案的状态机：SSE 终态或轮询驱动重取。

final class AnswerControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AnswerController,
          AsyncValue<Answer>,
          Answer,
          FutureOr<Answer>,
          String
        > {
  AnswerControllerFamily._()
    : super(
        retry: null,
        name: r'answerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 单个答案的状态机：SSE 终态或轮询驱动重取。

  AnswerControllerProvider call(String answerId) =>
      AnswerControllerProvider._(argument: answerId, from: this);

  @override
  String toString() => r'answerControllerProvider';
}

/// 单个答案的状态机：SSE 终态或轮询驱动重取。

abstract class _$AnswerController extends $AsyncNotifier<Answer> {
  late final _$args = ref.$arg as String;
  String get answerId => _$args;

  FutureOr<Answer> build(String answerId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Answer>, Answer>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Answer>, Answer>,
              AsyncValue<Answer>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 旧版答案（`ready` 但没有 `body_md`）的正文：取渲染稿 Markdown。

@ProviderFor(legacyAnswerMarkdown)
final legacyAnswerMarkdownProvider = LegacyAnswerMarkdownFamily._();

/// 旧版答案（`ready` 但没有 `body_md`）的正文：取渲染稿 Markdown。

final class LegacyAnswerMarkdownProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 旧版答案（`ready` 但没有 `body_md`）的正文：取渲染稿 Markdown。
  LegacyAnswerMarkdownProvider._({
    required LegacyAnswerMarkdownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'legacyAnswerMarkdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$legacyAnswerMarkdownHash();

  @override
  String toString() {
    return r'legacyAnswerMarkdownProvider'
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
    return legacyAnswerMarkdown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LegacyAnswerMarkdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$legacyAnswerMarkdownHash() =>
    r'0b18b0420bedb68afd4803e78394224412dff57b';

/// 旧版答案（`ready` 但没有 `body_md`）的正文：取渲染稿 Markdown。

final class LegacyAnswerMarkdownFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  LegacyAnswerMarkdownFamily._()
    : super(
        retry: null,
        name: r'legacyAnswerMarkdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 旧版答案（`ready` 但没有 `body_md`）的正文：取渲染稿 Markdown。

  LegacyAnswerMarkdownProvider call(String answerId) =>
      LegacyAnswerMarkdownProvider._(argument: answerId, from: this);

  @override
  String toString() => r'legacyAnswerMarkdownProvider';
}

/// 同一智能体会话的全部回合（答案页「对话脉络」）。

@ProviderFor(answerThread)
final answerThreadProvider = AnswerThreadFamily._();

/// 同一智能体会话的全部回合（答案页「对话脉络」）。

final class AnswerThreadProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnswerSummary>>,
          List<AnswerSummary>,
          FutureOr<List<AnswerSummary>>
        >
    with
        $FutureModifier<List<AnswerSummary>>,
        $FutureProvider<List<AnswerSummary>> {
  /// 同一智能体会话的全部回合（答案页「对话脉络」）。
  AnswerThreadProvider._({
    required AnswerThreadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'answerThreadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$answerThreadHash();

  @override
  String toString() {
    return r'answerThreadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AnswerSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AnswerSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return answerThread(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnswerThreadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$answerThreadHash() => r'4a8a808d08aaf8e76350b7a7c94635f332bb5214';

/// 同一智能体会话的全部回合（答案页「对话脉络」）。

final class AnswerThreadFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AnswerSummary>>, String> {
  AnswerThreadFamily._()
    : super(
        retry: null,
        name: r'answerThreadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 同一智能体会话的全部回合（答案页「对话脉络」）。

  AnswerThreadProvider call(String answerId) =>
      AnswerThreadProvider._(argument: answerId, from: this);

  @override
  String toString() => r'answerThreadProvider';
}
