import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/logic/citations.dart';
import '../../core/models/answers.dart';
import '../../core/models/jobs.dart';

/// 通用小徽标：底色为 [color] 的 10%，描边 30%。
class Pill extends StatelessWidget {
  const Pill({super.key, required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(YaoeTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

String answerStatusLabel(AnswerStatus status) => switch (status) {
  AnswerStatus.queued => '排队中',
  AnswerStatus.running => '进行中',
  AnswerStatus.ready => '已完成',
  AnswerStatus.failed => '失败',
  AnswerStatus.cancelled => '已取消',
};

String jobStatusLabel(JobStatus status) => switch (status) {
  JobStatus.queued => '排队中',
  JobStatus.running => '进行中',
  JobStatus.succeeded => '已完成',
  JobStatus.failed => '失败',
  JobStatus.cancelled => '已取消',
};

/// 答案状态徽标。
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final AnswerStatus status;

  @override
  Widget build(BuildContext context) => Pill(
    text: answerStatusLabel(status),
    color: answerStatusColor(context, status),
  );
}

/// 任务状态徽标。
class JobStatusBadge extends StatelessWidget {
  const JobStatusBadge({super.key, required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) => Pill(
    text: jobStatusLabel(status),
    color: jobStatusColor(context, status),
  );
}

/// 期刊分区徽标；未收录用灰色。
class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.quartile, this.label});

  final String quartile;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        context.yaoe.quartile(quartile) ?? theme.colorScheme.onSurfaceVariant;
    final text = (label ?? '').isNotEmpty
        ? label!
        : (quartile.isEmpty ? '未收录' : quartile.toUpperCase());
    return Pill(text: text, color: color);
  }
}

/// 全文来源徽标。
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source});

  final PaperSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.yaoe;
    final color = switch (source) {
      PaperSource.pmc || PaperSource.pdf => colors.success,
      PaperSource.inst => colors.info,
      PaperSource.abstract => theme.colorScheme.onSurfaceVariant,
    };
    return Pill(text: source.label, color: color);
  }
}

/// 引文核实状态。
class VerifiedPill extends StatelessWidget {
  const VerifiedPill({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    final colors = context.yaoe;
    return Pill(
      text: verified ? '已核实' : '未核实',
      color: verified ? colors.success : colors.warning,
      icon: verified ? Icons.verified_outlined : Icons.help_outline,
    );
  }
}

/// 引用编号方块（等宽数字，色板色）。
class CitationSquare extends StatelessWidget {
  const CitationSquare({super.key, required this.n, this.size = 22});

  final int n;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final color = citationColor(n, dark: dark);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(YaoeTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        '$n',
        style: theme.textTheme.labelSmall
            ?.merge(monoStyle)
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 等宽标识文本（PMID / DOI / PMCID）。
class MonoLabel extends StatelessWidget {
  const MonoLabel({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return SelectableText(
      '$label $value',
      style: theme.textTheme.labelSmall?.merge(monoStyle).copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
