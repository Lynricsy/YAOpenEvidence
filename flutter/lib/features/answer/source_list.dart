import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/citations.dart';
import '../../core/models/answers.dart';
import '../../core/models/kb.dart';
import '../../shared/external_links.dart';
import '../../shared/format.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/quote_highlight.dart';
import '../../shared/widgets/section_heading.dart';

/// 答案下方的来源列表。
class SourceList extends StatelessWidget {
  const SourceList({
    super.key,
    required this.papers,
    required this.bodyMd,
    required this.onOpen,
  });

  final List<AnswerPaper> papers;
  final String bodyMd;
  final void Function(CitationRef ref) onOpen;

  @override
  Widget build(BuildContext context) {
    if (papers.isEmpty) return const SizedBox.shrink();
    final counts = countMarkers(bodyMd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          module: AnswerModule.sources,
          count: '${papers.length} 篇',
        ),
        const SizedBox(height: YaoeTokens.space4),
        for (final paper in papers)
          Padding(
            padding: const EdgeInsets.only(bottom: YaoeTokens.space2),
            child: SourceCard(
              paper: paper,
              markerCount: counts[paper.n] ?? 0,
              onOpen: () => onOpen(CitationRef(paper.n, null)),
            ),
          ),
      ],
    );
  }
}

class SourceCard extends StatelessWidget {
  const SourceCard({
    super.key,
    required this.paper,
    required this.markerCount,
    required this.onOpen,
  });

  final AnswerPaper paper;
  final int markerCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CitationSquare(n: paper.n),
                const SizedBox(width: YaoeTokens.space3),
                Expanded(
                  child: Text(
                    paper.title.isEmpty ? '（无标题）' : paper.title,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: YaoeTokens.space2),
            Text(
              [
                paper.journal,
                paper.year,
              ].where((part) => part.isNotEmpty).join(' · '),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: YaoeTokens.space2),
            Wrap(
              spacing: YaoeTokens.space2,
              runSpacing: YaoeTokens.space1,
              children: [
                RankBadge(quartile: paper.quartile, label: paper.rankLabel),
                SourceBadge(source: paper.source),
                if (paper.nCitations > 0)
                  Pill(
                    text: '已核实 ${paper.nCitationsVerified}/${paper.nCitations}',
                    color: paper.nCitationsVerified == paper.nCitations
                        ? context.yaoe.success
                        : context.yaoe.warning,
                  ),
                if (markerCount > 0)
                  Pill(
                    text: '正文引用 $markerCount 处',
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: YaoeTokens.space2),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: YaoeTokens.space3,
                    children: [
                      MonoLabel(label: 'PMID', value: paper.pmid),
                      MonoLabel(label: 'DOI', value: paper.doi),
                    ],
                  ),
                ),
                ExternalLinkRow(
                  pmid: paper.pmid,
                  doi: paper.doi,
                  pmcid: paper.pmcid,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 「知识库补充」列表：本次问答额外用到的 KB 命中。
class KbSupplementList extends StatelessWidget {
  const KbSupplementList({super.key, required this.hits});

  final List<KbHit> hits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (hits.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(module: AnswerModule.kb, count: '${hits.length} 条'),
        const SizedBox(height: YaoeTokens.space4),
        for (final hit in hits)
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
                  Row(
                    children: [
                      Pill(
                        text: hit.kind.label,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: YaoeTokens.space2),
                      if (hit.verified != null)
                        VerifiedPill(verified: hit.verified!),
                      const Spacer(),
                      Text(
                        formatScore(hit.score),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: YaoeTokens.space2),
                  Text(
                    hit.textZh ?? hit.text,
                    style: theme.textTheme.bodySmall,
                  ),
                  if ((hit.quote ?? '').isNotEmpty) ...[
                    const SizedBox(height: YaoeTokens.space2),
                    QuoteHighlight(quote: hit.quote!, maxLines: 3),
                  ],
                  const SizedBox(height: YaoeTokens.space2),
                  Text(
                    [
                      hit.title,
                      hit.journal,
                      hit.year,
                      if (hit.pid != null) '¶${hit.pid}',
                    ].where((part) => part.isNotEmpty).join(' · '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
