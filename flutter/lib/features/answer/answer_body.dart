import 'package:flutter/material.dart';

import '../../core/logic/citations.dart';
import '../../core/logic/markdown_document.dart';
import '../../core/models/answers.dart';
import '../../shared/widgets/markdown_view.dart';
import 'citation_chip.dart';

/// 答案正文：裸标记按 `papers.length` 上限识别为引用芯片。
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = parseMarkdown(
      bodyMd,
      citationLimit: papers.isEmpty ? null : papers.length,
    );
    return MarkdownDocumentView(
      blocks: blocks,
      baseStyle: theme.textTheme.bodyLarge,
      citationSpanBuilder: (context, ref_, text) => WidgetSpan(
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
      ),
      onCitationTap: onCitationTap,
    );
  }
}
