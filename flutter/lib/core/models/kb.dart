import 'package:freezed_annotation/freezed_annotation.dart';

part 'kb.freezed.dart';
part 'kb.g.dart';

enum KbKind {
  fact,
  paragraph;

  String get label => switch (this) {
    KbKind.fact => '事实',
    KbKind.paragraph => '段落',
  };
}

/// 知识库检索命中的一条事实或段落。
@freezed
abstract class KbHit with _$KbHit {
  const factory KbHit({
    required KbKind kind,
    @Default('') String pmid,
    @Default('') String doi,
    @Default('') String pmcid,
    @Default('') String title,
    @Default('') String year,
    @Default('') String journal,
    @Default('') String quartile,
    @Default('') String source,
    @Default('') String authors,
    int? pid,
    String? sec,
    int? page,
    @Default('') String text,
    String? textZh,
    String? factKind,
    String? quote,
    bool? verified,
    @Default(0) double score,
  }) = _KbHit;

  factory KbHit.fromJson(Map<String, Object?> json) => _$KbHitFromJson(json);
}

@freezed
abstract class KbSearchResult with _$KbSearchResult {
  const factory KbSearchResult({
    @Default('') String query,
    @Default(<KbHit>[]) List<KbHit> items,
  }) = _KbSearchResult;

  factory KbSearchResult.fromJson(Map<String, Object?> json) =>
      _$KbSearchResultFromJson(json);
}

@freezed
abstract class KbStats with _$KbStats {
  const factory KbStats({
    @Default(0) int items,
    @Default(0) int papers,
    @Default(<String, int>{}) Map<String, int> byKind,
    String? embedder,
    int? dim,
  }) = _KbStats;

  factory KbStats.fromJson(Map<String, Object?> json) =>
      _$KbStatsFromJson(json);
}
