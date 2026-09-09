import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/models/answers.dart';
import '../../shared/widgets/badges.dart';

/// 一条智能体会话的全部回合：追问把上下文摊平在页面上，不用回历史里翻。
class ThreadNav extends StatelessWidget {
  const ThreadNav({super.key, required this.turns, required this.currentId});

  final List<AnswerSummary> turns;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = turns.indexWhere((t) => t.id == currentId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(YaoeTokens.space3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '对话脉络 · 第 ${at + 1}/${turns.length} 轮',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: YaoeTokens.space2),
          for (final (index, turn) in turns.indexed)
            _TurnRow(
              index: index,
              turn: turn,
              current: turn.id == currentId,
            ),
        ],
      ),
    );
  }
}

class _TurnRow extends StatelessWidget {
  const _TurnRow({
    required this.index,
    required this.turn,
    required this.current,
  });

  final int index;
  final AnswerSummary turn;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = current
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: current ? null : () => context.go('/a/${turn.id}'),
      borderRadius: BorderRadius.circular(YaoeTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: YaoeTokens.space1),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ),
            const SizedBox(width: YaoeTokens.space2),
            Expanded(
              child: Text(
                turn.question,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: current ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (turn.status != AnswerStatus.ready) ...[
              const SizedBox(width: YaoeTokens.space2),
              StatusBadge(status: turn.status),
            ],
          ],
        ),
      ),
    );
  }
}
