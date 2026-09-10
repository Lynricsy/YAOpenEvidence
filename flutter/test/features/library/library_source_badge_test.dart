import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/models/answers.dart';
import 'package:yaopenevidence/core/models/page.dart' as models;
import 'package:yaopenevidence/core/models/papers.dart';
import 'package:yaopenevidence/features/library/library_controller.dart';
import 'package:yaopenevidence/features/library/library_page.dart';

/// 库里有一半条目只入了摘要（`source: abstract`），列表上却没有任何线索，
/// 点进去的「全文」标签页其实只有摘要。这组用例锁住「每行都标出取全文还是仅摘要」，
/// 并覆盖 upload —— 它曾因客户端枚举缺分支被兜底成「仅摘要」，把上传的全文标反。
class _FakeLibrary extends LibraryController {
  _FakeLibrary(this.page);

  final models.Page<PaperMeta> page;

  @override
  Future<models.Page<PaperMeta>> build() async => page;
}

Future<void> _pump(WidgetTester tester, List<PaperSource> sources) async {
  final page = models.Page(
    items: [
      for (final (index, source) in sources.indexed)
        PaperMeta(key: 'k$index', title: '文献标题 $index', source: source),
    ],
    total: sources.length,
    limit: LibraryController.limit,
    offset: 0,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryControllerProvider.overrideWith(() => _FakeLibrary(page)),
      ],
      child: MaterialApp(home: Scaffold(body: LibraryPage())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('每行按 source 标出取全文还是仅摘要', (tester) async {
    await _pump(tester, [
      PaperSource.abstract,
      PaperSource.pmc,
      PaperSource.inst,
      PaperSource.upload,
    ]);

    expect(find.text('仅摘要'), findsOneWidget);
    expect(find.text('全文 · PMC'), findsOneWidget);
    expect(find.text('全文 · 机构'), findsOneWidget);
    expect(find.text('全文 · 上传'), findsOneWidget);
  });

  testWidgets('后端新增来源时退回「仅摘要」而不是显示空徽标', (tester) async {
    final meta = PaperMeta.fromJson({
      'key': 'k',
      'title': 'T',
      'source': 'brand-new-source',
    });
    expect(meta.source, PaperSource.abstract);

    await _pump(tester, [meta.source]);
    expect(find.text('仅摘要'), findsOneWidget);
  });
}
