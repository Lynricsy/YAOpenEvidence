import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/models/literature.dart';
import '../../shared/widgets/filter_pickers.dart';
import 'literature_controller.dart';

class LiteratureFilterPanel extends StatelessWidget {
  const LiteratureFilterPanel({
    super.key,
    required this.filters,
    required this.source,
    required this.onChanged,
  });

  final LiteratureFilters filters;
  final LiteratureSource source;
  final ValueChanged<LiteratureFilters> onChanged;

  static const _types = <String>[
    'Review',
    'Clinical Trial',
    'Randomized Controlled Trial',
    'Meta-Analysis',
    'Systematic Review',
    'Observational Study',
  ];

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: const Text('高级筛选'),
    childrenPadding: const EdgeInsets.only(bottom: YaoeTokens.space4),
    children: [
      YaoeYearPicker(
        mode: filters.yearMode,
        years: filters.years,
        yearFrom: filters.yearFrom,
        yearTo: filters.yearTo,
        onModeChanged: (value) => onChanged(filters.copyWith(yearMode: value)),
        onYearsChanged: (value) => onChanged(filters.copyWith(years: value)),
        onRangeChanged: (from, to) =>
            onChanged(filters.copyWith(yearFrom: from, yearTo: to)),
        errorText: filters.rangeError,
      ),
      const SizedBox(height: YaoeTokens.space4),
      QuartilePicker(
        quartiles: filters.quartiles,
        onChanged: (value) => onChanged(filters.copyWith(quartiles: value)),
      ),
      const SizedBox(height: YaoeTokens.space4),
      JournalPicker(
        journals: filters.journals,
        onChanged: (value) => onChanged(filters.copyWith(journals: value)),
      ),
      const SizedBox(height: YaoeTokens.space4),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('文献类型', style: Theme.of(context).textTheme.labelLarge),
      ),
      const SizedBox(height: YaoeTokens.space2),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: YaoeTokens.space2,
          runSpacing: YaoeTokens.space2,
          children: [
            for (final type in _types)
              FilterChip(
                label: Text(type),
                selected: filters.publicationTypes.contains(type),
                onSelected: (selected) => onChanged(
                  filters.copyWith(
                    publicationTypes: selected
                        ? [...filters.publicationTypes, type]
                        : filters.publicationTypes.where((v) => v != type).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('仅开放获取'),
        subtitle: const Text('仅 Semantic Scholar 有效'),
        value: filters.openAccessOnly,
        onChanged: source == LiteratureSource.s2
            ? (value) => onChanged(filters.copyWith(openAccessOnly: value))
            : null,
      ),
    ],
  );
}
