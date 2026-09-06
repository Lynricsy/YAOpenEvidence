import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../format.dart';

/// 分页控件：「第 x–y 条 / 共 n 条」+ 上一页 / 下一页。
class Pager extends StatelessWidget {
  const Pager({
    super.key,
    required this.total,
    required this.limit,
    required this.offset,
    required this.onChange,
  });

  final int total;
  final int limit;
  final int offset;
  final void Function(int offset) onChange;

  @override
  Widget build(BuildContext context) {
    if (total <= limit && offset == 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final first = total == 0 ? 0 : offset + 1;
    final last = offset + limit > total ? total : offset + limit;
    final hasPrevious = offset > 0;
    final hasNext = last < total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: YaoeTokens.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '第 $first–$last 条 / 共 ${formatCount(total)} 条',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: hasPrevious
                    ? () => onChange((offset - limit).clamp(0, total))
                    : null,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('上一页'),
              ),
              const SizedBox(width: YaoeTokens.space2),
              OutlinedButton.icon(
                onPressed: hasNext ? () => onChange(offset + limit) : null,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('下一页'),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
