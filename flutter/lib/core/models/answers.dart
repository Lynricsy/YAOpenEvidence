import 'package:freezed_annotation/freezed_annotation.dart';

import 'kb.dart';
import 'papers.dart';

part 'answers.freezed.dart';
part 'answers.g.dart';

enum AnswerStatus {
  queued,
  running,
  ready,
  failed,
  cancelled;

  /// 任务尚未进入终态（需要 SSE / 轮询继续跟踪）。
  bool get isActive =>
      this == AnswerStatus.queued || this == AnswerStatus.running;
}

enum PaperSource {
  pmc,
  pdf,
  inst,
  abstract;

  String get label => switch (this) {
    PaperSource.pmc => '全文 · PMC',
    PaperSource.pdf => '全文 · PDF',
    PaperSource.inst => '全文 · 机构',
    PaperSource.abstract => '仅摘要',
  };
}

/// 后端未来新增来源时不至于整份答案解码失败。
const _sourceKey = JsonKey(unknownEnumValue: PaperSource.abstract);

@freezed
abstract class JobError with _$JobError {
  const factory JobError({
    @Default('') String code,
    @Default('') String message,
  }) = _JobError;

  factory JobError.fromJson(Map<String, Object?> json) =>
      _$JobErrorFromJson(json);
}

/// 一篇被阅读的文献在答案中的元信息。注意 `year` 是字符串，未知字段一律为 `''`。
@freezed
abstract class AnswerPaper with _$AnswerPaper {
  const factory AnswerPaper({
    required int n,
    @Default('') String pmid,
    @Default('') String doi,
    @Default('') String pmcid,
    @Default('') String title,
    @Default('') String year,
    @Default('') String journal,
    @Default('') String issn,
    @Default('') String authors,
    @Default('') String quartile,
    @Default('') String rankLabel,
    @_sourceKey @Default(PaperSource.abstract) PaperSource source,
    int? relevance,
    @Default(0) int nParagraphs,
    @Default(0) int nCitations,
    @Default(0) int nCitationsVerified,
  }) = _AnswerPaper;

  factory AnswerPaper.fromJson(Map<String, Object?> json) =>
      _$AnswerPaperFromJson(json);
}

/// 答案正文引用到的一个原文段落。
@freezed
abstract class Citation with _$Citation {
  const factory Citation({
    required int n,
    @Default('') String pmid,
    @Default(0) int pid,
    @Default('') String sec,
    int? page,
    @Default('') String text,
    @Default(<String>[]) List<String> quotes,
    @Default(false) bool fromMarker,
  }) = _Citation;

  factory Citation.fromJson(Map<String, Object?> json) =>
      _$CitationFromJson(json);
}

@freezed
abstract class AnswerSummary with _$AnswerSummary {
  const factory AnswerSummary({
    required String id,
    String? jobId,
    required AnswerStatus status,
    @Default('') String question,
    String? filtersLabel,
    int? nPapers,
    int? nFulltext,
    required DateTime createdAt,
    DateTime? finishedAt,
    JobError? error,
  }) = _AnswerSummary;

  factory AnswerSummary.fromJson(Map<String, Object?> json) =>
      _$AnswerSummaryFromJson(json);
}

@freezed
abstract class Answer with _$Answer {
  const factory Answer({
    required String id,
    String? jobId,
    required AnswerStatus status,
    @Default('') String question,
    String? filtersLabel,
    int? nPapers,
    int? nFulltext,
    required DateTime createdAt,
    DateTime? finishedAt,
    JobError? error,
    String? questionEn,
    @Default(<String>[]) List<String> queries,
    @Default(<String, dynamic>{}) Map<String, dynamic> options,
    DateTime? startedAt,
    @Default(<AnswerPaper>[]) List<AnswerPaper> papers,
    String? bodyMd,
    @Default(<Citation>[]) List<Citation> citations,
    @Default(<KbHit>[]) List<KbHit> kbHits,
  }) = _Answer;

  factory Answer.fromJson(Map<String, Object?> json) => _$AnswerFromJson(json);
}

/// 逐篇阅读材料：在 [AnswerPaper] 之上追加笔记、核实引文、事实与全文。
@freezed
abstract class AnswerPaperDetail with _$AnswerPaperDetail {
  const factory AnswerPaperDetail({
    required int n,
    @Default('') String pmid,
    @Default('') String doi,
    @Default('') String pmcid,
    @Default('') String title,
    @Default('') String year,
    @Default('') String journal,
    @Default('') String issn,
    @Default('') String authors,
    @Default('') String quartile,
    @Default('') String rankLabel,
    @_sourceKey @Default(PaperSource.abstract) PaperSource source,
    int? relevance,
    @Default(0) int nParagraphs,
    @Default(0) int nCitations,
    @Default(0) int nCitationsVerified,
    @Default('') String notesMd,
    @Default(<VerifiedQuote>[]) List<VerifiedQuote> citations,
    @Default(<Fact>[]) List<Fact> facts,
    @Default(<Paragraph>[]) List<Paragraph> paragraphs,
    @Default('') String fulltextMd,
  }) = _AnswerPaperDetail;

  factory AnswerPaperDetail.fromJson(Map<String, Object?> json) =>
      _$AnswerPaperDetailFromJson(json);
}

/// 创建问答任务的请求体。可选字段为 null 时不编码（后端对 years / year_from 互斥有校验）。
@freezed
abstract class AnswerCreate with _$AnswerCreate {
  const factory AnswerCreate({
    required String question,
    required int papers,
    int? years,
    int? yearFrom,
    int? yearTo,
    @Default(<int>[]) List<int> quartiles,
    @Default(<String>[]) List<String> journals,
    bool? keepUnranked,
    @Default(true) bool useKb,
    @Default(0) int kbHits,
    @Default(28000) int maxChars,
  }) = _AnswerCreate;

  factory AnswerCreate.fromJson(Map<String, Object?> json) =>
      _$AnswerCreateFromJson(json);
}
