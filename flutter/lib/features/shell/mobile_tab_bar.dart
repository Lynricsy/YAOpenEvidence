import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import 'nav_items.dart';

/// 窄屏底部导航：4 个主项 + 「更多」。
class MobileTabBar extends StatelessWidget {
  const MobileTabBar({
    super.key,
    required this.currentBranch,
    required this.onSelect,
    required this.onMore,
  });

  final int currentBranch;
  final void Function(int branch) onSelect;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final tabs = tabBarItems;
    final index = tabs.indexWhere((item) => item.branch == currentBranch);
    final scheme = Theme.of(context).colorScheme;
    // 材质自己画：半透明侧栏底色 + 模糊 + 顶部 hairline，内容从底下透出来。
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.picoseek.sidebar.withValues(alpha: 0.86),
            border: Border(
              top: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: index >= 0 ? index : tabs.length,
            onDestinationSelected: (selected) {
              if (selected >= tabs.length) {
                onMore();
              } else {
                onSelect(tabs[selected].branch);
              }
            },
            destinations: [
              for (final item in tabs)
                NavigationDestination(icon: Icon(item.icon), label: item.label),
              const NavigationDestination(
                icon: Icon(Icons.more_horiz),
                label: '更多',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
