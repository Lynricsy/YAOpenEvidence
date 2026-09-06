import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/models/literature.dart';
import '../../shared/external_links.dart';
import '../../shared/format.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/page_header.dart';
import 'fulltext_sheet.dart';
import 'literature_controller.dart';
import 'literature_filters.dart';

class LiteraturePage extends ConsumerStatefulWidget {
  const LiteraturePage({super.key});

  @override
  ConsumerState<LiteraturePage> createState() => _LiteraturePageState();
}

class _LiteraturePageState extends ConsumerState<LiteraturePage> {
  @override
  Widget build(BuildContext context) {
    final value = ref.watch(literatureControllerProvider);
    final controller = ref.read(literatureControllerProvider.notifier);
    final canSearch = controller.query.trim().isNotEmpty &&
        controller.filters.rangeError == null && !value.isLoading;
    return SingleChildScrollView(
      child: PageBody(
        maxWidth: 1040,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(title: '查文献', description: '直接检索 PubMed / Semantic Scholar'),
            TextFormField(
              initialValue: controller.query,
              decoration: const InputDecoration(
                labelText: '检索词',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (text) => setState(() => controller.query = text),
              onFieldSubmitted: (_) {
                if (canSearch) unawaited(controller.search());
              },
            ),
            const SizedBox(height: YaoeTokens.space3),
            Wrap(
              spacing: YaoeTokens.space3,
              runSpacing: YaoeTokens.space3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<LiteratureSource>(
                    showSelectedIcon: false,
                    segments: [
                      for (final source in LiteratureSource.values)
                        ButtonSegment(value: source, label: Text(source.label)),
                    ],
                    selected: {controller.source},
                    onSelectionChanged: (values) =>
                        setState(() => controller.setSource(values.single)),
                  ),
                ),
                SizedBox(
                  width: 116,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(controller.limit),
                    initialValue: controller.limit,
                    decoration: const InputDecoration(labelText: '条数'),
                    items: [
                      for (final limit in const [10, 20, 30])
                        DropdownMenuItem(value: limit, child: Text('$limit 条')),
                    ],
                    onChanged: (limit) {
                      if (limit != null) setState(() => controller.setLimit(limit));
                    },
                  ),
                ),
                FilledButton.icon(
                  onPressed: canSearch ? () => unawaited(controller.search()) : null,
                  icon: const Icon(Icons.search),
                  label: Text(value.isLoading ? '检索中' : '检索'),
                ),
              ],
            ),
            LiteratureFilterPanel(
              filters: controller.filters,
              source: controller.source,
              onChanged: (filters) => setState(() => controller.setFilters(filters)),
            ),
            const SizedBox(height: YaoeTokens.space4),
            AsyncValueView<LiteratureSearchResult?>(
              value: value,
              onRetry: () => unawaited(controller.search()),
              builder: (result) {
                if (result == null) {
                  return const EmptyState(icon: Icons.search, title: '尚未检索');
                }
                final fallback = result.fallbackReason;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('来源 ${result.source.label} · 上游共 ${result.total} 条',
                      style: Theme.of(context).textTheme.titleSmall),
                    if (fallback != null && fallback.isNotEmpty) ...[
                      const SizedBox(height: YaoeTokens.space3),
                      Container(
                        padding: const EdgeInsets.all(YaoeTokens.space3),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.yaoe.warning),
                          borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
                        ),
                        child: Text('已改用 PubMed：$fallback'),
                      ),
                    ],
                    const SizedBox(height: YaoeTokens.space3),
                    if (result.items.isEmpty)
                      const EmptyState(icon: Icons.search_off, title: '未找到文献')
                    else
                      for (final record in result.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: YaoeTokens.space3),
                          child: _LiteratureCard(
                            key: ValueKey('${record.source.name}:${record.id}'),
                            record: record,
                          ),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LiteratureCard extends StatefulWidget {
  const _LiteratureCard({super.key, required this.record});

  final LiteratureRecord record;

  @override
  State<_LiteratureCard> createState() => _LiteratureCardState();
}

class _LiteratureCardState extends State<_LiteratureCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final theme = Theme.of(context);
    final summary = record.tldr?.trim().isNotEmpty == true
        ? record.tldr!
        : record.abstract ?? '';
    final ident = record.fulltextIdent;
    final metadata = [record.journal, record.year]
        .whereType<String>().where((value) => value.isNotEmpty).join(' · ');
    return Container(
      padding: const EdgeInsets.all(YaoeTokens.space4),
      decoration: BoxDecoration(
        color: context.yaoe.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(record.title, style: theme.textTheme.titleSmall),
          if (record.authors.isNotEmpty) ...[
            const SizedBox(height: YaoeTokens.space2),
            Text(formatAuthors(record.authors), style: theme.textTheme.bodySmall),
          ],
          if (metadata.isNotEmpty) Text(metadata, style: theme.textTheme.bodySmall),
          const SizedBox(height: YaoeTokens.space2),
          Wrap(
            spacing: YaoeTokens.space2,
            runSpacing: YaoeTokens.space2,
            children: [
              RankBadge(quartile: record.rank?.quartile ?? '', label: record.rank?.quartile),
              if (record.citedBy != null)
                Pill(text: '被引 ${record.citedBy}', color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: YaoeTokens.space3),
            Text(summary, maxLines: _expanded ? null : 3,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_expanded ? '收起' : '展开'),
              ),
            ),
          ],
          const SizedBox(height: YaoeTokens.space3),
          Wrap(
            spacing: YaoeTokens.space3,
            runSpacing: YaoeTokens.space2,
            children: [
              if (record.pmid?.isNotEmpty == true) MonoLabel(label: 'PMID', value: record.pmid!),
              if (record.doi?.isNotEmpty == true) MonoLabel(label: 'DOI', value: record.doi!),
              if (record.pmcid?.isNotEmpty == true) MonoLabel(label: 'PMCID', value: record.pmcid!),
            ],
          ),
          const SizedBox(height: YaoeTokens.space3),
          ExternalLinkRow(pmid: record.pmid, doi: record.doi,
            pmcid: record.pmcid, pdf: record.openAccessPdf),
          const SizedBox(height: YaoeTokens.space3),
          Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: ident == null ? '无可用标识符' : '查看全文',
              child: OutlinedButton.icon(
                onPressed: ident == null ? null : () => unawaited(showFulltextSheet(
                  context, ident: ident, title: record.title)),
                icon: const Icon(Icons.article_outlined),
                label: const Text('查看全文'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
