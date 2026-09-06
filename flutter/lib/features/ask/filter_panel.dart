import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/ask_filters.dart';
import '../../shared/widgets/filter_pickers.dart';
import 'ask_state.dart';

/// 提问筛选面板。宽屏常驻左侧 280 px，窄屏进 [FilterSheet]。
class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key, this.scrollable = true});

  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(askFiltersControllerProvider);
    final controller = ref.read(askFiltersControllerProvider.notifier);
    final currentYear = DateTime.now().year;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                filters.summary,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => controller.reset(),
              child: const Text('恢复默认'),
            ),
          ],
        ),
        const Divider(height: YaoeTokens.space4),
        QuartilePicker(
          quartiles: filters.quartiles,
          onChanged: (quartiles) =>
              controller.set(filters.copyWith(quartiles: quartiles)),
          keepUnranked: filters.keepUnranked,
          onKeepUnrankedChanged: (value) =>
              controller.set(filters.copyWith(keepUnranked: value)),
        ),
        const SizedBox(height: YaoeTokens.space4),
        YaoeYearPicker(
          mode: filters.yearMode,
          years: filters.years,
          yearFrom: filters.yearFrom,
          yearTo: filters.yearTo,
          onModeChanged: (mode) => controller.set(
            filters.copyWith(
              yearMode: mode,
              // 切到区间模式时给个合理起点，免得校验一直红着。
              yearFrom: mode == YearMode.range
                  ? (filters.yearFrom ?? currentYear - filters.years)
                  : filters.yearFrom,
            ),
          ),
          onYearsChanged: (years) =>
              controller.set(filters.copyWith(years: years)),
          onRangeChanged: (from, to) => controller.set(
            filters.copyWith(yearFrom: from, yearTo: to),
          ),
          errorText: filters.isYearRangeValid(currentYear: currentYear)
              ? null
              : '结束年不得早于起始年',
        ),
        const SizedBox(height: YaoeTokens.space4),
        JournalPicker(
          journals: filters.journals,
          onChanged: (journals) =>
              controller.set(filters.copyWith(journals: journals)),
        ),
        const SizedBox(height: YaoeTokens.space4),
        Text('阅读篇数', style: theme.textTheme.labelLarge),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 1,
                max: 30,
                divisions: 29,
                value: filters.papers.clamp(1, 30).toDouble(),
                label: '${filters.papers} 篇',
                onChanged: (value) =>
                    controller.set(filters.copyWith(papers: value.round())),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${filters.papers} 篇',
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text('写入并使用知识库', style: theme.textTheme.labelLarge),
          subtitle: Text(
            '关闭后本次不写入知识库，也不追加检索命中',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          value: filters.useKb,
          onChanged: (value) => controller.set(
            filters.copyWith(useKb: value, kbHits: value ? filters.kbHits : 0),
          ),
        ),
        Text('附加知识库命中', style: theme.textTheme.labelLarge),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 0,
                max: 20,
                divisions: 20,
                value: filters.useKb
                    ? filters.kbHits.clamp(0, 20).toDouble()
                    : 0,
                label: '${filters.useKb ? filters.kbHits : 0} 条',
                onChanged: filters.useKb
                    ? (value) => controller.set(
                        filters.copyWith(kbHits: value.round()),
                      )
                    : null,
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${filters.useKb ? filters.kbHits : 0} 条',
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: YaoeTokens.space3),
        Text('单篇字符预算', style: theme.textTheme.labelLarge),
        const SizedBox(height: YaoeTokens.space2),
        DropdownButtonFormField<int>(
          initialValue: AskFilters.maxCharsOptions.contains(filters.maxChars)
              ? filters.maxChars
              : 28000,
          isExpanded: true,
          items: [
            for (final option in AskFilters.maxCharsOptions)
              DropdownMenuItem(value: option, child: Text('$option 字符')),
          ],
          onChanged: (value) => controller.set(
            filters.copyWith(maxChars: value ?? filters.maxChars),
          ),
        ),
      ],
    );

    return scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(YaoeTokens.space4),
            child: content,
          )
        : Padding(
            padding: const EdgeInsets.all(YaoeTokens.space4),
            child: content,
          );
  }
}

/// 宽屏常驻筛选列。
class FilterColumn extends StatelessWidget {
  const FilterColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: const FilterPanel(),
    );
  }
}
