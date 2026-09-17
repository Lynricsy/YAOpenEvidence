import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/job_live.dart';
import '../../core/models/answers.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/surface.dart';
import 'job_live_monitor.dart';
import 'trace_list.dart';

/// 任务进度。标准引擎是阶段流水线 + 当前阶段进度 + 检索摘要；
/// 智能体引擎没有固定阶段，改用一行状态 + 检索轨迹。运行日志刻意不展示。
class ProgressPipeline extends StatelessWidget {
  const ProgressPipeline({
    super.key,
    required this.state,
    this.stages = StageKey.askPipeline,
    this.engine = AnswerEngine.ask,
    required this.onCandidateTap,
    this.onCancel,
    this.cancelRequested = false,
  });

  final JobLiveState state;
  final List<StageKey> stages;
  final AnswerEngine engine;

  /// 点击候选文献卡（进行中时材料可能还没生成）。
  final void Function(String pmid) onCandidateTap;

  /// 取消任务；为 null 时不显示取消入口（除非 [cancelRequested]）。
  final VoidCallback? onCancel;
  final bool cancelRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = state.live;
    final progress = live.progress;

    final codex = engine == AnswerEngine.codex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                codex ? '智能体检索' : '证据流水线',
                style: theme.textTheme.labelLarge,
              ),
            ),
            if (onCancel != null || cancelRequested)
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.stop_circle_outlined, size: 16),
                label: Text(cancelRequested ? '正在取消…' : '取消'),
              ),
          ],
        ),
        const SizedBox(height: YaoeTokens.space3),
        if (codex)
          // 轨迹本身就是进展，不用文字复述系统在干什么；
          // 还没有轨迹时只给一个转圈表示在跑。
          live.tools.isEmpty
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TraceList(calls: live.tools, live: true)
        else ...[
          _StageRow(
            stages: stages
                .where(
                  (stage) =>
                      stage != StageKey.kb || live.stages.containsKey(stage),
                )
                .toList(),
            live: live,
          ),
          if (progress != null) ...[
            const SizedBox(height: YaoeTokens.space3),
            Text(
              '${progress.stage.label}'
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
            if ((progress.title ?? '').isNotEmpty) ...[
              const SizedBox(height: YaoeTokens.space1),
              Text(
                progress.title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          if (live.search != null) ...[
            const SizedBox(height: YaoeTokens.space4),
            _SearchSummaryView(
              summary: live.search!,
              detail: live.stages[StageKey.search]?.detail ?? const {},
              onCandidateTap: onCandidateTap,
            ),
          ],
        ],
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.stages, required this.live});

  final List<StageKey> stages;
  final JobLive live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: YaoeTokens.space2,
      runSpacing: YaoeTokens.space2,
      children: [
        for (final stage in stages)
          _StageChip(
            label: stage.label,
            state: live.stages[stage],
            summary: live.stages[stage]?.status == StageStatus.finished
                ? stageSummary(stage, live.stages[stage]!.detail)
                : null,
            textTheme: theme.textTheme,
          ),
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.state,
    required this.summary,
    required this.textTheme,
  });

  final String label;
  final StageState? state;
  final String? summary;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.yaoe;
    final (Color color, Widget marker) = switch (state?.status) {
      StageStatus.finished => (
        colors.success,
        Icon(Icons.check, size: 12, color: colors.success),
      ),
      StageStatus.running => (
        theme.colorScheme.primary,
        _PulsingDot(color: theme.colorScheme.primary),
      ),
      null => (
        theme.colorScheme.onSurfaceVariant,
        Icon(
          Icons.circle_outlined,
          size: 10,
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
              Text(label, style: textTheme.labelMedium?.copyWith(color: color)),
              if ((summary ?? '').isNotEmpty)
                Text(
                  summary!,
                  style: textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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

class _SearchSummaryView extends StatelessWidget {
  const _SearchSummaryView({
    required this.summary,
    required this.detail,
    required this.onCandidateTap,
  });

  final SearchSummary summary;
  final Map<String, dynamic> detail;
  final void Function(String pmid) onCandidateTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stageSummary(StageKey.search, detail),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (summary.papers.isNotEmpty) ...[
          const SizedBox(height: YaoeTokens.space2),
          Wrap(
            spacing: YaoeTokens.space2,
            runSpacing: YaoeTokens.space2,
            children: [
              for (final paper in summary.papers)
                _CandidateCard(paper: paper, onTap: onCandidateTap),
            ],
          ),
        ],
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.paper, required this.onTap});

  final CandidatePaper paper;
  final void Function(String pmid) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pmid = paper.pmid ?? '';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: YaoeCard(
        onTap: pmid.isEmpty ? null : () => onTap(pmid),
        padding: const EdgeInsets.all(YaoeTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (paper.n != null) ...[
                  CitationSquare(n: paper.n!, size: 18),
                  const SizedBox(width: YaoeTokens.space2),
                ],
                Expanded(
                  child: Text(
                    paper.title ?? '（无标题）',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: YaoeTokens.space1),
            Text(
              [
                paper.journal ?? '',
                paper.year ?? '',
                paper.rankLabel ?? '',
              ].where((part) => part.isNotEmpty).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
