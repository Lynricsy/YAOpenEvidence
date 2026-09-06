import 'package:freezed_annotation/freezed_annotation.dart';

part 'literature.freezed.dart';
part 'literature.g.dart';

/// `auto` 只作为请求参数出现；响应里只会是 `pubmed` / `s2`。
enum LiteratureSource {
  auto,
  pubmed,
  s2;

  String get label => switch (this) {
    LiteratureSource.auto => '自动',
    LiteratureSource.pubmed => 'PubMed',
    LiteratureSource.s2 => 'Semantic Scholar',
  };
}

@freezed
abstract class RankInfo with _$RankInfo {
  const factory RankInfo({
    @Default('') String title,
    @Default(<String>[]) List<String> issns,
    @Default(0) int zone,
    @Default('') String quartile,
    double? sjr,
    String? hIndex,
    @Default('') String categories,
    @Default(false) bool top,
    @Default('') String source,
  }) = _RankInfo;

  factory RankInfo.fromJson(Map<String, Object?> json) =>
      _$RankInfoFromJson(json);
}

@freezed
abstract class RankQuery with _$RankQuery {
  const factory RankQuery({
    @Default('') String issn,
    @Default('') String title,
  }) = _RankQuery;

  factory RankQuery.fromJson(Map<String, Object?> json) =>
      _$RankQueryFromJson(json);
}

@freezed
abstract class RankResult with _$RankResult {
  const factory RankResult({
    required RankQuery query,
    @Default(false) bool found,
    RankInfo? rank,
    @Default('') String label,
  }) = _RankResult;

  factory RankResult.fromJson(Map<String, Object?> json) =>
      _$RankResultFromJson(json);
}

/// 上游检索结果的一条记录。注意与 answer/paper 系不同：未知字段是 null 而非空串。
@freezed
abstract class LiteratureRecord with _$LiteratureRecord {
  const LiteratureRecord._();

  const factory LiteratureRecord({
    required LiteratureSource source,
    required String id,
    String? pmid,
    String? pmcid,
    String? doi,
    String? s2Id,
    @Default('') String title,
    String? abstract,
    String? year,
    String? journal,
    String? issn,
    @Default(<String>[]) List<String> authors,
    @Default(<String>[]) List<String> types,
    int? citedBy,
    String? openAccessPdf,
    String? tldr,
    RankInfo? rank,
  }) = _LiteratureRecord;

  factory LiteratureRecord.fromJson(Map<String, Object?> json) =>
      _$LiteratureRecordFromJson(json);

  /// 取全文时使用的标识：优先 PMCID，其次 PMID，再次 DOI。
  String? get fulltextIdent {
    for (final candidate in [pmcid, pmid, doi]) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}

@freezed
abstract class LiteratureSearchResult with _$LiteratureSearchResult {
  const factory LiteratureSearchResult({
    required LiteratureSource source,
    @Default(0) int total,
    @Default(<LiteratureRecord>[]) List<LiteratureRecord> items,
    String? fallbackReason,
  }) = _LiteratureSearchResult;

  factory LiteratureSearchResult.fromJson(Map<String, Object?> json) =>
      _$LiteratureSearchResultFromJson(json);
}

@freezed
abstract class FulltextSection with _$FulltextSection {
  const factory FulltextSection({
    @Default('') String title,
    @Default(0) int chars,
  }) = _FulltextSection;

  factory FulltextSection.fromJson(Map<String, Object?> json) =>
      _$FulltextSectionFromJson(json);
}

@freezed
abstract class FulltextResult with _$FulltextResult {
  const factory FulltextResult({
    @Default('') String pmcid,
    @Default('') String citation,
    @Default(<FulltextSection>[]) List<FulltextSection> sections,
    @Default('') String abstract,
    String? section,
    String? text,
    @Default(false) bool truncated,
  }) = _FulltextResult;

  factory FulltextResult.fromJson(Map<String, Object?> json) =>
      _$FulltextResultFromJson(json);
}
