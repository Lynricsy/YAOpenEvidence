import 'package:flutter/material.dart';

/// 侧栏分组。
enum NavGroup {
  workspace('工作台'),
  explore('探索'),
  admin('管理');

  const NavGroup(this.label);

  final String label;
}

class NavItem {
  const NavItem({
    required this.branch,
    required this.path,
    required this.label,
    required this.icon,
    required this.group,
    this.adminOnly = false,
    this.inTabBar = false,
  });

  /// 对应 `StatefulShellRoute.indexedStack` 的分支下标。
  final int branch;
  final String path;
  final String label;
  final IconData icon;
  final NavGroup group;
  final bool adminOnly;

  /// 窄屏底部导航只放 4 项，其余进「更多」。
  final bool inTabBar;
}

const navItems = <NavItem>[
  NavItem(
    branch: 0,
    path: '/',
    label: '提问',
    icon: Icons.chat_bubble_outline,
    group: NavGroup.workspace,
    inTabBar: true,
  ),
  NavItem(
    branch: 1,
    path: '/history',
    label: '历史',
    icon: Icons.history,
    group: NavGroup.workspace,
    inTabBar: true,
  ),
  NavItem(
    branch: 2,
    path: '/library',
    label: '文献库',
    icon: Icons.local_library_outlined,
    group: NavGroup.explore,
    inTabBar: true,
  ),
  NavItem(
    branch: 3,
    path: '/kb',
    label: '知识库',
    icon: Icons.storage_outlined,
    group: NavGroup.explore,
    inTabBar: true,
  ),
  NavItem(
    branch: 4,
    path: '/search',
    label: '查文献',
    icon: Icons.search,
    group: NavGroup.explore,
  ),
  NavItem(
    branch: 5,
    path: '/admin/users',
    label: '用户',
    icon: Icons.group_outlined,
    group: NavGroup.admin,
    adminOnly: true,
  ),
  NavItem(
    branch: 6,
    path: '/account',
    label: '账号',
    icon: Icons.person_outline,
    group: NavGroup.admin,
  ),
];

/// 底部导航项（4 项）。
final tabBarItems = navItems.where((item) => item.inTabBar).toList();

/// 「更多」表单里的项（查文献 / 用户 / 账号）。
final moreItems = navItems.where((item) => !item.inTabBar).toList();

NavItem? navItemForBranch(int branch) {
  for (final item in navItems) {
    if (item.branch == branch) return item;
  }
  return null;
}
