import 'package:flutter/material.dart';

/// 用户头像：主色淡底 + 首字母大写。侧栏用户菜单与用户管理列表共用。
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.radius = 14});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.characters.isEmpty
        ? '?'
        : name.characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.16),
      child: Text(
        initial,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
