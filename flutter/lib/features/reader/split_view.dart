import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/session/prefs.dart';

part 'split_view.g.dart';

/// 分栏比例（答案区占比，0.40–0.60），持久化到 `picoseek.reader-layout`。
@Riverpod(keepAlive: true)
class ReaderLayout extends _$ReaderLayout {
  static const minAnswerFraction = 0.40;
  static const maxAnswerFraction = 0.60;

  @override
  double build() {
    final stored = ref.watch(prefsProvider).getJson(PrefKeys.readerLayout);
    final answer = stored?['answer'];
    if (answer is num) {
      final fraction = answer.toDouble() / 100;
      return fraction.clamp(minAnswerFraction, maxAnswerFraction);
    }
    return minAnswerFraction;
  }

  Future<void> set(double fraction) async {
    final clamped = fraction.clamp(minAnswerFraction, maxAnswerFraction);
    state = clamped;
    await ref.read(prefsProvider).setJson(PrefKeys.readerLayout, {
      'answer': (clamped * 100).round(),
      'reader': 100 - (clamped * 100).round(),
    });
  }
}

/// 答案 / 阅读器并排布局：8 px 拖拽分隔条，右侧最小 360 px。
class SplitView extends ConsumerStatefulWidget {
  const SplitView({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  ConsumerState<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends ConsumerState<SplitView> {
  static const dividerWidth = 12.0;
  static const minReaderWidth = 360.0;

  double? _dragFraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stored = ref.watch(readerLayoutProvider);
    final fraction = _dragFraction ?? stored;

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        var leftWidth = (total - dividerWidth) * fraction;
        // 右侧至少 360 px：窗口收窄时优先保证阅读器可读。
        if (total - dividerWidth - leftWidth < minReaderWidth) {
          leftWidth = (total - dividerWidth - minReaderWidth).clamp(
            0.0,
            total - dividerWidth,
          );
        }

        return Row(
          // 两栏撑满高度：答案侧的悬浮提问框依赖父级给出确定的高度。
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: leftWidth, child: widget.left),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final next =
                      (leftWidth + details.delta.dx) / (total - dividerWidth);
                  setState(
                    () => _dragFraction = next.clamp(
                      ReaderLayout.minAnswerFraction,
                      ReaderLayout.maxAnswerFraction,
                    ),
                  );
                },
                onHorizontalDragEnd: (_) {
                  final value = _dragFraction;
                  if (value != null) {
                    ref.read(readerLayoutProvider.notifier).set(value);
                  }
                  setState(() => _dragFraction = null);
                },
                child: Container(
                  width: dividerWidth,
                  height: double.infinity,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 1,
                        height: double.infinity,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: widget.right),
          ],
        );
      },
    );
  }
}
