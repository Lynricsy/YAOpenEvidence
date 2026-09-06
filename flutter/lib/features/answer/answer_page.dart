import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/answers_version.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/logic/ask_filters.dart';
import '../../core/logic/citations.dart';
import '../../core/models/answers.dart';
import '../../core/session/session_controller.dart';
import '../../shared/format.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/loadable.dart';
import '../ask/ask_state.dart';
import '../ask/composer.dart';
import '../ask/filter_sheet.dart';
import '../reader/reader_pane.dart';
import '../reader/split_view.dart';
import 'answer_body.dart';
import 'answer_controller.dart';
import 'job_live_monitor.dart';
import 'progress_pipeline.dart';
import 'source_list.dart';

class AnswerPage extends ConsumerStatefulWidget {
  const AnswerPage({super.key, required this.answerId});

  final String answerId;

  @override
  ConsumerState<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends ConsumerState<AnswerPage> {
  final _composer = TextEditingController();
  bool _submitting = false;
  bool _busy = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _openReader(CitationRef ref_) {
    final width = MediaQuery.sizeOf(context).width;
    ref.read(readerTargetProvider(widget.answerId).notifier).open(ref_);
    if (width >= YaoeTokens.expandedMinWidth) return; // 并排布局直接更新
    if (width < YaoeTokens.compactMaxWidth) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.92,
          child: _ReaderHost(answerId: widget.answerId),
        ),
      ).whenComplete(_closeReader);
      return;
    }
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭阅读器',
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : YaoeTokens.motionFast,
      pageBuilder: (context, animation, secondary) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            width: _sideSheetWidth(context),
            height: double.infinity,
            child: SafeArea(child: _ReaderHost(answerId: widget.answerId)),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondary, child) =>
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: YaoeTokens.motionCurve),
            ),
            child: child,
          ),
    ).whenComplete(_closeReader);
  }

  void _closeReader() {
    if (!mounted) return;
    ref.read(readerTargetProvider(widget.answerId).notifier).close();
  }

  Future<void> _submitFollowUp(String question) async {
    setState(() => _submitting = true);
    try {
      final filters = ref.read(askFiltersControllerProvider);
      final answer = await ref
          .read(apiClientProvider)
          .createAnswer(filters.toAnswerCreate(question));
      ref.read(answersVersionProvider.notifier).bump();
      _composer.clear();
      if (!mounted) return;
      context.go('/a/${answer.id}');
    } on ApiError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.userMessage)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showConfirm(
      context,
      title: '取消任务',
      body: '已产生的检索与阅读结果会保留，但不会生成答案。',
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(answerControllerProvider(widget.answerId).notifier)
          .cancel();
    } on ApiError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.userMessage)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirm(
      context,
      title: '删除问答',
      body: '删除后不可恢复。',
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(answerControllerProvider(widget.answerId).notifier)
          .delete();
      if (!mounted) return;
      context.go('/history');
    } on ApiError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.userMessage)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reuseFilters(Answer answer) {
    ref
        .read(askFiltersControllerProvider.notifier)
        .set(AskFilters.fromOptions(answer.options));
    ref.read(askDraftProvider.notifier).set(answer.question);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= YaoeTokens.expandedMinWidth;
    final target = ref.watch(readerTargetProvider(widget.answerId));
    final answerAsync = ref.watch(answerControllerProvider(widget.answerId));

    final main = AsyncValueView<Answer>(
      value: answerAsync,
      onRetry: () =>
          ref.invalidate(answerControllerProvider(widget.answerId)),
      builder: (answer) => _AnswerContent(
        answer: answer,
        busy: _busy,
        submitting: _submitting,
        composer: _composer,
        onOpenReader: _openReader,
        onCancel: _cancel,
        onDelete: _delete,
        onReuse: () => _reuseFilters(answer),
        onSubmit: _submitFollowUp,
      ),
    );

    if (wide && target != null) {
      return SplitView(
        left: main,
        right: _ReaderHost(answerId: widget.answerId, onClose: _closeReader),
      );
    }
    return main;
  }
}

double _sideSheetWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width * 0.85;
  return width < 560 ? width : 560;
}

/// 阅读器宿主：跟随 `readerTargetProvider`，目标为空时显示提示。
class _ReaderHost extends ConsumerWidget {
  const _ReaderHost({required this.answerId, this.onClose});

  final String answerId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(readerTargetProvider(answerId));
    if (target == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: ReaderPane(
        answerId: answerId,
        target: target,
        onClose: onClose ?? () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class _AnswerContent extends ConsumerWidget {
  const _AnswerContent({
    required this.answer,
    required this.busy,
    required this.submitting,
    required this.composer,
    required this.onOpenReader,
    required this.onCancel,
    required this.onDelete,
    required this.onReuse,
    required this.onSubmit,
  });

  final Answer answer;
  final bool busy;
  final bool submitting;
  final TextEditingController composer;
  final void Function(CitationRef ref) onOpenReader;
  final Future<void> Function() onCancel;
  final Future<void> Function() onDelete;
  final VoidCallback onReuse;
  final void Function(String question) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final jobId = answer.jobId;
    final liveState = (answer.status.isActive && jobId != null)
        ? ref.watch(jobLiveMonitorProvider(jobId))
        : null;
    final cancelRequested = ref
        .watch(answerControllerProvider(answer.id).notifier)
        .cancelRequested;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(YaoeTokens.space5),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(answer.question, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: YaoeTokens.space3),
                    _MetaRow(answer: answer, connection: liveState?.connection),
                    if (answer.queries.isNotEmpty) ...[
                      const SizedBox(height: YaoeTokens.space2),
                      _Queries(queries: answer.queries),
                    ],
                    const SizedBox(height: YaoeTokens.space3),
                    Wrap(
                      spacing: YaoeTokens.space2,
                      runSpacing: YaoeTokens.space2,
                      children: [
                        if (answer.status.isActive && answer.jobId != null)
                          OutlinedButton.icon(
                            onPressed: (busy || cancelRequested)
                                ? null
                                : onCancel,
                            icon: const Icon(Icons.stop_circle_outlined,
                                size: 16),
                            label: Text(cancelRequested ? '正在取消…' : '取消'),
                          ),
                        if (!answer.status.isActive)
                          OutlinedButton.icon(
                            onPressed: busy ? null : onDelete,
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('删除'),
                          ),
                        OutlinedButton.icon(
                          onPressed: onReuse,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('沿用筛选重新提问'),
                        ),
                      ],
                    ),
                    const SizedBox(height: YaoeTokens.space5),
                    if (answer.status.isActive)
                      liveState == null
                          ? const LoadingView()
                          : ProgressPipeline(
                              state: liveState,
                              onCandidateTap: (pmid) => ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '任务仍在进行中，原文与核实材料会在逐篇阅读阶段结束后出现。',
                                  ),
                                ),
                              ),
                            ),
                    if (answer.status == AnswerStatus.failed)
                      _FailureCard(error: answer.error),
                    if (answer.status == AnswerStatus.cancelled)
                      _NoticeCard(
                        icon: Icons.stop_circle_outlined,
                        color: context.yaoe.warning,
                        title: '任务已取消',
                        body: '可以调整筛选后重新提问。',
                      ),
                    if (answer.status == AnswerStatus.ready)
                      _ReadyBody(answer: answer, onOpenReader: onOpenReader),
                  ],
                ),
              ),
            ),
          ),
        ),
        _ComposerDock(
          controller: composer,
          submitting: submitting,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}

class _ReadyBody extends ConsumerWidget {
  const _ReadyBody({required this.answer, required this.onOpenReader});

  final Answer answer;
  final void Function(CitationRef ref) onOpenReader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyMd = answer.bodyMd;
    // 旧版答案没有结构化正文，取渲染稿 Markdown。
    if (bodyMd == null || bodyMd.trim().isEmpty) {
      final legacy = ref.watch(legacyAnswerMarkdownProvider(answer.id));
      return AsyncValueView<String>(
        value: legacy,
        onRetry: () => ref.invalidate(legacyAnswerMarkdownProvider(answer.id)),
        builder: (markdown) => _BodyWithSources(
          answer: answer,
          bodyMd: markdown,
          onOpenReader: onOpenReader,
        ),
      );
    }
    return _BodyWithSources(
      answer: answer,
      bodyMd: bodyMd,
      onOpenReader: onOpenReader,
    );
  }
}

class _BodyWithSources extends StatelessWidget {
  const _BodyWithSources({
    required this.answer,
    required this.bodyMd,
    required this.onOpenReader,
  });

  final Answer answer;
  final String bodyMd;
  final void Function(CitationRef ref) onOpenReader;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AnswerBody(
        bodyMd: bodyMd,
        papers: answer.papers,
        onCitationTap: onOpenReader,
      ),
      const SizedBox(height: YaoeTokens.space5),
      SourceList(
        papers: answer.papers,
        bodyMd: bodyMd,
        onOpen: onOpenReader,
      ),
      if (answer.kbHits.isNotEmpty) ...[
        const SizedBox(height: YaoeTokens.space5),
        KbSupplementList(hits: answer.kbHits),
      ],
    ],
  );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.answer, required this.connection});

  final Answer answer;
  final SseConnection? connection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.yaoe;
    final indicatorColor = switch (connection) {
      SseConnection.open => colors.success,
      SseConnection.reconnecting => colors.warning,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Wrap(
      spacing: YaoeTokens.space3,
      runSpacing: YaoeTokens.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StatusBadge(status: answer.status),
        if ((answer.filtersLabel ?? '').isNotEmpty)
          Text(
            answer.filtersLabel!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        Text(
          relativeTime(answer.createdAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (answer.nPapers != null)
          Text(
            '阅读 ${answer.nPapers} 篇 · 全文 ${answer.nFulltext ?? 0} 篇',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (connection != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor,
                ),
              ),
              const SizedBox(width: YaoeTokens.space1),
              Text(
                connection!.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: indicatorColor,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Queries extends StatelessWidget {
  const _Queries({required this.queries});

  final List<String> queries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          '检索式 ${queries.length} 条',
          style: theme.textTheme.labelLarge,
        ),
        children: [
          for (final query in queries)
            Padding(
              padding: const EdgeInsets.only(bottom: YaoeTokens.space1),
              child: SelectableText(
                query,
                style: theme.textTheme.labelSmall?.merge(monoStyle),
              ),
            ),
        ],
      ),
    );
  }
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.error});

  final JobError? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = error?.code ?? 'internal_error';
    return _NoticeCard(
      icon: Icons.error_outline,
      color: theme.colorScheme.error,
      title: jobErrorMessage(code),
      body: (error?.message ?? '').isEmpty ? null : error!.message,
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.color,
    required this.title,
    this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(YaoeTokens.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: YaoeTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
                if (body != null) ...[
                  const SizedBox(height: YaoeTokens.space1),
                  Text(body!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部常驻提问 Dock：提交即新建问答并跳转。
class _ComposerDock extends StatelessWidget {
  const _ComposerDock({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool submitting;
  final void Function(String question) onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        YaoeTokens.space4,
        YaoeTokens.space2,
        YaoeTokens.space4,
        YaoeTokens.space3,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Composer(
            controller: controller,
            onSubmit: onSubmit,
            submitting: submitting,
            dock: true,
            hintText: '继续提问…',
            trailing: [
              IconButton(
                tooltip: '筛选',
                onPressed: () => showFilterSheet(context),
                icon: const Icon(Icons.tune, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
