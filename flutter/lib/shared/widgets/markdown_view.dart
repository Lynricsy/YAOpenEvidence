import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/logic/citations.dart';
import '../../core/logic/markdown_document.dart';

/// 引用芯片构造器：答案页传入自己的 `CitationChip`；不传则退化为着色文本。
typedef CitationSpanBuilder =
    InlineSpan Function(BuildContext context, CitationRef ref, String text);

/// 按块渲染 [MarkdownBlock]。可选：
/// - [anchorKeys]：带 `<a id="pN">` 锚点的段落挂 key，供 `Scrollable.ensureVisible` 定位；
/// - [flashAnchor]：该锚点段落闪一下背景（定位提示）；
/// - [citationSpanBuilder] / [onCitationTap]：引用芯片渲染与点击。
class MarkdownDocumentView extends StatelessWidget {
  const MarkdownDocumentView({
    super.key,
    required this.blocks,
    this.anchorKeys,
    this.flashAnchor,
    this.citationSpanBuilder,
    this.onCitationTap,
    this.selectable = true,
    this.baseStyle,
  });

  final List<MarkdownBlock> blocks;
  final Map<int, GlobalKey>? anchorKeys;
  final int? flashAnchor;
  final CitationSpanBuilder? citationSpanBuilder;
  final void Function(CitationRef ref)? onCitationTap;
  final bool selectable;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) _BlockView(block: block, view: this),
      ],
    );
    return selectable ? SelectionArea(child: content) : content;
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.view});

  final MarkdownBlock block;
  final MarkdownDocumentView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (block) {
      case MdHeading(:final level, :final runs):
        final style = switch (level) {
          1 => theme.textTheme.headlineSmall,
          2 => theme.textTheme.titleLarge,
          3 => theme.textTheme.titleMedium,
          _ => theme.textTheme.titleSmall,
        };
        return Padding(
          padding: const EdgeInsets.only(
            top: YaoeTokens.space4,
            bottom: YaoeTokens.space2,
          ),
          child: Text.rich(
            _spans(context, runs, style),
            style: style,
          ),
        );

      case MdParagraph(:final runs, :final anchor):
        final base = view.baseStyle ?? theme.textTheme.bodyMedium;
        final paragraph = Padding(
          padding: const EdgeInsets.only(bottom: YaoeTokens.space3),
          child: Text.rich(_spans(context, runs, base), style: base),
        );
        if (anchor == null) return paragraph;
        final key = view.anchorKeys?[anchor];
        final highlighted = view.flashAnchor == anchor;
        return _AnchoredParagraph(
          key: key,
          flash: highlighted,
          child: paragraph,
        );

      case MdBlockQuote(:final blocks):
        return Container(
          margin: const EdgeInsets.only(bottom: YaoeTokens.space3),
          padding: const EdgeInsets.only(left: YaoeTokens.space3),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final inner in blocks)
                _BlockView(block: inner, view: view),
            ],
          ),
        );

      case MdList(:final ordered, :final start, :final items):
        return Padding(
          padding: const EdgeInsets.only(bottom: YaoeTokens.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < items.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: YaoeTokens.space1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text(
                          ordered ? '${start + index}.' : '·',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final inner in items[index])
                              _BlockView(block: inner, view: view),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case MdCodeBlock(:final code):
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: YaoeTokens.space3),
          padding: const EdgeInsets.all(YaoeTokens.space3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              code,
              style: theme.textTheme.bodySmall?.merge(monoStyle),
            ),
          ),
        );

      case MdTable(:final header, :final rows):
        return Container(
          margin: const EdgeInsets.only(bottom: YaoeTokens.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.symmetric(
                inside: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              children: [
                if (header.isNotEmpty)
                  TableRow(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                    ),
                    children: [
                      for (final cell in header)
                        _TableCell(
                          runs: cell,
                          citationSpanBuilder: view.citationSpanBuilder,
                          style: theme.textTheme.labelLarge,
                        ),
                    ],
                  ),
                for (final row in rows)
                  TableRow(
                    children: [
                      for (final cell in row)
                        _TableCell(
                          runs: cell,
                          citationSpanBuilder: view.citationSpanBuilder,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );

      case MdThematicBreak():
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: YaoeTokens.space3),
          child: Divider(),
        );

      case MdHtml(:final raw):
        return Padding(
          padding: const EdgeInsets.only(bottom: YaoeTokens.space3),
          child: Text(
            raw,
            style: theme.textTheme.bodySmall
                ?.merge(monoStyle)
                .copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        );
    }
  }

  TextSpan _spans(
    BuildContext context,
    List<InlineRun> runs,
    TextStyle? base,
  ) => TextSpan(
    children: [
      for (final run in runs)
        _runSpan(context, run, base, view.citationSpanBuilder),
    ],
  );
}

/// 行内 Markdown 文本：表格单元格与 PICOS 卡片复用同一套 run → span 转换。
class MarkdownInlineText extends StatelessWidget {
  const MarkdownInlineText({
    super.key,
    required this.runs,
    this.style,
    this.citationSpanBuilder,
  });

  final List<InlineRun> runs;
  final TextStyle? style;
  final CitationSpanBuilder? citationSpanBuilder;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        for (final run in runs)
          _runSpan(context, run, style, citationSpanBuilder),
      ],
    ),
    style: style,
  );
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.runs,
    required this.citationSpanBuilder,
    this.style,
  });

  final List<InlineRun> runs;
  final CitationSpanBuilder? citationSpanBuilder;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: YaoeTokens.space3,
      vertical: YaoeTokens.space2,
    ),
    child: MarkdownInlineText(
      runs: runs,
      style: style,
      citationSpanBuilder: citationSpanBuilder,
    ),
  );
}

InlineSpan _runSpan(
  BuildContext context,
  InlineRun run,
  TextStyle? base,
  CitationSpanBuilder? citationSpanBuilder,
) {
  final theme = Theme.of(context);
  final citation = run.citation;
  if (citation != null) {
    if (citationSpanBuilder != null) {
      return citationSpanBuilder(context, citation, run.text);
    }
    final color = citationColor(
      citation.n,
      dark: theme.brightness == Brightness.dark,
    );
    return TextSpan(
      text: run.text,
      style: (base ?? const TextStyle())
          .merge(monoStyle)
          .copyWith(color: color, fontWeight: FontWeight.w600),
      recognizer: null,
      onEnter: null,
      mouseCursor: SystemMouseCursors.click,
    );
  }

  var style = base ?? const TextStyle();
  if (run.style.has(InlineStyle.bold)) {
    style = style.copyWith(fontWeight: FontWeight.w600);
  }
  if (run.style.has(InlineStyle.italic)) {
    style = style.copyWith(fontStyle: FontStyle.italic);
  }
  if (run.style.has(InlineStyle.strikethrough)) {
    style = style.copyWith(decoration: TextDecoration.lineThrough);
  }
  if (run.style.has(InlineStyle.code)) {
    style = style.merge(monoStyle).copyWith(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
    );
  }
  if (run.style.has(InlineStyle.highlight)) {
    style = style.copyWith(backgroundColor: context.yaoe.highlight);
  }
  final link = run.link;
  if (link != null) {
    style = style.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary.withValues(alpha: 0.4),
    );
  }
  return TextSpan(text: run.text, style: style);
}

/// 定位提示：主色 14% 背景闪 2.4 s 后淡出。
class _AnchoredParagraph extends StatelessWidget {
  const _AnchoredParagraph({
    super.key,
    required this.flash,
    required this.child,
  });

  final bool flash;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(flash),
      tween: Tween(begin: flash ? 1 : 0, end: 0),
      duration: flash ? const Duration(milliseconds: 2400) : Duration.zero,
      curve: Curves.easeOut,
      builder: (context, value, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.14 * value),
          borderRadius: BorderRadius.circular(YaoeTokens.radiusSm),
        ),
        child: child,
      ),
      child: child,
    );
  }
}
