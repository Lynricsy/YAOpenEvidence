import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/answers_version.dart';
import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/session/session_controller.dart';
import 'ask_state.dart';
import 'composer.dart';
import 'filter_panel.dart';
import 'filter_sheet.dart';
import 'hero.dart';

class AskPage extends ConsumerStatefulWidget {
  const AskPage({super.key});

  @override
  ConsumerState<AskPage> createState() => _AskPageState();
}

class _AskPageState extends ConsumerState<AskPage> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(askDraftProvider);
    // 边输入边写回草稿：Riverpod 3 禁止在 dispose 里碰 ref，
    // 所以不能等到离开页面再存。
    _controller.addListener(_saveDraft);
  }

  void _saveDraft() =>
      ref.read(askDraftProvider.notifier).set(_controller.text);

  @override
  void dispose() {
    _controller.removeListener(_saveDraft);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String question) async {
    final filters = ref.read(askFiltersControllerProvider);
    if (!filters.isYearRangeValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('年份区间不合法：结束年不得早于起始年')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final answer = await ref
          .read(apiClientProvider)
          .createAnswer(filters.toAnswerCreate(question));
      ref.read(answersVersionProvider.notifier).bump();
      ref.read(askDraftProvider.notifier).clear();
      _controller.clear();
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

  void _useExample(String question) {
    _controller.text = question;
    _controller.selection = TextSelection.collapsed(
      offset: question.length,
    );
    ref.read(askDraftProvider.notifier).set(question);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= YaoeTokens.expandedMinWidth;
    final filters = ref.watch(askFiltersControllerProvider);
    // 草稿可能被答案页的「沿用筛选重新提问」改写。
    ref.listen(askDraftProvider, (previous, next) {
      if (next != _controller.text) _controller.text = next;
    });

    final main = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: YaoeTokens.space5,
        vertical: YaoeTokens.space6,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AskHero(onExample: _useExample),
              const SizedBox(height: YaoeTokens.space6),
              Composer(
                controller: _controller,
                onSubmit: _submit,
                engine: filters.engine,
                onEngineChanged: (engine) => ref
                    .read(askFiltersControllerProvider.notifier)
                    .set(filters.copyWith(engine: engine)),
                submitting: _submitting,
                autofocus: true,
                trailing: wide
                    ? const []
                    : [
                        IconButton(
                          tooltip: '筛选',
                          onPressed: () => showFilterSheet(context),
                          icon: const Icon(Icons.tune, size: 18),
                        ),
                      ],
              ),
              const SizedBox(height: YaoeTokens.space6),
              AskExamples(onExample: _useExample),
            ],
          ),
        ),
      ),
    );

    if (!wide) return main;
    return Row(
      children: [
        Expanded(child: main),
        const FilterColumn(),
      ],
    );
  }
}
