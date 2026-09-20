import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/ask_filters.dart' show YearMode;
import '../../core/models/literature.dart';
import '../../shared/widgets/filter_pickers.dart';
import '../../shared/widgets/surface.dart';
import 'literature_controller.dart';

/// 文献类型的中文标签；值仍是上游接受的英文名。
const _typeLabels = <String, String>{
  'Review': '综述',
  'Systematic Review': '系统综述',
  'Meta-Analysis': '荟萃分析',
  'Randomized Controlled Trial': '随机对照试验',
  'Clinical Trial': '临床试验',
  'Observational Study': '观察性研究',
};

/// 查文献的筛选面板（放进 `showAdaptiveSheet`）。
class LiteratureFilterPanel extends StatelessWidget {
  const LiteratureFilterPanel({
    super.key,
    required this.filters,
    required this.source,
    required this.limit,
    required this.onChanged,
    required this.onLimitChanged,
  });

  final LiteratureFilters filters;
  final LiteratureSource source;
  final int limit;
  final ValueChanged<LiteratureFilters> onChanged;
  final ValueChanged<int> onLimitChanged;

  /// 入口按钮上的一行摘要；全默认时为 null。
  static String? summarize(LiteratureFilters filters) {
    final parts = [
      switch (filters.yearMode) {
        YearMode.any => '',
        YearMode.recent => '近 ${filters.years} 年',
        YearMode.range =>
          '${filters.yearFrom ?? ''}–${filters.yearTo ?? ''}'.replaceAll(
            RegExp(r'^–|–$'),
            '',
          ),
      },
      if (filters.quartiles.isNotEmpty)
        (filters.quartiles.toList()..sort()).map((q) => 'Q$q').join('/'),
      if (filters.publicationTypes.isNotEmpty)
        '${filters.publicationTypes.length} 种类型',
      if (filters.journals.isNotEmpty) '${filters.journals.length} 本期刊',
      if (filters.openAccessOnly) '仅开放获取',
    ].where((part) => part.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PicoSeekTokens.pageInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('返回条数', style: theme.textTheme.labelLarge),
                const SizedBox(height: PicoSeekTokens.space2),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 10, label: Text('10 条')),
                    ButtonSegment(value: 20, label: Text('20 条')),
                    ButtonSegment(value: 30, label: Text('30 条')),
                  ],
                  selected: {limit},
                  onSelectionChanged: (values) => onLimitChanged(values.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: PicoSeekTokens.space3),
          FilterGroup(
            child: PicoSeekYearPicker(
              mode: filters.yearMode,
              years: filters.years,
              yearFrom: filters.yearFrom,
              yearTo: filters.yearTo,
              onModeChanged: (value) =>
                  onChanged(filters.copyWith(yearMode: value)),
              onYearsChanged: (value) =>
                  onChanged(filters.copyWith(years: value)),
              onRangeChanged: (from, to) =>
                  onChanged(filters.copyWith(yearFrom: from, yearTo: to)),
              errorText: filters.rangeError,
            ),
          ),
          const SizedBox(height: PicoSeekTokens.space3),
          FilterGroup(
            child: QuartilePicker(
              quartiles: filters.quartiles,
              onChanged: (value) =>
                  onChanged(filters.copyWith(quartiles: value)),
            ),
          ),
          const SizedBox(height: PicoSeekTokens.space3),
          FilterGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('文献类型', style: theme.textTheme.labelLarge),
                const SizedBox(height: PicoSeekTokens.space2),
                Wrap(
                  spacing: PicoSeekTokens.space2,
                  runSpacing: PicoSeekTokens.space2,
                  children: [
                    for (final entry in _typeLabels.entries)
                      FilterChip(
                        label: Text(entry.value),
                        selected: filters.publicationTypes.contains(entry.key),
                        onSelected: (selected) => onChanged(
                          filters.copyWith(
                            publicationTypes: selected
                                ? [...filters.publicationTypes, entry.key]
                                : filters.publicationTypes
                                      .where((v) => v != entry.key)
                                      .toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PicoSeekTokens.space3),
          FilterGroup(
            child: JournalPicker(
              journals: filters.journals,
              onChanged: (value) =>
                  onChanged(filters.copyWith(journals: value)),
            ),
          ),
          const SizedBox(height: PicoSeekTokens.space3),
          FilterGroup(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('仅开放获取', style: theme.textTheme.labelLarge),
              subtitle: const Text('仅 Semantic Scholar 有效'),
              value: filters.openAccessOnly,
              onChanged: source == LiteratureSource.s2
                  ? (value) =>
                        onChanged(filters.copyWith(openAccessOnly: value))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
