import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/logic/tool_labels.dart';
import '../../core/models/tool_call.dart';

/// 智能体的检索轨迹：实时（[live]）与落库两处共用同一行结构。
class TraceList extends StatelessWidget {
  const TraceList({super.key, required this.calls, this.live = false});

  final List<ToolCall> calls;

  /// 实时轨迹里 started 的行会转圈；落库轨迹只有终态。
  final bool live;

  @override
  Widget build(BuildContext context) {
    if (calls.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final call in calls)
          Padding(
            padding: const EdgeInsets.only(bottom: PicoSeekTokens.space2),
            child: _TraceRow(call: call, live: live),
          ),
      ],
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.call, required this.live});

  final ToolCall call;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = describeToolArgs(call.args);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(PicoSeekTokens.radiusMd),
          ),
          child: Icon(
            toolIcon(call.tool),
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: PicoSeekTokens.space2),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                toolLabel(call.server, call.tool),
                style: theme.textTheme.bodyMedium,
              ),
              if (args.isNotEmpty) ...[
                const SizedBox(width: PicoSeekTokens.space1),
                Expanded(
                  child: Text(
                    args,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: PicoSeekTokens.space2),
        _TraceStatus(call: call, live: live),
      ],
    );
  }
}

class _TraceStatus extends StatelessWidget {
  const _TraceStatus({required this.call, required this.live});

  final ToolCall call;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (call.status) {
      case ToolCallStatus.started:
        return SizedBox.square(
          dimension: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            // 落库轨迹里不该出现 started；万一出现也别永远转圈骗人。
            value: live ? null : 1,
          ),
        );
      case ToolCallStatus.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: context.picoseek.success),
            const SizedBox(width: PicoSeekTokens.space1),
            Text(
              formatDuration(call.durationMs),
              style: theme.textTheme.labelSmall?.merge(monoStyle).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      case ToolCallStatus.failed:
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, size: 14, color: theme.colorScheme.error),
              const SizedBox(width: PicoSeekTokens.space1),
              Flexible(
                child: Text(
                  call.error ?? '失败',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
