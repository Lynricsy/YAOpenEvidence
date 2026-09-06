import 'package:freezed_annotation/freezed_annotation.dart';

part 'papers.freezed.dart';
part 'papers.g.dart';

/// 文献的一个段落。`id` 即答案引用标记里的 `¶pid`。
@freezed
abstract class Paragraph with _$Paragraph {
  const factory Paragraph({
    required int id,
    @Default('') String sec,
    int? page,
    @Default('') String text,
  }) = _Paragraph;

  factory Paragraph.fromJson(Map<String, Object?> json) =>
      _$ParagraphFromJson(json);
}

@freezed
abstract class Fact with _$Fact {
  const Fact._();

  const factory Fact({
    @Default('') String fact,
    @Default('') String factZh,
    @Default('') String kind,
    int? pid,
    String? sec,
    int? page,
    @Default('') String quote,
    @Default(0) double score,
    @Default(false) bool verified,
  }) = _Fact;

  factory Fact.fromJson(Map<String, Object?> json) => _$FactFromJson(json);

  /// 事实类型中文文案（未知类型原样显示）。
  String get kindLabel => switch (kind) {
    'finding' => '研究发现',
    'method' => '研究方法',
    'background' => '背景',
    'limitation' => '局限性',
    _ => kind,
  };
}

/// 模型笔记里的一条引文及其核实结果。
@freezed
abstract class VerifiedQuote with _$VerifiedQuote {
  const factory VerifiedQuote({
    @Default(0) int claimedPid,
    int? pid,
    String? sec,
    int? page,
    @Default('') String quote,
    @Default(0) double score,
    @Default(false) bool verified,
    String? noteSection,
    @Default(false) bool keyFinding,
  }) = _VerifiedQuote;

  factory VerifiedQuote.fromJson(Map<String, Object?> json) =>
      _$VerifiedQuoteFromJson(json);
}

/// 共享文献库中的一篇文献。
@freezed
abstract class PaperMeta with _$PaperMeta {
  const factory PaperMeta({
    required String key,
    @Default('') String pmid,
    @Default('') String doi,
    @Default('') String pmcid,
    @Default('') String title,
    @Default('') String year,
    @Default('') String journal,
    @Default('') String issn,
    @Default('') String quartile,
    @Default('') String authors,
    @Default('') String source,
    @Default(<String>[]) List<String> types,
    DateTime? indexedAt,
    @Default(0) int nParagraphs,
    @Default(0) int nFacts,
  }) = _PaperMeta;

  factory PaperMeta.fromJson(Map<String, Object?> json) =>
      _$PaperMetaFromJson(json);
}
