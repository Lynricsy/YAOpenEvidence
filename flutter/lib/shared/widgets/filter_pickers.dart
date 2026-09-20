import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/ask_filters.dart';

/// 年份筛选：任意 / 近 N 年 / 自定义区间。提问页与查文献页共用。
class PicoSeekYearPicker extends StatelessWidget {
  const PicoSeekYearPicker({
    super.key,
    required this.mode,
    required this.years,
    required this.yearFrom,
    required this.yearTo,
    required this.onModeChanged,
    required this.onYearsChanged,
    required this.onRangeChanged,
    this.errorText,
  });

  final YearMode mode;
  final int years;
  final int? yearFrom;
  final int? yearTo;
  final ValueChanged<YearMode> onModeChanged;
  final ValueChanged<int> onYearsChanged;

  /// `(起始年, 结束年)`，null 表示不限。
  final void Function(int? from, int? to) onRangeChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;
    final yearOptions = [
      for (var year = currentYear; year >= 1900; year--) year,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('年份', style: theme.textTheme.labelLarge),
        const SizedBox(height: PicoSeekTokens.space2),
        SegmentedButton<YearMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: YearMode.any, label: Text('任意')),
            ButtonSegment(value: YearMode.recent, label: Text('近 N 年')),
            ButtonSegment(value: YearMode.range, label: Text('区间')),
          ],
          selected: {mode},
          onSelectionChanged: (selection) => onModeChanged(selection.first),
        ),
        if (mode == YearMode.recent) ...[
          const SizedBox(height: PicoSeekTokens.space2),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: 1,
                  max: 50,
                  divisions: 49,
                  value: years.clamp(1, 50).toDouble(),
                  label: '近 $years 年',
                  onChanged: (value) => onYearsChanged(value.round()),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text('$years 年', style: theme.textTheme.labelMedium),
              ),
            ],
          ),
        ],
        if (mode == YearMode.range) ...[
          const SizedBox(height: PicoSeekTokens.space2),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: yearFrom,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: '起始年'),
                  items: [
                    for (final year in yearOptions)
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (value) => onRangeChanged(value, yearTo),
                ),
              ),
              const SizedBox(width: PicoSeekTokens.space2),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: yearTo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: '结束年'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('至今')),
                    for (final year in yearOptions)
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (value) => onRangeChanged(yearFrom, value),
                ),
              ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: PicoSeekTokens.space1),
              child: Text(
                errorText!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// 期刊关键词输入：回车添加 chip，可删除；带常用预设。
class JournalPicker extends StatefulWidget {
  const JournalPicker({
    super.key,
    required this.journals,
    required this.onChanged,
    this.showPresets = true,
  });

  final List<String> journals;
  final ValueChanged<List<String>> onChanged;
  final bool showPresets;

  @override
  State<JournalPicker> createState() => _JournalPickerState();
}

class _JournalPickerState extends State<JournalPicker> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty || value.length > 100) return;
    if (widget.journals.contains(value)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.journals, value]);
    _controller.clear();
  }

  void _remove(String value) => widget.onChanged(
    widget.journals.where((item) => item != value).toList(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期刊关键词', style: theme.textTheme.labelLarge),
        const SizedBox(height: PicoSeekTokens.space2),
        TextField(
          controller: _controller,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          decoration: const InputDecoration(
            hintText: '输入后回车添加，如 lancet',
            prefixIcon: Icon(Icons.menu_book_outlined, size: 18),
          ),
          onSubmitted: _add,
        ),
        if (widget.journals.isNotEmpty) ...[
          const SizedBox(height: PicoSeekTokens.space2),
          Wrap(
            spacing: PicoSeekTokens.space2,
            runSpacing: PicoSeekTokens.space1,
            children: [
              for (final journal in widget.journals)
                InputChip(
                  label: Text(journal),
                  onDeleted: () => _remove(journal),
                ),
            ],
          ),
        ],
        if (widget.showPresets) ...[
          const SizedBox(height: PicoSeekTokens.space2),
          Wrap(
            spacing: PicoSeekTokens.space2,
            runSpacing: PicoSeekTokens.space1,
            children: [
              for (final (label, value) in AskFilters.journalPresets)
                ActionChip(
                  label: Text(label),
                  onPressed: widget.journals.contains(value)
                      ? null
                      : () => _add(value),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 分区多选（Q1–Q4）+「保留未收录」。
///
/// [caption] 说明分区依据（哪几张表、多少刊），[warning] 用于「没有表，筛选不生效」
/// 这类必须让主人看见的情况；两者互斥，warning 优先。
class QuartilePicker extends StatelessWidget {
  const QuartilePicker({
    super.key,
    required this.quartiles,
    required this.onChanged,
    this.keepUnranked,
    this.onKeepUnrankedChanged,
    this.caption,
    this.warning,
  });

  final List<int> quartiles;
  final ValueChanged<List<int>> onChanged;
  final bool? keepUnranked;
  final ValueChanged<bool>? onKeepUnrankedChanged;
  final String? caption;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期刊分区', style: theme.textTheme.labelLarge),
        const SizedBox(height: PicoSeekTokens.space2),
        if (warning != null)
          Padding(
            padding: const EdgeInsets.only(bottom: PicoSeekTokens.space2),
            child: Text(
              warning!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.picoseek.warning,
              ),
            ),
          )
        else if (caption != null)
          Padding(
            padding: const EdgeInsets.only(bottom: PicoSeekTokens.space2),
            child: Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        SegmentedButton<int>(
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 1, label: Text('Q1')),
            ButtonSegment(value: 2, label: Text('Q2')),
            ButtonSegment(value: 3, label: Text('Q3')),
            ButtonSegment(value: 4, label: Text('Q4')),
          ],
          selected: quartiles.toSet(),
          onSelectionChanged: (selection) =>
              onChanged(selection.toList()..sort()),
        ),
        if (keepUnranked != null && onKeepUnrankedChanged != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text('保留未收录期刊', style: theme.textTheme.labelLarge),
            value: keepUnranked!,
            // 未选分区时该开关无意义（后端也不接收）。
            onChanged: quartiles.isEmpty ? null : onKeepUnrankedChanged,
          ),
      ],
    );
  }
}
