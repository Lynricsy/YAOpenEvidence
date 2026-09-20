import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/models/page.dart' as models;
import 'package:picoseek/core/models/papers.dart';
import 'package:picoseek/features/library/library_controller.dart';
import 'package:picoseek/features/library/library_page.dart';
import 'package:picoseek/shared/widgets/pagination.dart';

/// 换页器曾经是文献库的固定底栏，永久占掉一条屏幕高度。它只有翻到列表尽头才有用，
/// 所以现在跟着列表滚动——这组用例锁住「首屏不出现、翻到尽头才出现」。
class _FakeLibrary extends LibraryController {
  _FakeLibrary(this.page);

  final models.Page<PaperMeta> page;

  @override
  Future<models.Page<PaperMeta>> build() async => page;
}

models.Page<PaperMeta> _page({
  required int count,
  required int total,
  int offset = 0,
}) => models.Page(
  items: List.generate(
    count,
    (index) => PaperMeta(
      key: 'k$index',
      title: '文献标题 $index',
      journal: '期刊 $index',
      year: '2026',
    ),
  ),
  total: total,
  limit: LibraryController.limit,
  offset: offset,
);

Future<void> _pump(WidgetTester tester, models.Page<PaperMeta> page) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryControllerProvider.overrideWith(() => _FakeLibrary(page)),
      ],
      child: const MaterialApp(home: Scaffold(body: LibraryPage())),
    ),
  );
  await tester.pumpAndSettle();
}

/// 搜索框的 EditableText 自带一个 Scrollable，必须显式指定列表的那个。
final _listScrollable = find.descendant(
  of: find.byType(ListView),
  matching: find.byType(Scrollable),
);

void main() {
  testWidgets('多页时首屏不出现换页器，滚到列表尽头才出现', (tester) async {
    await _pump(tester, _page(count: LibraryController.limit, total: 64));

    expect(find.byType(Pager), findsNothing, reason: '钉成固定底栏时这里会命中一个');

    await tester.scrollUntilVisible(
      find.byType(Pager),
      300,
      scrollable: _listScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.byType(Pager), findsOneWidget);
    expect(find.textContaining('第 1–20 条'), findsOneWidget);
  });

  testWidgets('只有一页时列表尽头也没有换页器', (tester) async {
    await _pump(tester, _page(count: 3, total: 3));

    expect(find.byType(Pager), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.byType(Pager), findsNothing);
  });

  testWidgets('翻到第二页后换页器仍在尽头可达', (tester) async {
    await _pump(
      tester,
      _page(count: 4, total: 64, offset: LibraryController.limit * 3),
    );

    await tester.scrollUntilVisible(
      find.byType(Pager),
      300,
      scrollable: _listScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('第 61–64 条'), findsOneWidget);
  });
}
