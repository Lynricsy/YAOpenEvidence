import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/logic/citations.dart';
import '../../core/logic/markdown_document.dart';
import '../../core/models/answers.dart';
import '../../core/models/papers.dart';
import '../../core/session/session_controller.dart';
import '../../shared/external_links.dart';
import '../../shared/format.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/markdown_view.dart';
import '../../shared/widgets/quote_highlight.dart';
import '../answer/answer_controller.dart';
import 'paragraph_markdown.dart';

part 'reader_pane.g.dart';

/// 阅读器当前目标（第 n 篇 / 第 pid 段）。null = 关闭。
@riverpod
class ReaderTarget extends _$ReaderTarget {
  @override
  CitationRef? build(String answerId) => null;

  void open(CitationRef ref_) => state = ref_;

  void close() => state = null;
}

/// 逐篇材料。旧版答案可能只有原文快照，甚至什么都没有。
sealed class ReaderMaterial {
  const ReaderMaterial();
}

final class ReaderDetail extends ReaderMaterial {
  const ReaderDetail(this.detail);

  final AnswerPaperDetail detail;
}

final class ReaderMarkdownOnly extends ReaderMaterial {
  const ReaderMarkdownOnly(this.markdown);

  final String markdown;
}

final class ReaderMissing extends ReaderMaterial {
  const ReaderMissing();
}

/// 取第 n 篇材料：详情 404 时回退原文快照，都 404 则视为缺失。
@riverpod
Future<ReaderMaterial> readerMaterial(Ref ref, String answerId, int n) async {
  final client = ref.watch(apiClientProvider);
  try {
    return ReaderDetail(await client.answerPaper(id: answerId, n: n));
  } on ApiError catch (error) {
    if (error.status != 404) rethrow;
  }
  try {
    return ReaderMarkdownOnly(
      await client.answerPaperMarkdown(id: answerId, n: n),
    );
  } on ApiError catch (error) {
    if (error.status == 404) return const ReaderMissing();
    rethrow;
  }
}

/// 阅读器面板：原文 / 阅读笔记 / 核实引文 / 事实。
class ReaderPane extends ConsumerStatefulWidget {
  const ReaderPane({
    super.key,
    required this.answerId,
    required this.target,
    this.onClose,
  });

  final String answerId;
  final CitationRef target;
  final VoidCallback? onClose;

  @override
  ConsumerState<ReaderPane> createState() => _ReaderPaneState();
}

class _ReaderPaneState extends ConsumerState<ReaderPane>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _goToParagraph(int pid) {
    ref
        .read(readerTargetProvider(widget.answerId).notifier)
        .open(CitationRef(widget.target.n, pid));
    _tabs.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = widget.target.n;
    final material = ref.watch(readerMaterialProvider(widget.answerId, n));
    final answer = ref.watch(answerControllerProvider(widget.answerId)).value;
    final paper = answer?.papers.where((p) => p.n == n).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(n: n, paper: paper, onClose: widget.onClose),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: AsyncValueView<ReaderMaterial>(
            value: material,
            onRetry: () => ref.invalidate(
              readerMaterialProvider(widget.answerId, n),
            ),
            builder: (data) => switch (data) {
              ReaderDetail(:final detail) => _DetailTabs(
                detail: detail,
                tabs: _tabs,
                pid: widget.target.pid,
                quotes: _quotesFor(answer, n, widget.target.pid, detail),
                onParagraph: _goToParagraph,
              ),
              ReaderMarkdownOnly(:final markdown) => SingleChildScrollView(
                padding: const EdgeInsets.all(YaoeTokens.space4),
                child: ParagraphMarkdown(
                  markdown: markdown,
                  pid: widget.target.pid,
                  quotes: _quotesFor(answer, n, widget.target.pid, null),
                ),
              ),
              ReaderMissing() => Padding(
                padding: const EdgeInsets.all(YaoeTokens.space4),
                child: (answer?.status.isActive ?? false)
                    ? const EmptyState(
                        icon: Icons.hourglass_empty,
                        title: '该文献尚未阅读完成',
                        description: '任务仍在进行中，原文与核实材料会在逐篇阅读阶段结束后出现。',
                      )
                    : const EmptyState(
                        icon: Icons.inbox_outlined,
                        title: '此答案没有逐篇材料',
                        description: '旧版导入的问答只保留了正文。',
                      ),
              ),
            },
          ),
        ),
      ],
    );
  }

  /// 高亮片段：优先答案里的引用记录，其次该段的核实引文。
  List<String> _quotesFor(
    Answer? answer,
    int n,
    int? pid,
    AnswerPaperDetail? detail,
  ) {
    if (pid == null) return const [];
    final quotes = <String>[
      ...?answer?.citations
          .where((citation) => citation.n == n && citation.pid == pid)
          .expand((citation) => citation.quotes),
      ...?detail?.citations
          .where((quote) => quote.pid == pid)
          .map((quote) => quote.quote),
    ];
    return quotes.where((quote) => quote.trim().isNotEmpty).toList();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.n, required this.paper, required this.onClose});

  final int n;
  final AnswerPaper? paper;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        YaoeTokens.space4,
        YaoeTokens.space3,
        YaoeTokens.space2,
        YaoeTokens.space3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CitationSquare(n: n),
          const SizedBox(width: YaoeTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper?.title.isNotEmpty == true ? paper!.title : '第 $n 篇文献',
                  style: theme.textTheme.titleSmall,
                ),
                if (paper != null) ...[
                  const SizedBox(height: YaoeTokens.space1),
                  Text(
                    [
                      paper!.journal,
                      paper!.year,
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
                      RankBadge(
                        quartile: paper!.quartile,
                        label: paper!.rankLabel,
                      ),
                      SourceBadge(source: paper!.source),
                    ],
                  ),
                  const SizedBox(height: YaoeTokens.space1),
                  ExternalLinkRow(
                    pmid: paper!.pmid,
                    doi: paper!.doi,
                    pmcid: paper!.pmcid,
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              tooltip: '关闭阅读器',
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({
    required this.detail,
    required this.tabs,
    required this.pid,
    required this.quotes,
    required this.onParagraph,
  });

  final AnswerPaperDetail detail;
  final TabController tabs;
  final int? pid;
  final List<String> quotes;
  final void Function(int pid) onParagraph;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(text: '原文'),
            const Tab(text: '阅读笔记'),
            Tab(text: '核实引文 ${detail.citations.length}'),
            Tab(text: '事实 ${detail.facts.length}'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabs,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(YaoeTokens.space4),
                child: ParagraphMarkdown(
                  markdown: detail.fulltextMd,
                  pid: pid,
                  quotes: quotes,
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(YaoeTokens.space4),
                child: detail.notesMd.trim().isEmpty
                    ? const EmptyState(
                        icon: Icons.notes_outlined,
                        title: '没有阅读笔记',
                      )
                    : MarkdownDocumentView(
                        blocks: parseMarkdown(detail.notesMd),
                      ),
              ),
              _QuoteList(
                quotes: detail.citations,
                onParagraph: onParagraph,
              ),
              _FactList(facts: detail.facts, onParagraph: onParagraph),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuoteList extends StatelessWidget {
  const _QuoteList({required this.quotes, required this.onParagraph});

  final List<VerifiedQuote> quotes;
  final void Function(int pid) onParagraph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (quotes.isEmpty) {
      return const EmptyState(
        icon: Icons.format_quote_outlined,
        title: '没有核实引文',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(YaoeTokens.space4),
      itemCount: quotes.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: YaoeTokens.space3),
      itemBuilder: (context, index) {
        final quote = quotes[index];
        final pid = quote.pid ?? quote.claimedPid;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                VerifiedPill(verified: quote.verified),
                const SizedBox(width: YaoeTokens.space2),
                if (pid > 0)
                  TextButton(
                    onPressed: () => onParagraph(pid),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text('¶$pid'),
                  ),
                if (quote.keyFinding)
                  Icon(Icons.star, size: 14, color: context.yaoe.warning),
                const Spacer(),
                Text(
                  formatScore(quote.score),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: YaoeTokens.space1),
            QuoteHighlight(quote: quote.quote),
            if ((quote.noteSection ?? '').isNotEmpty) ...[
              const SizedBox(height: YaoeTokens.space1),
              Text(
                quote.noteSection!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FactList extends StatelessWidget {
  const _FactList({required this.facts, required this.onParagraph});

  final List<Fact> facts;
  final void Function(int pid) onParagraph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (facts.isEmpty) {
      return const EmptyState(
        icon: Icons.lightbulb_outline,
        title: '没有抽取到事实',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(YaoeTokens.space4),
      itemCount: facts.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: YaoeTokens.space3),
      itemBuilder: (context, index) {
        final fact = facts[index];
        final text = fact.factZh.isNotEmpty ? fact.factZh : fact.fact;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(text: fact.kindLabel, color: theme.colorScheme.primary),
                const SizedBox(width: YaoeTokens.space2),
                VerifiedPill(verified: fact.verified),
                if (fact.pid != null)
                  TextButton(
                    onPressed: () => onParagraph(fact.pid!),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text('¶${fact.pid}'),
                  ),
              ],
            ),
            const SizedBox(height: YaoeTokens.space1),
            Text(text, style: theme.textTheme.bodySmall),
            if (fact.quote.isNotEmpty) ...[
              const SizedBox(height: YaoeTokens.space1),
              QuoteHighlight(quote: fact.quote, maxLines: 3),
            ],
          ],
        );
      },
    );
  }
}
