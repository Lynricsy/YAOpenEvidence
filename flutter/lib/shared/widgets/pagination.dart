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

  /// 是否有页可换。列表用它判断要不要在末尾插入换页器，免得为一个空 widget
  /// 多留一条分隔间距。
  static bool isUseful({
    required int total,
    required int limit,
    required int offset,
  }) => total > limit || offset > 0;

  @override
  Widget build(BuildContext context) {
    if (!isUseful(total: total, limit: limit, offset: offset)) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final first = total == 0 ? 0 : offset + 1;
    final last = offset + limit > total ? total : offset + limit;
    final hasPrevious = offset > 0;
    final hasNext = last < total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PicoSeekTokens.space3),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.outlined(
              tooltip: '上一页',
              onPressed: hasPrevious
                  ? () => onChange((offset - limit).clamp(0, total))
                  : null,
              icon: const Icon(Icons.chevron_left, size: 18),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PicoSeekTokens.space3,
              ),
              child: Text(
                '第 $first–$last 条 / 共 ${formatCount(total)} 条',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: '下一页',
              onPressed: hasNext ? () => onChange(offset + limit) : null,
              icon: const Icon(Icons.chevron_right, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
