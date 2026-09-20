import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:picoseek/app/app.dart';
import 'package:picoseek/core/logic/ask_filters.dart';
import 'package:picoseek/core/session/prefs.dart';
import 'package:picoseek/features/answer/answer_page.dart';
import 'package:picoseek/features/answer/citation_chip.dart';
import 'package:picoseek/features/ask/ask_page.dart';
import 'package:picoseek/features/ask/ask_state.dart';
import 'package:picoseek/features/reader/reader_pane.dart';

/// 通过 `--dart-define` 提供后端与账号后才执行，否则整体跳过。
const api = String.fromEnvironment('PICOSEEK_E2E_API');
const user = String.fromEnvironment('PICOSEEK_E2E_USER');
const password = String.fromEnvironment('PICOSEEK_E2E_PASSWORD');

const question = 'SGLT2抑制剂对HFpEF患者有什么获益？';

const minute = Duration(minutes: 1);

Future<void> pumpUntilTrue(
  WidgetTester tester,
  bool Function() ready, {
  Duration timeout = const Duration(minutes: 10),
  String what = '条件',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (ready()) return;
  }
  fail('等待超时：$what');
}

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(minutes: 10),
}) => pumpUntilTrue(
  tester,
  () => finder.evaluate().isNotEmpty,
  timeout: timeout,
  what: '$finder',
);

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
    // 会话引导是真实 I/O,pumpAndSettle 不等它;等到登录表单或已登录的提问页。
    final loginForm = find.byType(TextFormField);
    final askPage = find.byType(AskPage);
    await pumpUntilTrue(
      tester,
      () => loginForm.evaluate().isNotEmpty || askPage.evaluate().isNotEmpty,
      timeout: minute,
      what: '登录页或提问页',
    );

    // 本机可能残留上次冒烟的会话;只有真在登录页时才走登录流程。
    if (loginForm.evaluate().isNotEmpty) {
      await tester.enterText(loginForm.at(0), api);
      await tester.enterText(loginForm.at(1), user);
      await tester.enterText(loginForm.at(2), password);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('登录'));
      await pumpUntil(tester, askPage, timeout: minute);
    }

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
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.arrow_upward).first);
    await pumpUntil(tester, find.byType(AnswerPage));

    // 终态后正文出现引用芯片。
    await pumpUntil(tester, find.byType(CitationChip));
    await tester.tap(find.byType(CitationChip).first);
    await pumpUntil(tester, find.byType(ReaderPane));
    expect(find.byType(ReaderPane), findsOneWidget);
  }, skip: api.isEmpty || user.isEmpty || password.isEmpty);
}
