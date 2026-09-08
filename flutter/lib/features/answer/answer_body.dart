import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/answer_sections.dart';
import '../../core/logic/citations.dart';
import '../../core/logic/markdown_document.dart';
import '../../core/models/answers.dart';
import '../../shared/widgets/markdown_view.dart';
import '../../shared/widgets/section_heading.dart';
import 'citation_chip.dart';
import 'picos_cards.dart';

/// 答案正文：裸标记按 `papers.length` 上限识别为引用芯片；正文按分节头切成
/// 「结论卡 / 证据 / PICOS 证据表 / 局限」模块。没有任何已知模块（旧答案渲染稿、
/// 模型没按格式写）时整段按单块渲染。
class AnswerBody extends StatelessWidget {
  const AnswerBody({
    super.key,
    required this.bodyMd,
    required this.papers,
    required this.onCitationTap,
  });

  final String bodyMd;
  final List<AnswerPaper> papers;
  final void Function(CitationRef ref) onCitationTap;

  int? get _citationLimit => papers.isEmpty ? null : papers.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    InlineSpan spanBuilder(
      BuildContext context,
      CitationRef ref_,
      String text,
    ) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: CitationChip(
          ref_: ref_,
          text: text,
          paper: papers.where((paper) => paper.n == ref_.n).firstOrNull,
          onTap: onCitationTap,
        ),
      ),
    );

    final sections = splitAnswerSections(bodyMd);
    if (!hasKnownSections(sections)) {
      return MarkdownDocumentView(
        blocks: parseMarkdown(bodyMd, citationLimit: _citationLimit),
        baseStyle: theme.textTheme.bodyLarge,
        citationSpanBuilder: spanBuilder,
        onCitationTap: onCitationTap,
      );
    }

    // 各节内的 MarkdownDocumentView 一律 selectable: false，整篇共用一个
    // SelectionArea，避免多个选区互相割裂。
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < sections.length; index++) ...[
            if (index > 0) const SizedBox(height: YaoeTokens.space6),
            _section(context, sections[index], spanBuilder),
          ],
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    AnswerSection section,
    CitationSpanBuilder spanBuilder,
  ) {
    final theme = Theme.of(context);
    final blocks = parseMarkdown(
      section.markdown,
      citationLimit: _citationLimit,
    );

    Widget document(List<MarkdownBlock> only) => MarkdownDocumentView(
      blocks: only,
      baseStyle: theme.textTheme.bodyLarge,
      citationSpanBuilder: spanBuilder,
      onCitationTap: onCitationTap,
      selectable: false,
    );

    switch (section.kind) {
      case AnswerSectionKind.conclusion:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(YaoeTokens.space4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                module: AnswerModule.conclusion,
                rule: false,
              ),
              const SizedBox(height: YaoeTokens.space3),
              document(blocks),
            ],
          ),
        );

      case AnswerSectionKind.evidence:
      case AnswerSectionKind.caveats:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              module: section.kind == AnswerSectionKind.evidence
                  ? AnswerModule.evidence
                  : AnswerModule.caveats,
            ),
            const SizedBox(height: YaoeTokens.space4),
            document(blocks),
          ],
        );

      case AnswerSectionKind.picos:
        final compact =
            MediaQuery.sizeOf(context).width < YaoeTokens.compactMaxWidth;
        final rows = blocks.whereType<MdTable>().firstOrNull?.rows.length ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              module: AnswerModule.picos,
              count: rows > 0 ? '$rows 篇' : null,
            ),
            const SizedBox(height: YaoeTokens.space4),
            for (final block in blocks)
              if (block is MdTable && compact)
                PicosCardList(
                  header: block.header,
                  rows: block.rows,
                  citationSpanBuilder: spanBuilder,
                )
              else
                document([block]),
          ],
        );

      case AnswerSectionKind.other:
        return document(blocks);
    }
  }
}
