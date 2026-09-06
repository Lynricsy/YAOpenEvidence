import 'package:markdown/markdown.dart' as md;

import 'citations.dart';

/// 行内样式（可叠加的位标志）。
class InlineStyle {
  const InlineStyle(this.bits);

  final int bits;

  static const none = InlineStyle(0);
  static const bold = InlineStyle(1 << 0);
  static const italic = InlineStyle(1 << 1);
  static const code = InlineStyle(1 << 2);
  static const strikethrough = InlineStyle(1 << 3);
  static const highlight = InlineStyle(1 << 4);

  InlineStyle operator |(InlineStyle other) => InlineStyle(bits | other.bits);

  bool has(InlineStyle flag) => (bits & flag.bits) != 0;

  @override
  bool operator ==(Object other) => other is InlineStyle && other.bits == bits;

  @override
  int get hashCode => bits;

  @override
  String toString() => 'InlineStyle($bits)';
}

/// 一段行内文本及其样式；[citation] 非空表示这是一处引用芯片。
class InlineRun {
  const InlineRun({
    required this.text,
    this.style = InlineStyle.none,
    this.link,
    this.citation,
  });

  final String text;
  final InlineStyle style;
  final Uri? link;
  final CitationRef? citation;

  InlineRun copyWith({String? text, InlineStyle? style}) => InlineRun(
    text: text ?? this.text,
    style: style ?? this.style,
    link: link,
    citation: citation,
  );

  @override
  bool operator ==(Object other) =>
      other is InlineRun &&
      other.text == text &&
      other.style == style &&
      other.link == link &&
      other.citation == citation;

  @override
  int get hashCode => Object.hash(text, style, link, citation);

  @override
  String toString() => 'InlineRun($text, ${style.bits})';
}

/// 块级结构。渲染层按此逐块画 widget。
sealed class MarkdownBlock {
  const MarkdownBlock();
}

final class MdHeading extends MarkdownBlock {
  const MdHeading(this.level, this.runs);

  final int level;
  final List<InlineRun> runs;
}

/// [anchor] 来自段首的 `<a id="pN"></a>`，供滚动定位。
final class MdParagraph extends MarkdownBlock {
  const MdParagraph(this.runs, {this.anchor});

  final List<InlineRun> runs;
  final int? anchor;
}

final class MdBlockQuote extends MarkdownBlock {
  const MdBlockQuote(this.blocks);

  final List<MarkdownBlock> blocks;
}

final class MdList extends MarkdownBlock {
  const MdList({
    required this.ordered,
    required this.start,
    required this.items,
  });

  final bool ordered;
  final int start;
  final List<List<MarkdownBlock>> items;
}

final class MdCodeBlock extends MarkdownBlock {
  const MdCodeBlock({this.language, required this.code});

  final String? language;
  final String code;
}

final class MdTable extends MarkdownBlock {
  const MdTable({required this.header, required this.rows});

  final List<List<InlineRun>> header;
  final List<List<List<InlineRun>>> rows;
}

final class MdThematicBreak extends MarkdownBlock {
  const MdThematicBreak();
}

/// 无法识别的 HTML 块，按等宽纯文本显示。
final class MdHtml extends MarkdownBlock {
  const MdHtml(this.raw);

  final String raw;
}

/// 取一组 run 的纯文本（用于引文高亮定位、无障碍标签）。
String plainTextOf(Iterable<InlineRun> runs) => runs.map((r) => r.text).join();

/// 转义方括号占位标签：package:markdown 在 `_combineAdjacentText` 里把相邻文本节点合并，
/// `\[1]` 转义后与后文并成一个 `A[1] B` 文本节点，事后扫描无法再区分转义。
/// 因此用一个自定义行内语法把 `\[` 变成独立元素节点，扫描时不参与标记识别。
const _escapedBracketTag = 'yaoe-escaped-bracket';

class _EscapedBracketSyntax extends md.InlineSyntax {
  _EscapedBracketSyntax() : super(r'\\\[', startCharacter: 0x5c);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text(_escapedBracketTag, '['));
    return true;
  }
}

/// 解析 Markdown。[citationLimit] 非空时把 `[n]` / `[n¶pid]` 裸标记识别为引用
/// （1…limit 之外不识别）。
List<MarkdownBlock> parseMarkdown(String markdown, {int? citationLimit}) {
  final document = md.Document(
    // 自定义语法先于默认语法求值，`\[` 因此在 EscapeSyntax 之前被摘成独立节点。
    inlineSyntaxes: [_EscapedBracketSyntax()],
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  );
  return _blocks(document.parse(markdown), citationLimit);
}

const _blockTags = <String>{
  'p',
  'ul',
  'ol',
  'blockquote',
  'pre',
  'table',
  'hr',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
};

List<MarkdownBlock> _blocks(List<md.Node> nodes, int? limit) {
  final out = <MarkdownBlock>[];
  for (final node in nodes) {
    final block = _block(node, limit);
    if (block != null) out.add(block);
  }
  return out;
}

MarkdownBlock? _block(md.Node node, int? limit) {
  // 块级 HTML 由 HtmlBlockSyntax 直接产出裸 Text 节点。
  if (node is md.Text) {
    final raw = node.text.trim();
    return raw.isEmpty ? null : MdHtml(raw);
  }
  if (node is! md.Element) return null;
  final children = node.children ?? const <md.Node>[];

  switch (node.tag) {
    case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
      final level = int.tryParse(node.tag.substring(1)) ?? 1;
      return MdHeading(level, _inline(children, limit).runs);
    case 'p':
      final built = _inline(children, limit);
      return MdParagraph(built.runs, anchor: built.anchor);
    case 'blockquote':
      return MdBlockQuote(_blocks(children, limit));
    case 'ul':
      return MdList(ordered: false, start: 1, items: _items(children, limit));
    case 'ol':
      return MdList(
        ordered: true,
        start: int.tryParse(node.attributes['start'] ?? '') ?? 1,
        items: _items(children, limit),
      );
    case 'pre':
      final code = children.whereType<md.Element>().firstWhere(
        (e) => e.tag == 'code',
        orElse: () => md.Element.text('code', node.textContent),
      );
      final classes = code.attributes['class'] ?? '';
      final language = classes.startsWith('language-')
          ? classes.substring('language-'.length)
          : null;
      return MdCodeBlock(
        language: (language ?? '').isEmpty ? null : language,
        code: code.textContent.replaceFirst(RegExp(r'\n$'), ''),
      );
    case 'table':
      final header = <List<InlineRun>>[];
      final rows = <List<List<InlineRun>>>[];
      for (final section in children.whereType<md.Element>()) {
        for (final row in (section.children ?? const <md.Node>[])
            .whereType<md.Element>()
            .where((e) => e.tag == 'tr')) {
          final cells = (row.children ?? const <md.Node>[])
              .whereType<md.Element>()
              .map(
                (cell) =>
                    _inline(cell.children ?? const <md.Node>[], limit).runs,
              )
              .toList(growable: false);
          if (section.tag == 'thead') {
            header.addAll(cells);
          } else {
            rows.add(cells);
          }
        }
      }
      return MdTable(header: header, rows: rows);
    case 'hr':
      return const MdThematicBreak();
    default:
      // 未知块容器：能拆出子块就按引用块渲染，否则当段落。
      final inner = _blocks(children, limit);
      if (inner.isNotEmpty) return MdBlockQuote(inner);
      final built = _inline(children, limit);
      return built.runs.isEmpty
          ? null
          : MdParagraph(built.runs, anchor: built.anchor);
  }
}

List<List<MarkdownBlock>> _items(List<md.Node> children, int? limit) => children
    .whereType<md.Element>()
    .where((e) => e.tag == 'li')
    .map((li) => _itemBlocks(li.children ?? const <md.Node>[], limit))
    .toList(growable: false);

/// 列表项：紧凑列表的子节点是行内节点，需要自己聚成段落。
List<MarkdownBlock> _itemBlocks(List<md.Node> children, int? limit) {
  final blocks = <MarkdownBlock>[];
  final pending = <md.Node>[];

  void flush() {
    if (pending.isEmpty) return;
    final built = _inline(pending, limit);
    if (built.runs.isNotEmpty) {
      blocks.add(MdParagraph(built.runs, anchor: built.anchor));
    }
    pending.clear();
  }

  for (final child in children) {
    if (child is md.Element && _blockTags.contains(child.tag)) {
      flush();
      final block = _block(child, limit);
      if (block != null) blocks.add(block);
    } else {
      pending.add(child);
    }
  }
  flush();
  return blocks;
}

class _InlineBuilder {
  final List<InlineRun> runs = [];
  int? anchor;
  bool highlight = false;

  /// 是否已出现可见文本（决定 `<a id="pN">` 是否算段落锚点）。
  bool sawText = false;

  void add(String text, InlineStyle style, Uri? link, CitationRef? citation) {
    if (text.isEmpty) return;
    runs.add(
      InlineRun(
        text: text,
        style: highlight ? style | InlineStyle.highlight : style,
        link: link,
        citation: citation,
      ),
    );
    sawText = true;
  }
}

_InlineBuilder _inline(List<md.Node> children, int? limit) {
  final builder = _InlineBuilder();
  for (final child in children) {
    _appendInline(
      child,
      builder,
      style: InlineStyle.none,
      link: null,
      allowMarkers: true,
      limit: limit,
    );
  }
  return builder;
}

void _appendInline(
  md.Node node,
  _InlineBuilder builder, {
  required InlineStyle style,
  required Uri? link,
  required bool allowMarkers,
  required int? limit,
}) {
  if (node is md.Text) {
    _appendText(
      node.text,
      builder,
      style: style,
      link: link,
      allowMarkers: allowMarkers,
      limit: limit,
    );
    return;
  }
  if (node is! md.Element) return;
  final children = node.children ?? const <md.Node>[];

  void recurse(InlineStyle nextStyle, Uri? nextLink, bool markers) {
    for (final child in children) {
      _appendInline(
        child,
        builder,
        style: nextStyle,
        link: nextLink,
        allowMarkers: markers,
        limit: limit,
      );
    }
  }

  switch (node.tag) {
    case 'em':
      recurse(style | InlineStyle.italic, link, allowMarkers);
    case 'strong':
      recurse(style | InlineStyle.bold, link, allowMarkers);
    case 'del':
      recurse(style | InlineStyle.strikethrough, link, allowMarkers);
    case 'mark':
      builder.highlight = true;
      recurse(style, link, allowMarkers);
      builder.highlight = false;
    case 'code':
      // 代码里的方括号不是引用标记。
      builder.add(node.textContent, style | InlineStyle.code, link, null);
    case 'a':
      final destination = node.attributes['href'] ?? '';
      final ref = parseAnswerLink(destination);
      if (ref != null) {
        builder.add(node.textContent, style, null, ref);
      } else {
        // 普通链接的标签不再识别裸标记：`[[1]](https://example.com)` 必须留在原链接上，
        // 否则点击会跳到第 1 篇文献（与 Web 端跳过整个 link 子树一致）。
        recurse(style, Uri.tryParse(destination) ?? link, false);
      }
    case 'img':
      final alt = node.attributes['alt'] ?? node.attributes['title'] ?? '';
      builder.add(alt, style, link, null);
    case 'br':
      builder.add('\n', style, link, null);
    case _escapedBracketTag:
      // 转义出来的方括号是普通字符，不参与引用标记识别。
      builder.add(node.textContent, style, link, null);
    default:
      recurse(style, link, allowMarkers);
  }
}

final _anchorRegex = RegExp(r'<a\s+id="p(\d+)"\s*>', caseSensitive: false);
final _inlineTagRegex = RegExp(
  r'<a\s+id="p\d+"\s*>|</a\s*>|<mark\s*>|</mark\s*>|<br\s*/?>',
  caseSensitive: false,
);

/// 文本节点：切出行内 HTML（段落锚点、`<mark>` 开关、`<br>`）与引用标记。
///
/// package:markdown 的 `InlineHtmlSyntax` 把原始标签留在普通文本里（不单独成节点），
/// 因此这里必须自己扫描；转义 `\[1]` 由 `EscapeSyntax` 拆成独立文本节点，天然不成标记。
void _appendText(
  String text,
  _InlineBuilder builder, {
  required InlineStyle style,
  required Uri? link,
  required bool allowMarkers,
  required int? limit,
}) {
  var cursor = 0;
  for (final match in _inlineTagRegex.allMatches(text)) {
    if (match.start > cursor) {
      _appendPlain(
        text.substring(cursor, match.start),
        builder,
        style: style,
        link: link,
        allowMarkers: allowMarkers,
        limit: limit,
      );
    }
    final tag = match[0]!.toLowerCase();
    if (tag.startsWith('<a')) {
      if (!builder.sawText) {
        builder.anchor = int.tryParse(
          _anchorRegex.firstMatch(match[0]!)?.group(1) ?? '',
        );
      }
    } else if (tag.startsWith('<mark')) {
      builder.highlight = true;
    } else if (tag.startsWith('</mark')) {
      builder.highlight = false;
    } else if (tag.startsWith('<br')) {
      builder.add('\n', style, link, null);
    }
    cursor = match.end;
  }
  if (cursor < text.length) {
    _appendPlain(
      text.substring(cursor),
      builder,
      style: style,
      link: link,
      allowMarkers: allowMarkers,
      limit: limit,
    );
  }
}

void _appendPlain(
  String text,
  _InlineBuilder builder, {
  required InlineStyle style,
  required Uri? link,
  required bool allowMarkers,
  required int? limit,
}) {
  // 软换行在行内等价于空格（硬换行由 `br` 元素单独产出 '\n'）。
  final flowed = text.replaceAll('\n', ' ');
  if (!allowMarkers || limit == null || limit < 1) {
    builder.add(flowed, style, link, null);
    return;
  }
  var cursor = 0;
  for (final marker in markersIn(flowed)) {
    if (marker.ref.n < 1 || marker.ref.n > limit) continue;
    if (marker.start > cursor) {
      builder.add(flowed.substring(cursor, marker.start), style, link, null);
    }
    builder.add(
      flowed.substring(marker.start, marker.end),
      style,
      link,
      marker.ref,
    );
    cursor = marker.end;
  }
  if (cursor < flowed.length) {
    builder.add(flowed.substring(cursor), style, link, null);
  }
}
