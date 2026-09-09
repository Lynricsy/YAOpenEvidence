import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/answers.dart';

part 'ask_filters.freezed.dart';
part 'ask_filters.g.dart';

enum YearMode { any, recent, range }

int _currentYear() => DateTime.now().year;

int _clamp(int value, {required int fallback, required int min, required int max}) =>
    value >= min && value <= max ? value : fallback;

/// 提问筛选条件。取值夹紧规则逐字移植 `frontend/src/lib/filters.ts`。
@freezed
abstract class AskFilters with _$AskFilters {
  const AskFilters._();

  const factory AskFilters({
    @Default(AnswerEngine.ask) AnswerEngine engine,
    @Default(<int>[]) List<int> quartiles,
    @Default(false) bool keepUnranked,
    @Default(YearMode.recent) YearMode yearMode,
    @Default(3) int years,
    int? yearFrom,
    int? yearTo,
    @Default(<String>[]) List<String> journals,
    @Default(8) int papers,
    @Default(true) bool useKb,
    @Default(0) int kbHits,
    @Default(28000) int maxChars,
  }) = _AskFilters;

  factory AskFilters.fromJson(Map<String, Object?> json) =>
      _$AskFiltersFromJson(json);

  /// 从 `Answer.options` 还原筛选条件（用于「沿用此次筛选重新提问」）。
  factory AskFilters.fromOptions(Map<String, dynamic> options) {
    int? asInt(Object? raw) => raw is num ? raw.toInt() : null;
    final years = asInt(options['years']);
    final yearFrom = asInt(options['year_from']);
    return AskFilters(
      engine: options['engine'] == 'codex'
          ? AnswerEngine.codex
          : AnswerEngine.ask,
      quartiles: [
        ...?(options['quartiles'] as List?)?.map(asInt).whereType<int>(),
      ],
      keepUnranked: options['keep_unranked'] == true,
      yearMode: years != null
          ? YearMode.recent
          : (yearFrom != null ? YearMode.range : YearMode.any),
      years: years ?? 3,
      yearFrom: yearFrom,
      yearTo: asInt(options['year_to']),
      journals: [
        ...?(options['journals'] as List?)?.whereType<String>(),
      ],
      papers: asInt(options['papers']) ?? 8,
      useKb: options['use_kb'] as bool? ?? true,
      kbHits: asInt(options['kb_hits']) ?? 0,
      maxChars: asInt(options['max_chars']) ?? 28000,
    );
  }

  /// 供筛选表单使用的单篇字符预算候选值。
  static const maxCharsOptions = <int>[12000, 20000, 28000, 40000, 60000];

  /// 期刊快捷预设：展示名 → 实际关键词。
  static const journalPresets = <(String, String)>[
    ('Nature', 'nature'),
    ('Lancet', 'lancet'),
    ('NEJM', 'new england'),
    ('JAMA', 'jama'),
    ('BMJ', 'bmj'),
    ('Cell', 'cell'),
  ];

  /// 逐字段夹紧到后端接受的范围。越界或非法值一律回落默认值。
  AskFilters normalized({int? currentYear}) {
    final year = currentYear ?? _currentYear();
    final seen = <String>{};
    return AskFilters(
      engine: engine,
      quartiles: quartiles.where((q) => q >= 1 && q <= 4).toSet().toList()
        ..sort(),
      keepUnranked: keepUnranked,
      yearMode: yearMode,
      years: _clamp(years, fallback: 3, min: 1, max: 50),
      yearFrom: yearFrom == null
          ? null
          : _clamp(yearFrom!, fallback: 1900, min: 1900, max: 2100),
      yearTo: yearTo == null
          ? null
          : _clamp(yearTo!, fallback: year, min: 1900, max: 2100),
      journals: journals
          .map((j) => j.trim().toLowerCase())
          .where((j) => j.isNotEmpty && j.length <= 100)
          .where(seen.add)
          .toList(growable: false),
      papers: _clamp(papers, fallback: 8, min: 1, max: 30),
      useKb: useKb,
      kbHits: _clamp(kbHits, fallback: 0, min: 0, max: 20),
      maxChars: _clamp(maxChars, fallback: 28000, min: 4000, max: 60000),
    );
  }

  /// 自定义年份区间是否可提交。
  bool isYearRangeValid({int? currentYear}) {
    if (yearMode != YearMode.range) return true;
    final year = currentYear ?? _currentYear();
    final from = yearFrom;
    if (from == null || from < 1900 || from > year) return false;
    final to = yearTo;
    if (to == null) return true;
    return to >= from && to <= year;
  }

  /// 生成创建任务的请求体：years 与 year_from/year_to 互斥，
  /// keep_unranked 仅在选了分区时发送，且永不发送 use_paywall。
  ///
  /// 智能体引擎只发它真会用到的字段（镜像 `frontend/src/lib/filters.ts`）：
  /// 字符预算、知识库命中数与「含未收录期刊」在那条路径上不生效。
  AnswerCreate toAnswerCreate(String question) {
    final codex = engine == AnswerEngine.codex;
    return AnswerCreate(
      question: question.trim(),
      engine: engine,
      papers: papers,
      years: yearMode == YearMode.recent ? years : null,
      yearFrom: yearMode == YearMode.range ? yearFrom : null,
      yearTo: yearMode == YearMode.range ? yearTo : null,
      quartiles: quartiles,
      journals: journals,
      keepUnranked: (quartiles.isEmpty || codex) ? null : keepUnranked,
      useKb: useKb,
      kbHits: codex ? null : (useKb ? kbHits : 0),
      maxChars: codex ? null : maxChars,
    );
  }

  /// 一行式摘要，例如「近3年 · Q1/Q2 + 未收录 · 期刊含 nature|lancet · 8 篇」。
  String get summary {
    final parts = <String>[];
    switch (yearMode) {
      case YearMode.recent:
        parts.add('近$years年');
      case YearMode.range:
        parts.add('${yearFrom ?? '起始年'}–${yearTo ?? '至今'}');
      case YearMode.any:
        parts.add('年份不限');
    }
    if (quartiles.isEmpty) {
      parts.add('分区不限');
    } else {
      parts.add(
        quartiles.map((q) => 'Q$q').join('/') + (keepUnranked ? ' + 未收录' : ''),
      );
    }
    if (journals.isNotEmpty) parts.add('期刊含 ${journals.join('|')}');
    parts.add('$papers 篇');
    return parts.join(' · ');
  }
}
