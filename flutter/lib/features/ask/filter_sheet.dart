import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import 'filter_panel.dart';

/// 打开筛选面板：窄屏底部 sheet，其余从右侧滑入（与阅读器规则一致）。
Future<void> showFilterSheet(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < YaoeTokens.compactMaxWidth) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _SheetFrame(child: const FilterPanel()),
      ),
    );
  }
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭筛选',
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : YaoeTokens.motionFast,
    pageBuilder: (context, animation, secondary) {
      final theme = Theme.of(context);
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: theme.colorScheme.surface,
          child: SizedBox(
            width: _sideWidth(context),
            height: double.infinity,
            child: SafeArea(child: _SheetFrame(child: const FilterPanel())),
          ),
        ),
      );
    },
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
  );
}

double _sideWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final candidate = width * 0.85;
  return candidate < 560 ? candidate : 560;
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            YaoeTokens.space4,
            YaoeTokens.space3,
            YaoeTokens.space2,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('检索筛选', style: theme.textTheme.titleSmall),
              ),
              IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
