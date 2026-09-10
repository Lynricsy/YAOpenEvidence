import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/shared/widgets/floating_composer.dart';
import 'package:yaopenevidence/shared/widgets/scroll_chrome.dart';

Offset _slideOffset(WidgetTester tester) =>
    tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset;

void main() {
  const composerHeight = 60.0;

  Future<double> pumpHost(WidgetTester tester) async {
    final chrome = ScrollChromeController();
    addTearDown(chrome.dispose);
    late double reservedBottom;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrollChrome(
            notifier: chrome,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                chrome.handle(notification);
                return false;
              },
              child: FloatingComposerHost(
                body: Builder(
                  builder: (context) {
                    reservedBottom = MediaQuery.paddingOf(context).bottom;
                    return ListView(
                      children: List.generate(
                        40,
                        (index) => SizedBox(height: 80, child: Text('$index')),
                      ),
                    );
                  },
                ),
                composer: const SizedBox(
                  height: composerHeight,
                  child: Text('composer'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // composer 高度是实测的：第一帧后才写回 body 的 MediaQuery。
    await tester.pumpAndSettle();
    return reservedBottom;
  }

  testWidgets('提问框默认可见，并为内容底部留出自身高度', (tester) async {
    final reservedBottom = await pumpHost(tester);

    expect(find.text('composer'), findsOneWidget);
    expect(_slideOffset(tester), Offset.zero);
    expect(reservedBottom, greaterThanOrEqualTo(composerHeight + 8));
  });

  testWidgets('向下滚动收起，向上滚动与触底恢复', (tester) async {
    await pumpHost(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(_slideOffset(tester), const Offset(0, 1.2), reason: '向下滚动收起');

    await tester.drag(find.byType(ListView), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(_slideOffset(tester), Offset.zero, reason: '向上滚动恢复');
  });

  testWidgets('收起后提问框滑出视口', (tester) async {
    await pumpHost(tester);
    final viewportBottom = tester.getSize(find.byType(MaterialApp)).height;

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('composer')).dy,
      greaterThanOrEqualTo(viewportBottom),
    );
  });
}
