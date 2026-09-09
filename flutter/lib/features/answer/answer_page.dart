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
import '../ask/engine_picker.dart';
import '../ask/filter_sheet.dart';
import '../reader/reader_pane.dart';
import '../reader/split_view.dart';
import 'answer_body.dart';
import 'answer_controller.dart';
import 'job_live_monitor.dart';
import 'progress_pipeline.dart';
import 'source_list.dart';
import 'thread_nav.dart';
import 'trace_list.dart';

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

  /// 新建一轮问答（标准引擎，或智能体引擎尚未 ready 时）。
  Future<void> _submitNew(String question) async {
    await _submit(() async {
      final filters = ref.read(askFiltersControllerProvider);
      return ref
          .read(apiClientProvider)
          .createAnswer(filters.toAnswerCreate(question));
    });
  }

  /// 追问：续接同一智能体会话，其余选项沿用被追问的那一轮。
  Future<void> _submitFollowUp(String question) async {
    await _submit(
      () => ref
          .read(apiClientProvider)
          .followUp(widget.answerId, FollowupCreate(question: question)),
    );
  }

  Future<void> _submit(Future<Answer> Function() request) async {
    setState(() => _submitting = true);
    try {
      final answer = await request();
      ref.read(answersVersionProvider.notifier).bump();
      ref.invalidate(answerThreadProvider(widget.answerId));
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
        // 智能体的已完成回合才能续接，其余情况一律新建一轮。
        onSubmit:
            (answer.engine == AnswerEngine.codex &&
                answer.status == AnswerStatus.ready)
            ? _submitFollowUp
            : _submitNew,
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
    final codex = answer.engine == AnswerEngine.codex;
    // 只有智能体会话才有多轮，标准引擎不必为此多发一个请求。
    final thread = codex
        ? (ref.watch(answerThreadProvider(answer.id)).value ??
              const <AnswerSummary>[])
        : const <AnswerSummary>[];

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
                    if (thread.length > 1) ...[
                      ThreadNav(turns: thread, currentId: answer.id),
                      const SizedBox(height: YaoeTokens.space3),
                    ],
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
                          // 智能体没有「筛选」这层语义，只是重新问一次。
                          label: Text(codex ? '重新提问' : '沿用筛选重新提问'),
                        ),
                      ],
                    ),
                    const SizedBox(height: YaoeTokens.space5),
                    if (answer.status.isActive)
                      liveState == null
                          ? const LoadingView()
                          : ProgressPipeline(
                              state: liveState,
                              engine: answer.engine,
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
          // 智能体的已完成回合可以续接，输入框锁定引擎并换占位文案。
          mode: (codex && answer.status == AnswerStatus.ready)
              ? ComposerMode.followUp
              : ComposerMode.ask,
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
    // 智能体没有逐篇原文快照：正文不做结构化拆分，也没有来源列表可给。
    if (answer.engine == AnswerEngine.codex) {
      return _AgentBody(
        answer: answer,
        bodyMd: bodyMd ?? '',
        onOpenReader: onOpenReader,
      );
    }
    // 旧版答案没有结构化正文，取渲染稿 Markdown。
    if (bodyMd == null || bodyMd.trim().isEmpty) {
      final legacy = ref.watch(legacyAnswerMarkdownProvider(answer.id));
      return AsyncValueView<String>(
        value: legacy,
        onRetry: () => ref.invalidate(legacyAnswerMarkdownProvider(answer.id)),
        builder: (markdown) => _BodyWithSources(
          answer: answer,
          bodyMd: markdown,
          structured: false,
          onOpenReader: onOpenReader,
        ),
      );
    }
    return _BodyWithSources(
      answer: answer,
      bodyMd: bodyMd,
      structured: true,
      onOpenReader: onOpenReader,
    );
  }
}

/// 智能体答案：整篇正文 + 可折叠的检索轨迹。
class _AgentBody extends StatelessWidget {
  const _AgentBody({
    required this.answer,
    required this.bodyMd,
    required this.onOpenReader,
  });

  final Answer answer;
  final String bodyMd;
  final void Function(CitationRef ref) onOpenReader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnswerBody(
          bodyMd: bodyMd,
          papers: answer.papers,
          onCitationTap: onOpenReader,
          structured: false,
        ),
        if (answer.trace.isNotEmpty) ...[
          const SizedBox(height: YaoeTokens.space5),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(
                bottom: YaoeTokens.space2,
              ),
              title: Text(
                '检索轨迹（${answer.trace.length}）',
                style: theme.textTheme.labelLarge,
              ),
              children: [TraceList(calls: answer.trace)],
            ),
          ),
        ],
        if (answer.kbHits.isNotEmpty) ...[
          const SizedBox(height: YaoeTokens.space6),
          KbSupplementList(hits: answer.kbHits),
        ],
      ],
    );
  }
}

class _BodyWithSources extends StatelessWidget {
  const _BodyWithSources({
    required this.answer,
    required this.bodyMd,
    required this.structured,
    required this.onOpenReader,
  });

  final Answer answer;
  final String bodyMd;
  final bool structured;
  final void Function(CitationRef ref) onOpenReader;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AnswerBody(
        bodyMd: bodyMd,
        papers: answer.papers,
        onCitationTap: onOpenReader,
        structured: structured,
      ),
      const SizedBox(height: YaoeTokens.space6),
      SourceList(
        papers: answer.papers,
        bodyMd: bodyMd,
        onOpen: onOpenReader,
      ),
      if (answer.kbHits.isNotEmpty) ...[
        const SizedBox(height: YaoeTokens.space6),
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
    // 正常连接不出现指示灯：只有在等或出问题时才值得占位。
    final note = connection?.label;
    final indicatorColor = connection == SseConnection.reconnecting
        ? colors.warning
        : theme.colorScheme.onSurfaceVariant;

    return Wrap(
      spacing: YaoeTokens.space3,
      runSpacing: YaoeTokens.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StatusBadge(status: answer.status),
        // Wrap 的 spacing 对零尺寸子项也生效，标准引擎下别留个空档。
        if (answer.engine.isCodex) EngineBadge(engine: answer.engine),
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
        if (note != null)
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
                note,
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

/// 底部常驻提问 Dock：新建一轮问答，或在智能体会话上追问。
class _ComposerDock extends ConsumerWidget {
  const _ComposerDock({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
    required this.mode,
  });

  final TextEditingController controller;
  final bool submitting;
  final void Function(String question) onSubmit;
  final ComposerMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final followUp = mode == ComposerMode.followUp;
    final filters = ref.watch(askFiltersControllerProvider);
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
            mode: mode,
            // 追问沿用会话引擎，占位文案由 mode 决定。
            hintText: followUp ? null : '继续提问…',
            engine: followUp ? AnswerEngine.codex : filters.engine,
            onEngineChanged: (engine) => ref
                .read(askFiltersControllerProvider.notifier)
                .set(filters.copyWith(engine: engine)),
            trailing: followUp
                ? const []
                : [
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
