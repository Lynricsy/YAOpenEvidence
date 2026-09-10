import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// 答案页的六个模块。展示元数据固定在这里，不用模型写的标签文字。
enum AnswerModule { conclusion, evidence, picos, caveats, sources, kb }

extension AnswerModuleStyle on AnswerModule {
  String get title => switch (this) {
    AnswerModule.conclusion => '结论',
    AnswerModule.evidence => '证据',
    AnswerModule.picos => 'PICOS 证据表',
    AnswerModule.caveats => '局限',
    AnswerModule.sources => '参考文献',
    AnswerModule.kb => '知识库补充',
  };

  String get eyebrow => switch (this) {
    AnswerModule.conclusion => 'BOTTOM LINE',
    AnswerModule.evidence => 'EVIDENCE',
    AnswerModule.picos => 'PICOS TABLE',
    AnswerModule.caveats => 'CAVEATS',
    AnswerModule.sources => 'REFERENCES',
    AnswerModule.kb => 'KNOWLEDGE BASE',
  };

  IconData get icon => switch (this) {
    AnswerModule.conclusion => Icons.verified_outlined,
    AnswerModule.evidence => Icons.science_outlined,
    AnswerModule.picos => Icons.table_chart_outlined,
    AnswerModule.caveats => Icons.warning_amber_outlined,
    AnswerModule.sources => Icons.menu_book_outlined,
    AnswerModule.kb => Icons.inventory_2_outlined,
  };

  /// 色调：结论/证据/PICOS 主色，局限警示色，参考文献与知识库中性色。
  Color tone(BuildContext context) => switch (this) {
    AnswerModule.conclusion ||
    AnswerModule.evidence ||
    AnswerModule.picos => Theme.of(context).colorScheme.primary,
    AnswerModule.caveats => context.yaoe.warning,
    AnswerModule.sources ||
    AnswerModule.kb => Theme.of(context).colorScheme.onSurfaceVariant,
  };
}

/// 模块分节头：图标方块 + 中文标题 + 英文小字 + 右侧计数，[rule] 时下方带分隔线。
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.module,
    this.count,
    this.rule = true,
  });

  final AnswerModule module;

  /// 右侧计数，如 `3 篇`、`5 条`；null 不显示。
  final String? count;
  final bool rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = module.tone(context);
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final count = this.count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
              ),
              child: Icon(module.icon, size: 16, color: tone),
            ),
            const SizedBox(width: 10),
            Text(module.title, style: theme.textTheme.titleMedium),
            const SizedBox(width: YaoeTokens.space2),
            Expanded(
              child: Text(
                module.eyebrow,
                style: muted?.copyWith(letterSpacing: 1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null)
              Padding(
                padding: const EdgeInsets.only(left: YaoeTokens.space2),
                child: Text(count, style: muted?.merge(monoStyle)),
              ),
          ],
        ),
        if (rule)
          const Padding(
            padding: EdgeInsets.only(top: YaoeTokens.space3),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}
