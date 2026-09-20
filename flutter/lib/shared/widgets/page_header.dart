import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 页面标题区：衬线标题 + 说明 + 右侧操作。
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: PicoSeekTokens.sectionSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                if (description != null) ...[
                  const SizedBox(height: PicoSeekTokens.space1),
                  Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Wrap(spacing: PicoSeekTokens.space2, children: actions),
        ],
      ),
    );
  }
}

/// 页面内容的统一约束：最大宽度 + 内边距。
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = PicoSeekTokens.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          PicoSeekTokens.pageInset,
          PicoSeekTokens.space5,
          PicoSeekTokens.pageInset,
          PicoSeekTokens.space5 + MediaQuery.paddingOf(context).bottom,
        ),
        // 底部保留区只消费一次，防止内部 ListView 再叠一遍。
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: child,
        ),
      ),
    ),
  );
}
