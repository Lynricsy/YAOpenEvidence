import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/logic/markdown_document.dart';
import '../../core/models/literature.dart';
import '../../core/session/session_controller.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/markdown_view.dart';

Future<void> showFulltextSheet(
  BuildContext context, {
  required String ident,
  required String title,
}) async {
  final size = MediaQuery.sizeOf(context);
  final child = _FulltextSheet(ident: ident, title: title);
  if (size.width < YaoeTokens.compactMaxWidth) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SizedBox(height: size.height * .92, child: child),
    );
  } else {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭全文',
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : YaoeTokens.motionMedium,
      pageBuilder: (_, _, _) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: math.min(560.0, size.width * .85),
          height: size.height,
          child: child,
        ),
      ),
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: YaoeTokens.motionCurve)),
        child: child,
      ),
    );
  }
}

class _FulltextSheet extends ConsumerStatefulWidget {
  const _FulltextSheet({required this.ident, required this.title});

  final String ident;
  final String title;

  @override
  ConsumerState<_FulltextSheet> createState() => _FulltextSheetState();
}

class _FulltextSheetState extends ConsumerState<_FulltextSheet> {
  AsyncValue<FulltextResult> _value = const AsyncLoading();
  List<FulltextSection> _sections = const [];
  String _section = '';
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load(''));
  }

  Future<void> _load(String section) async {
    final request = ++_request;
    setState(() {
      _section = section;
      _value = const AsyncLoading();
    });
    final value = await AsyncValue.guard(() => ref.read(apiClientProvider)
        .literatureFulltext(ident: widget.ident, section: section, maxChars: 20000));
    if (!mounted || request != _request) return;
    setState(() {
      _value = value;
      if (section.isEmpty && value.hasValue) {
        _sections = value.requireValue.sections;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _value.error;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(YaoeTokens.space4),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium)),
                  IconButton(
                    tooltip: '关闭全文',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(YaoeTokens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: YaoeTokens.space2,
                      runSpacing: YaoeTokens.space2,
                      children: [
                        ChoiceChip(label: const Text('目录与摘要'), selected: _section.isEmpty,
                          onSelected: (_) => unawaited(_load(''))),
                        ChoiceChip(label: const Text('全部'), selected: _section == 'all',
                          onSelected: (_) => unawaited(_load('all'))),
                        for (final section in _sections)
                          ChoiceChip(label: Text(section.title), selected: _section == section.title,
                            onSelected: (_) => unawaited(_load(section.title))),
                      ],
                    ),
                    const SizedBox(height: YaoeTokens.space4),
                    if (error is ApiError && error.code == 'fulltext_unavailable')
                      const EmptyState(icon: Icons.article_outlined,
                        title: 'Europe PMC 无可用全文')
                    else
                      AsyncValueView<FulltextResult>(
                        value: _value,
                        onRetry: () => unawaited(_load(_section)),
                        builder: (result) {
                          final text = _section.isEmpty ? result.abstract : result.text ?? '';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (result.citation.isNotEmpty) ...[
                                Text(result.citation, style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: YaoeTokens.space3),
                              ],
                              if (text.trim().isEmpty)
                                EmptyState(icon: Icons.article_outlined,
                                  title: _section.isEmpty ? '无摘要' : '该章节暂无正文')
                              else
                                MarkdownDocumentView(blocks: parseMarkdown(text)),
                              if (result.truncated) ...[
                                const SizedBox(height: YaoeTokens.space4),
                                Text('已截断，仅显示前 20000 字符',
                                  style: TextStyle(color: context.yaoe.warning)),
                              ],
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
