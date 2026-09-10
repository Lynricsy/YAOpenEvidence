import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/logic/ask_filters.dart';
import '../../core/models/answers.dart';
import '../../core/models/meta.dart';
import '../../shared/format.dart';
import '../../shared/widgets/filter_pickers.dart';
import '../../shared/widgets/surface.dart';
import 'ask_state.dart';
import 'filter_meta.dart';

/// 提问筛选面板。宽屏常驻左侧 320 px，窄屏进 [showFilterSheet]。
class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key, this.scrollable = true});

  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(askFiltersControllerProvider);
    final controller = ref.read(askFiltersControllerProvider.notifier);
    final currentYear = DateTime.now().year;

    // 分区依据：加载中/失败时都不显示，避免面板上多出一行没用的噪音
    final tables = ref.watch(rankTablesProvider).value;
    final rankWarning = tables != null && tables.tables.isEmpty
        ? '未加载分区表，Q1–Q4 筛选不会生效'
        : null;
    final rankCaption = tables == null || tables.tables.isEmpty
        ? null
        : '分区依据：${tables.tables.map(_describeTable).join('，')}';
    // 智能体引擎不走确定性流水线：与之无关的旋钮直接不渲染，
    // 留着只会让人以为它们还生效。
    final codex = filters.engine == AnswerEngine.codex;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filters.summary,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (codex)
          Padding(
            padding: const EdgeInsets.only(top: YaoeTokens.space2),
            child: Text(
              '智能体模式下，字符预算、知识库命中数与机构访问不生效；'
              '筛选条件会作为检索要求交给模型。',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: YaoeTokens.space3),
        FilterGroup(
          child: YaoeYearPicker(
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
            onRangeChanged: (from, to) =>
                controller.set(filters.copyWith(yearFrom: from, yearTo: to)),
            errorText: filters.isYearRangeValid(currentYear: currentYear)
                ? null
                : '结束年不得早于起始年',
          ),
        ),
        const SizedBox(height: YaoeTokens.space3),
        FilterGroup(
          child: QuartilePicker(
            quartiles: filters.quartiles,
            onChanged: (quartiles) =>
                controller.set(filters.copyWith(quartiles: quartiles)),
            keepUnranked: codex ? null : filters.keepUnranked,
            onKeepUnrankedChanged: codex
                ? null
                : (value) =>
                      controller.set(filters.copyWith(keepUnranked: value)),
            caption: rankCaption,
            warning: rankWarning,
          ),
        ),
        const SizedBox(height: YaoeTokens.space3),
        FilterGroup(
          child: JournalPicker(
            journals: filters.journals,
            onChanged: (journals) =>
                controller.set(filters.copyWith(journals: journals)),
          ),
        ),
        const SizedBox(height: YaoeTokens.space3),
        FilterGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      onChanged: (value) => controller.set(
                        filters.copyWith(papers: value.round()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '${filters.papers} 篇',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelMedium?.merge(monoStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: YaoeTokens.space3),
        FilterGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  filters.copyWith(
                    useKb: value,
                    kbHits: value ? filters.kbHits : 0,
                  ),
                ),
              ),
              if (!codex) ...[
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
                      width: 56,
                      child: Text(
                        '${filters.useKb ? filters.kbHits : 0} 条',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelMedium?.merge(monoStyle),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!codex) ...[
          const SizedBox(height: YaoeTokens.space3),
          FilterGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('单篇字符预算', style: theme.textTheme.labelLarge),
                const SizedBox(height: YaoeTokens.space2),
                DropdownButtonFormField<int>(
                  initialValue:
                      AskFilters.maxCharsOptions.contains(filters.maxChars)
                      ? filters.maxChars
                      : 28000,
                  isExpanded: true,
                  items: [
                    for (final option in AskFilters.maxCharsOptions)
                      DropdownMenuItem(
                        value: option,
                        child: Text('约 ${formatCount(option)} 字'),
                      ),
                  ],
                  onChanged: (value) => controller.set(
                    filters.copyWith(maxChars: value ?? filters.maxChars),
                  ),
                ),
                const SizedBox(height: YaoeTokens.space2),
                Text(
                  '每篇全文送入模型的字数上限，越大越全但更慢',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: YaoeTokens.space3),
          const FilterGroup(child: _PaywallRow()),
        ],
        const SizedBox(height: YaoeTokens.space3),
        Center(
          child: TextButton(
            onPressed: () => controller.reset(),
            child: const Text('恢复默认'),
          ),
        ),
      ],
    );

    return scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(YaoeTokens.pageInset),
            child: content,
          )
        : Padding(
            padding: const EdgeInsets.all(YaoeTokens.pageInset),
            child: content,
          );
  }
}

String _describeTable(RankTable table) {
  final name = table.source == 'scimago' ? 'SCImago' : table.file;
  final year = table.year == null ? '' : ' ${table.year}';
  return '$name$year（${table.journals} 刊）';
}

/// 机构订阅登录态的只读状态行：付费全文取不到时主人得知道是为什么。
class _PaywallRow extends ConsumerWidget {
  const _PaywallRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(paywallStatusProvider).value;
    if (status == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final String text;
    if (!status.playwrightAvailable) {
      text = '不可用（服务端未安装浏览器）';
    } else if (!status.configured) {
      text = '未配置，付费全文将回退到摘要';
    } else {
      final host = Uri.tryParse(status.finalUrl ?? '')?.host ?? '';
      final savedAt = status.savedAt == null
          ? ''
          : ' · ${formatDateTime(status.savedAt!)}';
      text = '已配置$savedAt${host.isEmpty ? '' : ' · $host'}';
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('机构访问', style: theme.textTheme.labelLarge),
        const SizedBox(width: YaoeTokens.space3),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
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
      width: 320,
      decoration: BoxDecoration(
        color: context.yaoe.sidebar,
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: const FilterPanel(),
    );
  }
}
