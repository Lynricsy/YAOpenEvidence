import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme_controller.dart';
import '../../app/theme/tokens.dart';
import '../../core/session/session_controller.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/confirm_dialog.dart';

enum _UserAction { account, themeSystem, themeLight, themeDark, logout }

/// 账号菜单：账号设置 / 主题三选 / 退出登录。
class UserMenu extends ConsumerWidget {
  const UserMenu({super.key, this.compact = false});

  /// 紧凑模式只显示头像（AppBar 与折叠侧栏用）。
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final mode = ref.watch(themeControllerProvider);

    final avatar = UserAvatar(name: user.username);

    return PopupMenuButton<_UserAction>(
      tooltip: '账号',
      position: PopupMenuPosition.under,
      onSelected: (action) async {
        switch (action) {
          case _UserAction.account:
            context.go('/account');
          case _UserAction.themeSystem:
            await ref
                .read(themeControllerProvider.notifier)
                .set(ThemeMode.system);
          case _UserAction.themeLight:
            await ref
                .read(themeControllerProvider.notifier)
                .set(ThemeMode.light);
          case _UserAction.themeDark:
            await ref
                .read(themeControllerProvider.notifier)
                .set(ThemeMode.dark);
          case _UserAction.logout:
            final confirmed = await showConfirm(
              context,
              title: '退出登录',
              body: '退出后需要重新输入用户名和密码。',
            );
            if (confirmed) {
              await ref.read(sessionControllerProvider.notifier).logout();
            }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: _UserAction.account, child: Text('账号设置')),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(
          value: _UserAction.themeSystem,
          checked: mode == ThemeMode.system,
          child: const Text('跟随系统'),
        ),
        CheckedPopupMenuItem(
          value: _UserAction.themeLight,
          checked: mode == ThemeMode.light,
          child: const Text('浅色'),
        ),
        CheckedPopupMenuItem(
          value: _UserAction.themeDark,
          checked: mode == ThemeMode.dark,
          child: const Text('深色'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: _UserAction.logout, child: Text('退出登录')),
      ],
      child: compact
          ? Padding(
              padding: const EdgeInsets.all(YaoeTokens.space2),
              child: avatar,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(YaoeTokens.radiusField),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: YaoeTokens.space3,
                  vertical: YaoeTokens.space2,
                ),
                child: Row(
                  children: [
                    avatar,
                    const SizedBox(width: YaoeTokens.space2),
                    Expanded(
                      child: Text(
                        user.username,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: YaoeTokens.space2),
                    Pill(
                      text: user.role.label,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
