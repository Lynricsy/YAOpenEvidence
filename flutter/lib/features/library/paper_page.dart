import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/logic/markdown_document.dart';
import '../../shared/external_links.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/markdown_view.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/quote_highlight.dart';
import '../../shared/widgets/surface.dart';
import 'library_controller.dart';

class PaperPage extends ConsumerStatefulWidget {
  const PaperPage({super.key, required this.paperKey, this.pid});

  final String paperKey;
  final int? pid;

  @override
  ConsumerState<PaperPage> createState() => _PaperPageState();
}

class _PaperPageState extends ConsumerState<PaperPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final Map<int, GlobalKey> _anchorKeys = {};
  String? _markdown;
  List<MarkdownBlock> _blocks = const [];
  int? _flashAnchor;
  int _locationRequest = 0;

  /// 分段控件的选中值：跟随 TabController，切换时重建按钮。
  int get _tab => _tabs.index;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant PaperPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paperKey != widget.paperKey) {
      _markdown = null;
      _blocks = const [];
      _anchorKeys.clear();
      _flashAnchor = null;
      _locationRequest++;
      _tabs.index = 0;
    }
    if (oldWidget.pid != widget.pid || oldWidget.paperKey != widget.paperKey) {
      _flashAnchor = null;
      _tabs.index = 0;
      _locate(widget.pid);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _collectAnchors(List<MarkdownBlock> blocks) {
    for (final block in blocks) {
      if (block is MdParagraph && block.anchor != null) {
        _anchorKeys.putIfAbsent(block.anchor!, GlobalKey.new);
      } else if (block is MdBlockQuote) {
        _collectAnchors(block.blocks);
      } else if (block is MdList) {
        for (final item in block.items) {
          _collectAnchors(item);
        }
      }
    }
  }

  void _locate(int? pid) {
    final request = ++_locationRequest;
    if (pid == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || request != _locationRequest || _tabs.index != 0) return;
      final target = _anchorKeys[pid]?.currentContext;
      if (target == null) return;
      unawaited(
        Scrollable.ensureVisible(
          target,
          alignment: 0.3,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 300),
        ),
      );
      setState(() {
        _flashAnchor = MediaQuery.disableAnimationsOf(context) ? null : pid;
      });
    });
  }

  void _openParagraph(int pid) {
    setState(() => _flashAnchor = null);
    _tabs.index = 0;
    context.go('/library/${Uri.encodeComponent(widget.paperKey)}?pid=$pid');
    _locate(pid);
  }

  Widget _fulltext(String markdown) {
    if (_markdown != markdown) {
      _markdown = markdown;
      _blocks = parseMarkdown(markdown);
      _anchorKeys.clear();
      _collectAnchors(_blocks);
      _locate(widget.pid);
    }
    if (_blocks.isEmpty) {
      return const EmptyState(icon: Icons.description_outlined, title: '暂无全文');
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: YaoeTokens.space4),
      child: MarkdownDocumentView(
        blocks: _blocks,
        anchorKeys: _anchorKeys,
        flashAnchor: _flashAnchor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = ref.watch(paperMetaProvider(widget.paperKey));
    final fulltext = ref.watch(paperFulltextProvider(widget.paperKey));
    final facts = ref.watch(paperFactsProvider(widget.paperKey));
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsyncValueView(
            value: meta,
            onRetry: () => ref.invalidate(paperMetaProvider(widget.paperKey)),
            builder: (paper) => YaoeCard(
              padding: const EdgeInsets.all(YaoeTokens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(paper.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: YaoeTokens.space2),
                  Wrap(
                    spacing: YaoeTokens.space2,
                    runSpacing: YaoeTokens.space2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        [
                          paper.journal,
                          paper.year,
                        ].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      RankBadge(quartile: paper.quartile),
                    ],
                  ),
                  const SizedBox(height: YaoeTokens.space2),
                  Wrap(
                    spacing: YaoeTokens.space3,
                    runSpacing: YaoeTokens.space1,
                    children: [
                      MonoLabel(label: 'PMID', value: paper.pmid),
                      MonoLabel(label: 'DOI', value: paper.doi),
                      MonoLabel(label: 'PMCID', value: paper.pmcid),
                    ],
                  ),
                  ExternalLinkRow(
                    pmid: paper.pmid,
                    doi: paper.doi,
                    pmcid: paper.pmcid,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: YaoeTokens.space4),
          Align(
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('全文')),
                ButtonSegment(value: 1, label: Text('事实')),
              ],
              selected: {_tab},
              onSelectionChanged: (values) => _tabs.animateTo(values.first),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                AsyncValueView(
                  value: fulltext,
                  onRetry: () =>
                      ref.invalidate(paperFulltextProvider(widget.paperKey)),
                  builder: _fulltext,
                ),
                AsyncValueView(
                  value: facts,
                  onRetry: () =>
                      ref.invalidate(paperFactsProvider(widget.paperKey)),
                  builder: (items) => items.isEmpty
                      ? const EmptyState(
                          icon: Icons.fact_check_outlined,
                          title: '暂无事实',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: YaoeTokens.space4,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: YaoeTokens.space3),
                          itemBuilder: (context, index) {
                            final fact = items[index];
                            return YaoeCard(
                              padding: const EdgeInsets.all(YaoeTokens.space4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: YaoeTokens.space2,
                                    runSpacing: YaoeTokens.space2,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      if (fact.kindLabel.isNotEmpty)
                                        Pill(
                                          text: fact.kindLabel,
                                          color: theme.colorScheme.primary,
                                        ),
                                      VerifiedPill(verified: fact.verified),
                                      if (fact.pid != null)
                                        TextButton.icon(
                                          onPressed: () =>
                                              _openParagraph(fact.pid!),
                                          icon: const Icon(
                                            Icons.subdirectory_arrow_right,
                                            size: 16,
                                          ),
                                          label: const Text('定位原文'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: YaoeTokens.space2),
                                  SelectableText(
                                    fact.factZh.trim().isNotEmpty
                                        ? fact.factZh
                                        : fact.fact,
                                  ),
                                  if (fact.quote.isNotEmpty) ...[
                                    const SizedBox(height: YaoeTokens.space2),
                                    QuoteHighlight(quote: fact.quote),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
