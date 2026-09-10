import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/session/session_controller.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/scroll_chrome.dart';
import 'app_sidebar.dart';
import 'mobile_tab_bar.dart';
import 'more_sheet.dart';
import 'nav_items.dart';
import 'user_menu.dart';

/// 三档自适应外壳：
/// `< 768` 底部导航 + AppBar；`768–1279` 折叠图标栏；`≥ 1280` 可折叠展开栏。
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// 提问框与手机底部导航栏共用的收起状态。
  final _chrome = ScrollChromeController();

  @override
  void dispose() {
    _chrome.dispose();
    super.dispose();
  }

  void _goBranch(int branch) {
    _chrome.reveal();
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  /// 页面滚动时驱动 chrome 收起/恢复；通知继续向上冒泡。
  bool _onScroll(ScrollNotification notification) {
    _chrome.handle(notification);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < YaoeTokens.compactMaxWidth;
    final isExpanded = width >= YaoeTokens.expandedMinWidth;
    final branch = widget.navigationShell.currentIndex;
    final isAdmin = ref.watch(isAdminProvider);

    if (isCompact) {
      // 分支内的详情路由（问答 / 文献详情）在顶栏出返回键，其余显示品牌标识。
      final path = GoRouterState.of(context).uri.path;
      final isAnswer = path.startsWith('/a/');
      final isPaper = path.startsWith('/library/');
      final title = isAnswer
          ? '问答'
          : isPaper
          ? '文献详情'
          : navItemForBranch(branch)?.label ?? 'YAOpenEvidence';

      return Scaffold(
        // 内容延伸到导航栏底下，玻璃才有东西可透。
        extendBody: true,
        appBar: AppBar(
          leadingWidth: 44,
          leading: (isAnswer || isPaper)
              ? BackButton(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      context.go(isAnswer ? '/' : '/library');
                    }
                  },
                )
              : const Padding(
                  padding: EdgeInsets.only(left: YaoeTokens.space3),
                  child: Center(
                    child: BrandLogo(size: 22, semanticLabel: 'YAOpenEvidence'),
                  ),
                ),
          title: Text(title),
          actions: const [UserMenu(compact: true)],
        ),
        body: ScrollChrome(
          notifier: _chrome,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.navigationShell,
          ),
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: _chrome,
          builder: (context, _) {
            final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
            final hidden = _chrome.hidden || keyboard;
            final reduce = MediaQuery.disableAnimationsOf(context);
            return AnimatedSlide(
              offset: hidden ? const Offset(0, 1) : Offset.zero,
              duration: reduce ? Duration.zero : YaoeTokens.motionMedium,
              curve: YaoeTokens.motionCurve,
              child: MobileTabBar(
                currentBranch: branch,
                onSelect: _goBranch,
                onMore: () => showMoreSheet(
                  context,
                  isAdmin: isAdmin,
                  onSelect: _goBranch,
                ),
              ),
            );
          },
        ),
      );
    }

    final storedCollapsed = ref.watch(sidebarCollapsedProvider);
    final collapsed = !isExpanded || (storedCollapsed ?? false);

    return Scaffold(
      body: ScrollChrome(
        notifier: _chrome,
        child: _SidebarShortcut(
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
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: widget.navigationShell,
                ),
              ),
            ],
          ),
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
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): _guarded,
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
