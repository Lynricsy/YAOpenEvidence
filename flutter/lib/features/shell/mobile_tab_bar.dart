import 'package:flutter/material.dart';

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
    return NavigationBar(
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
    );
  }
}
