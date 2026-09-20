import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../shared/format.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/pagination.dart';
import '../../shared/widgets/surface.dart';
import 'library_controller.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(libraryControllerProvider);
    final controller = ref.read(libraryControllerProvider.notifier);
    final theme = Theme.of(context);
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: '文献库', description: '本地已阅读并入库的文献'),
          TextFormField(
            initialValue: controller.query,
            onChanged: controller.setQuery,
            decoration: const InputDecoration(
              hintText: '搜索标题或期刊',
              prefixIcon: Icon(Icons.search_outlined),
            ),
          ),
          const SizedBox(height: PicoSeekTokens.space4),
          Expanded(
            child: AsyncValueView(
              value: page,
              onRetry: controller.reload,
              builder: (data) {
                if (data.items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_library_outlined,
                    title: '文献库还是空的',
                    description: '完成一次问答后，读过的文献会出现在这里',
                  );
                }
                // 换页器跟在列表末尾一起滚动，不做固定底栏：它只有翻到尽头时才
                // 有用，钉住会永久占掉一条屏幕高度（历史与用户列表也都是滚走的）。
                final showPager = Pager.isUseful(
                  total: data.total,
                  limit: data.limit,
                  offset: data.offset,
                );
                return ListView.separated(
                  itemCount: data.items.length + (showPager ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: PicoSeekTokens.space3),
                  itemBuilder: (context, index) {
                    if (index == data.items.length) {
                      return Pager(
                        total: data.total,
                        limit: data.limit,
                        offset: data.offset,
                        onChange: controller.setOffset,
                      );
                    }
                    final meta = data.items[index];
                    return PicoSeekCard(
                      onTap: () => context.go(
                        '/library/${Uri.encodeComponent(meta.key)}',
                      ),
                      padding: const EdgeInsets.all(PicoSeekTokens.space4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meta.title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: PicoSeekTokens.space2),
                          Wrap(
                            spacing: PicoSeekTokens.space2,
                            runSpacing: PicoSeekTokens.space2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                [
                                  meta.journal,
                                  meta.year,
                                ].where((s) => s.isNotEmpty).join(' · '),
                              ),
                              RankBadge(quartile: meta.quartile),
                              SourceBadge(source: meta.source),
                              for (final type in meta.types.take(3))
                                Pill(
                                  text: type,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              if (meta.types.length > 3)
                                Pill(
                                  text: '+${meta.types.length - 3}',
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                            ],
                          ),
                          const SizedBox(height: PicoSeekTokens.space2),
                          if (meta.indexedAt != null)
                            Text(
                              '入库于 ${relativeTime(meta.indexedAt!)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
