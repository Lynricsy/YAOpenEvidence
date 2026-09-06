import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/session/session_controller.dart';
import 'app_sidebar.dart';
import 'mobile_tab_bar.dart';
import 'more_sheet.dart';
import 'nav_items.dart';
import 'user_menu.dart';

/// 三档自适应外壳：
/// `< 768` 底部导航 + AppBar；`768–1279` 折叠图标栏；`≥ 1280` 可折叠展开栏。
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int branch) => navigationShell.goBranch(
    branch,
    initialLocation: branch == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < YaoeTokens.compactMaxWidth;
    final isExpanded = width >= YaoeTokens.expandedMinWidth;
    final branch = navigationShell.currentIndex;
    final isAdmin = ref.watch(isAdminProvider);

    if (isCompact) {
      return Scaffold(
        appBar: AppBar(
          title: Text(navItemForBranch(branch)?.label ?? 'YAOpenEvidence'),
          actions: const [UserMenu(compact: true)],
        ),
        body: navigationShell,
        bottomNavigationBar: MobileTabBar(
          currentBranch: branch,
          onSelect: _goBranch,
          onMore: () => showMoreSheet(
            context,
            isAdmin: isAdmin,
            onSelect: _goBranch,
          ),
        ),
      );
    }

    final storedCollapsed = ref.watch(sidebarCollapsedProvider);
    final collapsed = !isExpanded || (storedCollapsed ?? false);

    return Scaffold(
      body: _SidebarShortcut(
        enabled: isExpanded,
        onToggle: () => ref
            .read(sidebarCollapsedProvider.notifier)
            .toggle(storedCollapsed ?? false),
        child: Row(
          children: [
            AppSidebar(
              currentBranch: branch,
              onSelect: _goBranch,
              collapsed: collapsed,
              onToggle: () {
                if (!isExpanded) {
                  // 中等宽度下侧栏固定折叠，点按钮直接跳到账号页更有用。
                  _goBranch(6);
                  return;
                }
                ref
                    .read(sidebarCollapsedProvider.notifier)
                    .toggle(storedCollapsed ?? false);
              },
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}

/// `Ctrl/Cmd+B` 折叠侧栏；焦点在文本框里时不触发。
class _SidebarShortcut extends StatelessWidget {
  const _SidebarShortcut({
    required this.enabled,
    required this.onToggle,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
            _guarded,
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true): _guarded,
      },
      // 需要焦点在子树内才能收到按键：外壳挂载时先接住焦点，
      // 页面里的输入框获得焦点后会自然接管。
      child: Focus(autofocus: true, child: child),
    );
  }

  void _guarded() {
    final focused = FocusManager.instance.primaryFocus?.context;
    // 光标在输入框里时 Ctrl+B 交给文本编辑，不折叠侧栏。
    final editing =
        focused != null &&
        (focused.widget is EditableText ||
            focused.findAncestorWidgetOfExactType<EditableText>() != null);
    if (!editing) onToggle();
  }
}
