import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 自适应面板：紧凑宽度用 0.92 高的模态底部 sheet，其余从右侧滑入抽屉
/// （宽 `min(85%, 560)`，与阅读器规则一致）。头部为标题 + 「完成」。
///
/// 筛选面板与全文面板共用此实现。
Future<T?> showAdaptiveSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  if (MediaQuery.sizeOf(context).width < YaoeTokens.compactMaxWidth) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _SheetFrame(title: title, child: child),
      ),
    );
  }
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭$title',
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : YaoeTokens.motionFast,
    pageBuilder: (context, animation, secondary) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          width: _sideWidth(context),
          height: double.infinity,
          child: SafeArea(
            child: _SheetFrame(title: title, child: child),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondary, child) =>
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animation,
                  curve: YaoeTokens.motionCurve,
                ),
              ),
          child: child,
        ),
  );
}

double _sideWidth(BuildContext context) {
  final candidate = MediaQuery.sizeOf(context).width * 0.85;
  return candidate < 560 ? candidate : 560;
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            YaoeTokens.pageInset,
            YaoeTokens.space3,
            YaoeTokens.space2,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              // 改动即时生效，关闭就是确认，所以只留「完成」不留 ✕。
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('完成'),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
