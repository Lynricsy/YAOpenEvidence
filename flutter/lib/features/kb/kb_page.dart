import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/logic/job_live.dart';
import '../../core/models/jobs.dart';
import '../../core/models/kb.dart';
import '../../core/session/session_controller.dart';
import '../../shared/format.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/stat_block.dart';
import '../answer/job_live_monitor.dart';
import 'kb_controller.dart';

class KbPage extends ConsumerStatefulWidget {
  const KbPage({super.key});

  @override
  ConsumerState<KbPage> createState() => _KbPageState();
}

class _KbPageState extends ConsumerState<KbPage> {
  final _query = TextEditingController();
  bool _startingReindex = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search() {
    unawaited(ref.read(kbSearchControllerProvider.notifier).search(_query.text));
  }

  Future<void> _reindex() async {
    final confirmed = await showConfirm(
      context,
      title: '重建索引',
      body: '将重新生成知识库的向量索引。确定继续吗？',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _startingReindex = true);
    final reindexJob = ref.read(kbReindexJobProvider.notifier);
    try {
      final job = await ref.read(apiClientProvider).reindexKb();
      reindexJob.set(job);
    } on ApiError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.userMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _startingReindex = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(kbStatsProvider);
    final result = ref.watch(kbSearchControllerProvider);
    final controller = ref.read(kbSearchControllerProvider.notifier);
    final job = ref.watch(kbReindexJobProvider);
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '知识库',
              description: '事实与段落的语义检索',
              actions: [
                if (ref.watch(isAdminProvider))
                  OutlinedButton.icon(
                    onPressed: _startingReindex || job != null ? null : _reindex,
                    icon: const Icon(Icons.refresh_outlined),
                    label: Text(_startingReindex ? '提交中' : '重建索引'),
                  ),
              ],
            ),
            AsyncValueView<KbStats>(
              value: stats,
              onRetry: () => ref.invalidate(kbStatsProvider),
              builder: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth < 600
                          ? constraints.maxWidth
                          : (constraints.maxWidth - YaoeTokens.space3 * 2) / 3;
                      return Wrap(
                        spacing: YaoeTokens.space3,
                        runSpacing: YaoeTokens.space3,
                        children: [
                          SizedBox(
                            width: width,
                            child: StatBlock(label: '条目', value: formatCount(data.items)),
                          ),
                          SizedBox(
                            width: width,
                            child: StatBlock(label: '论文', value: formatCount(data.papers)),
                          ),
                          SizedBox(
                            width: width,
                            child: StatBlock(
                              label: '嵌入器',
                              value: data.embedder ?? '未加载',
                              note: '维度 ${data.dim ?? "未知"}',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: YaoeTokens.space3),
                  Wrap(
                    spacing: YaoeTokens.space2,
                    runSpacing: YaoeTokens.space2,
                    children: [
                      for (final entry in data.byKind.entries)
                        Pill(
                          text: '${switch (entry.key) { "fact" => KbKind.fact.label, "paragraph" => KbKind.paragraph.label, _ => entry.key }} ${formatCount(entry.value)}',
                          color: colors.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (job != null) ...[
              const SizedBox(height: YaoeTokens.space4),
              _ReindexProgress(key: ValueKey(job.id), jobId: job.id),
            ],
            const SizedBox(height: YaoeTokens.space5),
            TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: '检索知识库',
                prefixIcon: Icon(Icons.search_outlined),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: YaoeTokens.space3),
            Wrap(
              spacing: YaoeTokens.space3,
              runSpacing: YaoeTokens.space3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<KbKind?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('全部')),
                    ButtonSegment(value: KbKind.fact, label: Text('事实')),
                    ButtonSegment(value: KbKind.paragraph, label: Text('段落')),
                  ],
                  selected: {controller.kind},
                  onSelectionChanged: (values) => setState(() => controller.setKind(values.first)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('条数'),
                    const SizedBox(width: YaoeTokens.space2),
                    DropdownButton<int>(
                      value: controller.topK,
                      items: [
                        for (final count in const [5, 8, 15, 30])
                          DropdownMenuItem(value: count, child: Text('$count')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => controller.setTopK(value));
                      },
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: result.isLoading ? null : _search,
                  icon: const Icon(Icons.search_outlined),
                  label: Text(result.isLoading ? '检索中' : '搜索'),
                ),
              ],
            ),
            const SizedBox(height: YaoeTokens.space4),
            AsyncValueView<KbSearchResult?>(
              value: result,
              onRetry: _search,
              builder: (data) {
                if (data == null) {
                  return Container(
                    padding: const EdgeInsets.all(YaoeTokens.space3),
                    color: context.yaoe.info.withValues(alpha: 0.08),
                    child: Text(
                      '首次检索需加载嵌入模型，约 15 秒',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.yaoe.info),
                    ),
                  );
                }
                if (data.items.isEmpty) {
                  return const EmptyState(icon: Icons.search_off_outlined, title: '未找到相关内容');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final hit in data.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: YaoeTokens.space3),
                        child: _HitCard(hit: hit),
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

class _HitCard extends StatelessWidget {
  const _HitCard({required this.hit});

  final KbHit hit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hit.pmid.isEmpty
            ? null
            : () => context.go('/library/${Uri.encodeComponent(hit.pmid)}${hit.pid != null ? '?pid=${hit.pid}' : ''}'),
        child: Padding(
          padding: const EdgeInsets.all(YaoeTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: YaoeTokens.space2,
                runSpacing: YaoeTokens.space2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Pill(text: hit.kind.label, color: theme.colorScheme.primary),
                  if (hit.verified != null) VerifiedPill(verified: hit.verified!),
                  if (hit.pid != null) Text('¶${hit.pid}'),
                  Text('相似度 ${formatScore(hit.score)}', style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: YaoeTokens.space3),
              Text(hit.textZh ?? hit.text, style: theme.textTheme.bodyMedium),
              const SizedBox(height: YaoeTokens.space3),
              Text(
                [hit.title, hit.journal, hit.year].where((part) => part.isNotEmpty).join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReindexProgress extends ConsumerStatefulWidget {
  const _ReindexProgress({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<_ReindexProgress> createState() => _ReindexProgressState();
}

class _ReindexProgressState extends ConsumerState<_ReindexProgress> {
  Timer? _poll;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(jobLiveMonitorProvider(widget.jobId), (_, next) {
      final terminal = next.live.terminal;
      if (terminal == null) return;
      // 首次订阅可能回放终态，延后提交以免在父组件构建时修改状态。
      scheduleMicrotask(() => _finish(terminal));
    }, fireImmediately: true);
    // SSE 可能被代理掐断而不重连成功；REST 兜底保证进度条不会永远转下去。
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final Job job;
    try {
      job = await ref.read(apiClientProvider).job(widget.jobId);
    } on ApiError {
      return;                       // 网络抖动或鉴权失效，下一个周期再试
    }
    if (!mounted) return;
    final terminal = jobTerminal(job);
    if (terminal == null) return;
    scheduleMicrotask(() => _finish(terminal));
  }

  void _finish(Terminal terminal) {
    if (_done) return;
    _done = true;
    _poll?.cancel();
    if (!mounted || ref.read(kbReindexJobProvider)?.id != widget.jobId) return;
    ref.invalidate(kbStatsProvider);
    ref.read(kbReindexJobProvider.notifier).set(null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(reindexTerminalMessage(terminal))));
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobLiveMonitorProvider(widget.jobId));
    final progress = state.live.progress;
    final reindexProgress = progress?.stage == StageKey.reindex ? progress : null;
    final color = switch (state.connection) {
      SseConnection.open => context.yaoe.success,
      SseConnection.reconnecting => context.yaoe.warning,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    final logs = state.live.logs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: YaoeTokens.space3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('重建索引', style: Theme.of(context).textTheme.titleMedium),
            Pill(text: state.connection.label, color: color, icon: Icons.circle),
          ],
        ),
        const SizedBox(height: YaoeTokens.space3),
        LinearProgressIndicator(
          value: reindexProgress != null && reindexProgress.total > 0
              ? (reindexProgress.current / reindexProgress.total).clamp(0.0, 1.0)
              : null,
        ),
        if (reindexProgress?.title case final String title) ...[
          const SizedBox(height: YaoeTokens.space2),
          Text(title),
        ],
        if (logs.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('运行日志'),
            children: [
              for (final line in logs.skip(logs.length > 20 ? logs.length - 20 : 0))
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    line.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: line.level == LogLevel.warning ? context.yaoe.warning : null,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
