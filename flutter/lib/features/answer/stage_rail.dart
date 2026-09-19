import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/ask_rail.dart';

/// 进度条数据：运行中的阶段计数（流水线）或后台写库篇数（答案页）。
typedef RailProgress = ({String label, int current, int total, String? detail});

/// 阶段节点条：运行中的流水线与答案页的后台写库共用同一套视觉语言。
class StageRail extends StatelessWidget {
  const StageRail({super.key, required this.nodes, this.progress});

  final List<AskRailNode> nodes;
  final RailProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = this.progress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: YaoeTokens.space2,
          runSpacing: YaoeTokens.space2,
          children: [
            for (final node in nodes)
              _StageChip(node: node, textTheme: theme.textTheme),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: YaoeTokens.space3),
          Text(
            '${progress.label}'
            '${progress.total > 0 ? ' ${progress.current}/${progress.total}' : ''}',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: YaoeTokens.space1),
          ClipRRect(
            borderRadius: BorderRadius.circular(YaoeTokens.radiusSm),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress.total > 0
                  ? (progress.current / progress.total).clamp(0.0, 1.0)
                  : null,
            ),
          ),
          if ((progress.detail ?? '').isNotEmpty) ...[
            const SizedBox(height: YaoeTokens.space1),
            Text(
              progress.detail!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.node, required this.textTheme});

  final AskRailNode node;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.yaoe;
    final muted = theme.colorScheme.onSurfaceVariant;
    final (Color color, Widget marker) = switch (node.status) {
      RailStatus.done => (
        colors.success,
        Icon(Icons.check, size: 12, color: colors.success),
      ),
      RailStatus.running => (
        theme.colorScheme.primary,
        _PulsingDot(color: theme.colorScheme.primary),
      ),
      // 排上队但还没轮到：时钟比空心圆更能说明「在等后台」。
      RailStatus.waiting => (
        theme.colorScheme.primary,
        Icon(Icons.schedule, size: 12, color: theme.colorScheme.primary),
      ),
      RailStatus.failed => (
        theme.colorScheme.error,
        Icon(Icons.error_outline, size: 12, color: theme.colorScheme.error),
      ),
      RailStatus.cancelled => (
        muted,
        Icon(Icons.block, size: 12, color: muted),
      ),
      RailStatus.todo => (
        muted,
        Icon(Icons.circle_outlined, size: 10, color: muted),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: YaoeTokens.space2 + 2,
        vertical: YaoeTokens.space1 + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: YaoeTokens.tintFillAlpha),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: YaoeTokens.tintBorderAlpha),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          marker,
          const SizedBox(width: YaoeTokens.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.label,
                style: textTheme.labelMedium?.copyWith(color: color),
              ),
              if ((node.hint ?? '').isNotEmpty)
                Text(
                  node.hint!,
                  style: textTheme.labelSmall?.copyWith(color: muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 进行中阶段的脉冲圆点。
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 尊重系统「减弱动效」；MediaQuery 只能在依赖就绪后读。
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: 0.4 + 0.6 * _controller.value),
      ),
    ),
  );
}
