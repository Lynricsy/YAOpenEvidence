import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/logic/ask_filters.dart';
import 'package:yaopenevidence/core/models/answers.dart';

void main() {
  const defaults = AskFilters();

  test('默认筛选只发 years，不发 year_from / keep_unranked', () {
    final payload = defaults.toAnswerCreate('  问题  ').toJson();
    expect(payload['question'], '问题');
    expect(payload['years'], 3);
    expect(payload.containsKey('year_from'), isFalse);
    expect(payload.containsKey('keep_unranked'), isFalse);
    expect(payload['kb_hits'], 0);
    expect(payload['max_chars'], 28000);
    expect(payload.containsKey('use_paywall'), isFalse);
  });

  test('codex 引擎不发流水线专属字段，但发 engine', () {
    final payload = defaults
        .copyWith(
          engine: AnswerEngine.codex,
          quartiles: [1],
          keepUnranked: true,
          kbHits: 5,
        )
        .toAnswerCreate('问题')
        .toJson();
    expect(payload['engine'], 'codex');
    expect(payload.containsKey('keep_unranked'), isFalse);
    expect(payload.containsKey('kb_hits'), isFalse);
    expect(payload.containsKey('max_chars'), isFalse);
    // 检索要求本身仍然交给模型。
    expect(payload['quartiles'], [1]);
    expect(payload['years'], 3);
  });

  test('options 往返带上引擎', () {
    final restored = AskFilters.fromOptions(const {'engine': 'codex'});
    expect(restored.engine, AnswerEngine.codex);
    expect(restored.normalized().engine, AnswerEngine.codex);
    expect(
      AskFilters.fromOptions(const <String, dynamic>{}).engine,
      AnswerEngine.ask,
    );
  });

  test('自定义区间 + 分区时发 year_from/year_to 与 keep_unranked，不发 years', () {
    final payload = defaults
        .copyWith(
          yearMode: YearMode.range,
          yearFrom: 2019,
          yearTo: 2023,
          quartiles: [1, 2],
          keepUnranked: true,
        )
        .toAnswerCreate('问题')
        .toJson();
    expect(payload.containsKey('years'), isFalse);
    expect(payload['year_from'], 2019);
    expect(payload['year_to'], 2023);
    expect(payload['keep_unranked'], isTrue);
    expect(payload['quartiles'], [1, 2]);
  });

  test('use_kb 关闭时 kb_hits 强制为 0', () {
    final payload = defaults
        .copyWith(useKb: false, kbHits: 12)
        .toAnswerCreate('问题')
        .toJson();
    expect(payload['use_kb'], isFalse);
    expect(payload['kb_hits'], 0);
  });

  test('options 往返保持一致', () {
    final normalized = defaults
        .copyWith(
          yearMode: YearMode.range,
          yearFrom: 2015,
          yearTo: 2020,
          quartiles: [2, 1],
          keepUnranked: true,
          journals: ['Nature ', 'nature', 'lancet'],
          papers: 12,
          kbHits: 5,
        )
        .normalized(currentYear: 2026);

    final restored = AskFilters.fromOptions(const {
      'years': null,
      'year_from': 2015,
      'year_to': 2020,
      'quartiles': [1, 2],
      'keep_unranked': true,
      'journals': ['nature', 'lancet'],
      'papers': 12,
      'use_kb': true,
      'kb_hits': 5,
      'max_chars': 28000,
    }).normalized(currentYear: 2026);

    expect(restored, normalized);
    expect(normalized.journals, ['nature', 'lancet']);
  });

  test('越界取值回落默认', () {
    final normalized = defaults
        .copyWith(
          papers: 99,
          years: 0,
          kbHits: 50,
          maxChars: 100,
          quartiles: [4, 4, 9, 1],
        )
        .normalized(currentYear: 2026);
    expect(normalized.papers, 8);
    expect(normalized.years, 3);
    expect(normalized.kbHits, 0);
    expect(normalized.maxChars, 28000);
    expect(normalized.quartiles, [1, 4]);
  });

  test('年份区间校验', () {
    var filters = defaults.copyWith(yearMode: YearMode.range);
    expect(filters.isYearRangeValid(currentYear: 2026), isFalse); // 缺起始年
    filters = filters.copyWith(yearFrom: 2020);
    expect(filters.isYearRangeValid(currentYear: 2026), isTrue); // 至今
    filters = filters.copyWith(yearTo: 2019);
    expect(filters.isYearRangeValid(currentYear: 2026), isFalse); // 结束早于起始
    filters = filters.copyWith(yearTo: 2030);
    expect(filters.isYearRangeValid(currentYear: 2026), isFalse); // 结束超过今年
  });

  test('摘要文案', () {
    expect(defaults.summary, '近3年 · 分区不限 · 8 篇');
    var filters = defaults.copyWith(
      quartiles: [1, 2],
      keepUnranked: true,
      journals: ['nature', 'lancet'],
    );
    expect(filters.summary, '近3年 · Q1/Q2 + 未收录 · 期刊含 nature|lancet · 8 篇');
    filters = filters.copyWith(yearMode: YearMode.range, yearFrom: 2019);
    expect(filters.summary, startsWith('2019–至今'));
    filters = filters.copyWith(yearMode: YearMode.any);
    expect(filters.summary, startsWith('年份不限'));
  });

  test('持久化 JSON 往返', () {
    final filters = defaults.copyWith(
      yearMode: YearMode.any,
      journals: ['nature'],
      useKb: false,
    );
    expect(AskFilters.fromJson(filters.toJson()), filters);
  });
}
