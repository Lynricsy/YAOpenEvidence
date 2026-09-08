import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/markdown_document.dart';
import '../../shared/widgets/markdown_view.dart';

/// 窄屏下的 PICOS 证据表：每个表体行一张卡，卡内首行是引用芯片，
/// 其余按表头顺序逐列一行（标签取表格实际表头文字）。
class PicosCardList extends StatelessWidget {
  const PicosCardList({
    super.key,
    required this.header,
    required this.rows,
    this.citationSpanBuilder,
  });

  final List<List<InlineRun>> header;
  final List<List<List<InlineRun>>> rows;
  final CitationSpanBuilder? citationSpanBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: YaoeTokens.space2),
            child: Container(
              padding: const EdgeInsets.all(YaoeTokens.space3),
              decoration: BoxDecoration(
                color: context.yaoe.card,
                borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (row.isNotEmpty)
                    MarkdownInlineText(
                      runs: row.first,
                      style: theme.textTheme.labelLarge,
                      citationSpanBuilder: citationSpanBuilder,
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: YaoeTokens.space2),
                    child: Divider(height: 1),
                  ),
                  for (var i = 1; i < math.min(header.length, row.length); i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: YaoeTokens.space2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 88,
                            child: Text(plainTextOf(header[i]), style: muted),
                          ),
                          Expanded(
                            child: MarkdownInlineText(
                              runs: row[i],
                              style: theme.textTheme.bodySmall,
                              citationSpanBuilder: citationSpanBuilder,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
