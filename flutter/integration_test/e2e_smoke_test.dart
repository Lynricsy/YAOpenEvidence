import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yaopenevidence/app/app.dart';
import 'package:yaopenevidence/core/logic/ask_filters.dart';
import 'package:yaopenevidence/core/session/prefs.dart';
import 'package:yaopenevidence/features/answer/answer_page.dart';
import 'package:yaopenevidence/features/answer/citation_chip.dart';
import 'package:yaopenevidence/features/ask/ask_page.dart';
import 'package:yaopenevidence/features/ask/ask_state.dart';
import 'package:yaopenevidence/features/reader/reader_pane.dart';

/// 通过 `--dart-define` 提供后端与账号后才执行，否则整体跳过。
const api = String.fromEnvironment('YAOE_E2E_API');
const user = String.fromEnvironment('YAOE_E2E_USER');
const password = String.fromEnvironment('YAOE_E2E_PASSWORD');

const question = 'SGLT2抑制剂对HFpEF患者有什么获益？';

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(minutes: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('等待超时：$finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('登录 → 提问 → 引用芯片 → 阅读器定位', (tester) async {
    final prefs = await Prefs.open();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // 登录页：服务器地址 / 用户名 / 密码。
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), api);
    await tester.enterText(fields.at(1), user);
    await tester.enterText(fields.at(2), password);
    await tester.tap(find.text('登录'));
    await pumpUntil(tester, find.byType(AskPage));

    // 只读 1 篇、关闭知识库，把冒烟时间压到最短。
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AskPage)),
    );
    await container
        .read(askFiltersControllerProvider.notifier)
        .set(
          const AskFilters(
            papers: 1,
            useKb: false,
            yearMode: YearMode.recent,
            years: 5,
          ),
        );
    container.read(askDraftProvider.notifier).set(question);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward).first);
    await pumpUntil(tester, find.byType(AnswerPage));

    // 终态后正文出现引用芯片。
    await pumpUntil(tester, find.byType(CitationChip));
    await tester.tap(find.byType(CitationChip).first);
    await pumpUntil(tester, find.byType(ReaderPane));
    expect(find.byType(ReaderPane), findsOneWidget);
  }, skip: api.isEmpty || user.isEmpty || password.isEmpty);
}
