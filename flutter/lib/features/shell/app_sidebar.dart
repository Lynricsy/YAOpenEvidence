import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/answers_version.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/api/endpoints.dart';
import '../../core/models/answers.dart';
import '../../core/session/prefs.dart';
import '../../core/session/session_controller.dart';
import '../../shared/widgets/brand_logo.dart';
import 'nav_items.dart';
import 'user_menu.dart';

part 'app_sidebar.g.dart';

/// 侧栏折叠状态。null = 尚未选择，由窗口宽度决定。
@Riverpod(keepAlive: true)
class SidebarCollapsed extends _$SidebarCollapsed {
  @override
  bool? build() =>
      switch (ref.watch(prefsProvider).getString(PrefKeys.sidebar)) {
        'collapsed' => true,
        'expanded' => false,
        _ => null,
      };

  Future<void> set(bool collapsed) async {
    state = collapsed;
    await ref
        .read(prefsProvider)
        .setString(PrefKeys.sidebar, collapsed ? 'collapsed' : 'expanded');
  }

  Future<void> toggle(bool current) => set(!current);
}

/// 侧栏「最近问答」5 条。`answersVersion` 变化时重取。
@riverpod
Future<List<AnswerSummary>> recentAnswers(Ref ref) async {
  ref.watch(answersVersionProvider);
  final page = await ref.watch(apiClientProvider).answers(limit: 5);
  return page.items;
}

/// 桌面/平板侧栏。
class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.currentBranch,
    required this.onSelect,
    required this.collapsed,
    required this.onToggle,
  });

  final int currentBranch;
  final void Function(int branch) onSelect;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    final items = navItems
        .where((item) => !item.adminOnly || isAdmin)
        .where((item) => item.branch != 6)
        .toList();

    final width = collapsed
        ? YaoeTokens.sidebarCollapsedWidth
        : YaoeTokens.sidebarExpandedWidth;

    return AnimatedContainer(
      duration: YaoeTokens.motionFast,
      curve: YaoeTokens.motionCurve,
      width: width,
      decoration: BoxDecoration(
        color: context.yaoe.sidebar,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      // 折叠动画只过渡容器宽度，内容始终按折叠/展开的目标宽度布局再裁剪：
      // 否则中间帧里图标 + 文字要挤进几十像素，会触发 RenderFlex 溢出。
      child: ConstraintsTransformBox(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.hardEdge,
        // tighten 会被既有上下界夹住，这里必须直接替换宽度约束。
        constraintsTransform: (constraints) =>
            constraints.copyWith(minWidth: width, maxWidth: width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(collapsed: collapsed, onToggle: onToggle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: YaoeTokens.space2,
                ),
                children: [
                  for (final group in NavGroup.values)
                    ..._groupSection(context, ref, group, items),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(YaoeTokens.space2),
              child: UserMenu(compact: collapsed),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _groupSection(
    BuildContext context,
    WidgetRef ref,
    NavGroup group,
    List<NavItem> items,
  ) {
    final theme = Theme.of(context);
    final groupItems = items.where((item) => item.group == group).toList();
    if (groupItems.isEmpty) return const [];
    return [
      if (!collapsed)
        Padding(
          padding: const EdgeInsets.only(
            left: YaoeTokens.space4,
            top: YaoeTokens.space3,
            bottom: YaoeTokens.space1,
          ),
          child: Text(
            group.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      for (final item in groupItems)
        _SidebarTile(
          icon: item.icon,
          label: item.label,
          selected: currentBranch == item.branch,
          collapsed: collapsed,
          onTap: () => onSelect(item.branch),
        ),
      if (group == NavGroup.workspace && !collapsed) _RecentAnswers(),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.collapsed, required this.onToggle});

  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toggle = IconButton(
      tooltip: collapsed ? '展开侧栏 (Ctrl+B)' : '折叠侧栏 (Ctrl+B)',
      onPressed: onToggle,
      icon: Icon(
        collapsed ? Icons.chevron_right : Icons.chevron_left,
        size: 18,
      ),
    );

    if (collapsed) {
      // 折叠宽度只有 64：品牌标识与折叠按钮竖排，横排必然溢出。
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          YaoeTokens.space2,
          YaoeTokens.space4,
          YaoeTokens.space2,
          YaoeTokens.space2,
        ),
        child: Column(
          children: [
            const BrandLogo(size: 24, semanticLabel: 'YAOpenEvidence'),
            const SizedBox(height: YaoeTokens.space2),
            toggle,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        YaoeTokens.space3,
        YaoeTokens.space4,
        YaoeTokens.space2,
        YaoeTokens.space2,
      ),
      child: Row(
        children: [
          Expanded(
            child: BrandLockup(
              logoSize: 24,
              mainAxisAlignment: MainAxisAlignment.start,
              textStyle: theme.textTheme.titleSmall,
            ),
          ),
          toggle,
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;
    final tile = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 0 : YaoeTokens.space3,
          vertical: YaoeTokens.space2 + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : null,
          borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            if (!collapsed) ...[
              const SizedBox(width: YaoeTokens.space3),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? YaoeTokens.space2 : YaoeTokens.space2,
        vertical: 1,
      ),
      child: collapsed ? Tooltip(message: label, child: tile) : tile,
    );
  }
}

/// 「最近问答」5 条，带状态圆点。
class _RecentAnswers extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentAnswersProvider);
    final items = recent.value ?? const <AnswerSummary>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: YaoeTokens.space4,
            top: YaoeTokens.space3,
            bottom: YaoeTokens.space1,
          ),
          child: Text(
            '最近问答',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final answer in items)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: YaoeTokens.space2,
              vertical: 1,
            ),
            child: InkWell(
              onTap: () => context.go('/a/${answer.id}'),
              borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: YaoeTokens.space3,
                  vertical: YaoeTokens.space2,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: answerStatusColor(context, answer.status),
                      ),
                    ),
                    const SizedBox(width: YaoeTokens.space2),
                    Expanded(
                      child: Text(
                        answer.question,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
