import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 引文文本：带高亮底色的直引显示（核实引文列表、事实列表用）。
class QuoteHighlight extends StatelessWidget {
  const QuoteHighlight({super.key, required this.quote, this.maxLines});

  final String quote;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = quote.trim();
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: YaoeTokens.space2,
        vertical: YaoeTokens.space1,
      ),
      decoration: BoxDecoration(
        color: context.yaoe.highlight,
        borderRadius: BorderRadius.circular(YaoeTokens.radiusSm),
      ),
      child: Text(
        '“$text”',
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
