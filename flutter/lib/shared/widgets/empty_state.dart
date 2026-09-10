import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 空状态：图标 + 标题 + 描述 + 可选操作。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: YaoeTokens.pageInset,
        vertical: YaoeTokens.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.outline),
          const SizedBox(height: YaoeTokens.space3),
          Text(title, style: theme.textTheme.titleMedium),
          if (description != null) ...[
            const SizedBox(height: YaoeTokens.space1),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: YaoeTokens.space3),
            action!,
          ],
        ],
      ),
    );
  }
}
