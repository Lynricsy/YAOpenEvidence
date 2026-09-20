import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
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
import '../../shared/widgets/surface.dart';
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
    unawaited(
      ref.read(kbSearchControllerProvider.notifier).search(_query.text),
    );
  }

  Future<void> _reindex() async {
    final confirmed = await showConfirm(
      context,
      title: '重建索引',
      body: '将重新生成知识库索引，期间检索结果可能不完整。确定继续吗？',
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _startingReindex = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = ref.watch(kbStatsProvider);
    final result = ref.watch(kbSearchControllerProvider);
    final controller = ref.read(kbSearchControllerProvider.notifier);
    final job = ref.watch(kbReindexJobProvider);
    final isAdmin = ref.watch(isAdminProvider);
    return SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(title: '知识库', description: '事实与段落的语义检索'),
            AsyncValueView<KbStats>(
              value: stats,
              onRetry: () => ref.invalidate(kbStatsProvider),
              builder: (data) => PicoSeekCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatCount(data.items),
                                style: theme.textTheme.headlineMedium?.merge(
                                  monoStyle,
                                ),
                              ),
                              Text(
                                '条知识',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${formatCount(data.papers)} 篇文献',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: PicoSeekTokens.space3),
                    Wrap(
                      spacing: PicoSeekTokens.space2,
                      runSpacing: PicoSeekTokens.space2,
                      children: [
                        for (final entry in data.byKind.entries)
                          if (_kindLabel(entry.key) case final String label)
                            Pill(
                              text: '$label ${formatCount(entry.value)}',
                              color: theme.colorScheme.primary,
                            ),
                      ],
                    ),
                    if (isAdmin) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: PicoSeekTokens.space3,
                        ),
                        child: Divider(height: 1),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _startingReindex || job != null
                              ? null
                              : _reindex,
                          icon: const Icon(Icons.refresh_outlined, size: 16),
                          label: Text(_startingReindex ? '提交中' : '重建索引'),
                        ),
                      ),
                    ],
                    if (job != null) ...[
                      const SizedBox(height: PicoSeekTokens.space4),
                      _ReindexProgress(key: ValueKey(job.id), jobId: job.id),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: PicoSeekTokens.sectionSpacing),
            TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: '检索知识库',
                prefixIcon: Icon(Icons.search_outlined),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: PicoSeekTokens.space3),
            Wrap(
              spacing: PicoSeekTokens.space3,
              runSpacing: PicoSeekTokens.space3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<KbKind?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('全部')),
                    ButtonSegment(value: KbKind.fact, label: Text('事实')),
                    ButtonSegment(value: KbKind.paragraph, label: Text('段落')),
                  ],
                  selected: {controller.kind},
                  onSelectionChanged: (values) =>
                      setState(() => controller.setKind(values.first)),
                ),
                FilledButton.icon(
                  onPressed: result.isLoading ? null : _search,
                  icon: const Icon(Icons.search_outlined),
                  label: Text(result.isLoading ? '检索中' : '搜索'),
                ),
              ],
            ),
            const SizedBox(height: PicoSeekTokens.space4),
            AsyncValueView<KbSearchResult?>(
              value: result,
              onRetry: _search,
              builder: (data) {
                if (data == null) {
                  return PicoSeekCard(
                    tint: context.picoseek.info,
                    child: Text(
                      '首次检索需要预热，约 15 秒',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.picoseek.info,
                      ),
                    ),
                  );
                }
                if (data.items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off_outlined,
                    title: '未找到相关内容',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final hit in data.items)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: PicoSeekTokens.space3,
                        ),
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

/// 已知条目种类 → 中文标签；未知种类返回 null（不渲染，别把内部键名摆给用户）。
String? _kindLabel(String kind) => switch (kind) {
  'fact' => KbKind.fact.label,
  'paragraph' => KbKind.paragraph.label,
  _ => null,
};

class _HitCard extends StatelessWidget {
  const _HitCard({required this.hit});

  final KbHit hit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PicoSeekCard(
      padding: const EdgeInsets.all(PicoSeekTokens.space4),
      onTap: hit.pmid.isEmpty
          ? null
          : () => context.go(
              '/library/${Uri.encodeComponent(hit.pmid)}'
              '${hit.pid != null ? '?pid=${hit.pid}' : ''}',
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: PicoSeekTokens.space2,
            runSpacing: PicoSeekTokens.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Pill(text: hit.kind.label, color: theme.colorScheme.primary),
              if (hit.verified != null) VerifiedPill(verified: hit.verified!),
            ],
          ),
          const SizedBox(height: PicoSeekTokens.space3),
          Text(hit.textZh ?? hit.text, style: theme.textTheme.bodyMedium),
          const SizedBox(height: PicoSeekTokens.space3),
          Text(
            [
              hit.title,
              hit.journal,
              hit.year,
            ].where((part) => part.isNotEmpty).join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
      return; // 网络抖动或鉴权失效，下一个周期再试
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
    final theme = Theme.of(context);
    final state = ref.watch(jobLiveMonitorProvider(widget.jobId));
    final progress = state.live.progress;
    final reindexProgress = progress?.stage == StageKey.reindex
        ? progress
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('重建索引', style: theme.textTheme.labelLarge),
        const SizedBox(height: PicoSeekTokens.space3),
        LinearProgressIndicator(
          value: reindexProgress != null && reindexProgress.total > 0
              ? (reindexProgress.current / reindexProgress.total).clamp(
                  0.0,
                  1.0,
                )
              : null,
        ),
        if (reindexProgress?.title case final String title) ...[
          const SizedBox(height: PicoSeekTokens.space2),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
