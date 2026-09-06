import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/inline_highlight.dart';
import '../../core/logic/markdown_document.dart';
import '../../shared/widgets/markdown_view.dart';

/// 带段落锚点的原文视图：定位到 `pid` 段并高亮命中的引文。
class ParagraphMarkdown extends StatefulWidget {
  const ParagraphMarkdown({
    super.key,
    required this.markdown,
    this.pid,
    this.quotes = const [],
  });

  final String markdown;

  /// 需要定位的段落编号（来自 `[n¶pid]`）。
  final int? pid;

  /// 该段落里需要高亮的直引片段。
  final List<String> quotes;

  @override
  State<ParagraphMarkdown> createState() => _ParagraphMarkdownState();
}

class _ParagraphMarkdownState extends State<ParagraphMarkdown> {
  final _anchorKeys = <int, GlobalKey>{};
  late List<MarkdownBlock> _blocks;
  int? _flash;

  @override
  void initState() {
    super.initState();
    _rebuild();
    _scheduleScroll();
  }

  @override
  void didUpdateWidget(ParagraphMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdown != widget.markdown ||
        oldWidget.pid != widget.pid ||
        !_sameQuotes(oldWidget.quotes, widget.quotes)) {
      _rebuild();
      if (oldWidget.pid != widget.pid ||
          oldWidget.markdown != widget.markdown) {
        _scheduleScroll();
      }
    }
  }

  bool _sameQuotes(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _rebuild() {
    final parsed = parseMarkdown(widget.markdown);
    _anchorKeys.clear();
    _blocks = [
      for (final block in parsed)
        if (block is MdParagraph && block.anchor != null)
          _decorate(block)
        else
          block,
    ];
  }

  MarkdownBlock _decorate(MdParagraph block) {
    final anchor = block.anchor!;
    _anchorKeys[anchor] = GlobalKey();
    if (anchor != widget.pid || widget.quotes.isEmpty) return block;
    return MdParagraph(
      highlightQuotes(block.runs, widget.quotes),
      anchor: anchor,
    );
  }

  void _scheduleScroll() {
    final pid = widget.pid;
    if (pid == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _anchorKeys[pid];
      final context = key?.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.3,
        duration: MediaQuery.disableAnimationsOf(this.context)
            ? Duration.zero
            : YaoeTokens.motionMedium,
        curve: YaoeTokens.motionCurve,
      );
      setState(() => _flash = pid);
    });
  }

  @override
  Widget build(BuildContext context) => MarkdownDocumentView(
    blocks: _blocks,
    anchorKeys: _anchorKeys,
    flashAnchor: _flash,
  );
}
