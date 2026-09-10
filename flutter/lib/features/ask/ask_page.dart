import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/answers_version.dart';
import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/session/session_controller.dart';
import '../../shared/widgets/floating_composer.dart';
import '../../shared/widgets/page_header.dart';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.userMessage)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _useExample(String question) {
    _controller.text = question;
    _controller.selection = TextSelection.collapsed(offset: question.length);
    ref.read(askDraftProvider.notifier).set(question);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= YaoeTokens.expandedMinWidth;
    // 草稿可能被答案页的「沿用筛选重新提问」改写。
    ref.listen(askDraftProvider, (previous, next) {
      if (next != _controller.text) _controller.text = next;
    });

    // 桌面进页面直接抢焦点；移动端不抢，免得键盘一上来就盖住 Tab 栏。
    const desktop = {
      TargetPlatform.linux,
      TargetPlatform.windows,
      TargetPlatform.macOS,
    };

    final host = FloatingComposerHost(
      body: SingleChildScrollView(
        child: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AskHero(),
              const SizedBox(height: YaoeTokens.moduleSpacing),
              AskExamples(onExample: _useExample),
            ],
          ),
        ),
      ),
      composer: Composer(
        controller: _controller,
        onSubmit: _submit,
        submitting: _submitting,
        autofocus: desktop.contains(defaultTargetPlatform),
        onFilterTap: wide ? null : () => showFilterSheet(context),
      ),
    );

    if (!wide) return host;
    return Row(
      // 两列都必须撑满高度，否则 Stack 收缩到内容高度、内容被垂直居中。
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: host),
        // 吞掉筛选列的滚动通知：滚它不该把提问框收起来。
        NotificationListener<ScrollNotification>(
          onNotification: (_) => true,
          child: const FilterColumn(),
        ),
      ],
    );
  }
}
