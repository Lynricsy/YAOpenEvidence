import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/logic/ask_rail.dart';
import 'package:picoseek/core/logic/job_live.dart';
import 'package:picoseek/features/answer/stage_rail.dart';

Future<void> pumpRail(
  WidgetTester tester, {
  required bool useKb,
  BackgroundKb? kb,
  bool settled = false,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: StageRail(
        nodes: askRailNodes(
          JobLive.empty,
          useKb: useKb,
          kb: kb,
          settled: settled,
        ),
        progress: kb?.status == KbStatus.running
            ? (
                label: '写入知识库',
                current: kb!.current,
                total: kb.total,
                detail: null,
              )
            : null,
      ),
    ),
  ),
);

void main() {
  testWidgets('答案页：写库节点上屏，带后台进度文案与进度条', (tester) async {
    await pumpRail(
      tester,
      useKb: true,
      kb: const BackgroundKb(status: KbStatus.running, current: 3, total: 10),
      settled: true,
    );

    expect(find.text('综合成稿'), findsOneWidget);
    expect(find.text('写入知识库'), findsOneWidget);
    expect(find.text('写入知识库 3/10'), findsOneWidget);
    expect(find.text('后台写入中（3/10 篇）'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('问答进行中：写库节点提示答案交付后才跑，没有进度条', (tester) async {
    await pumpRail(tester, useKb: true);

    expect(find.text('写入知识库'), findsOneWidget);
    expect(find.text('答案交付后在后台进行'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('写入失败只影响节点，文案说明答案不受影响', (tester) async {
    await pumpRail(
      tester,
      useKb: true,
      kb: const BackgroundKb(status: KbStatus.failed, current: 4, total: 10),
      settled: true,
    );

    expect(find.text('写入失败，答案不受影响'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('关掉知识库时节点条里没有写库', (tester) async {
    await pumpRail(tester, useKb: false, settled: true);

    expect(find.text('写入知识库'), findsNothing);
    expect(find.text('综合成稿'), findsOneWidget);
  });
}
