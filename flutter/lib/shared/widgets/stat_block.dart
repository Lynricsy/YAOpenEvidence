import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 统计块：大数字 + 标签 + 备注。
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.note,
  });

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(YaoeTokens.space4),
      decoration: BoxDecoration(
        color: context.yaoe.card,
        borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: YaoeTokens.space1),
          Text(value, style: theme.textTheme.headlineSmall),
          if (note != null) ...[
            const SizedBox(height: YaoeTokens.space1),
            Text(
              note!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
