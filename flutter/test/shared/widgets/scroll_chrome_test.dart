import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/shared/widgets/scroll_chrome.dart';

FixedScrollMetrics _metrics({
  required double pixels,
  double maxScrollExtent = 1000,
}) => FixedScrollMetrics(
  pixels: pixels,
  minScrollExtent: 0,
  maxScrollExtent: maxScrollExtent,
  viewportDimension: 600,
  axisDirection: AxisDirection.down,
  devicePixelRatio: 1,
);

/// `UserScrollNotification` 的构造不收 depth，需要 BuildContext；用一个挂载好的
/// Builder 拿到真实 context 再手工投递通知。
Future<BuildContext> _context(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    Builder(
      builder: (context) {
        captured = context;
        return const SizedBox();
      },
    ),
  );
  return captured;
}

void main() {
  testWidgets('向下滚隐藏，向上滚恢复', (tester) async {
    final context = await _context(tester);
    final chrome = ScrollChromeController();
    expect(chrome.hidden, isFalse);

    chrome.handle(
      UserScrollNotification(
        metrics: _metrics(pixels: 200),
        context: context,
        direction: ScrollDirection.reverse,
      ),
    );
    expect(chrome.hidden, isTrue);

    chrome.handle(
      UserScrollNotification(
        metrics: _metrics(pixels: 200),
        context: context,
        direction: ScrollDirection.forward,
      ),
    );
    expect(chrome.hidden, isFalse);
  });

  testWidgets('从顶部第一次下滑也收起', (tester) async {
    final context = await _context(tester);
    final chrome = ScrollChromeController();

    chrome.handle(
      UserScrollNotification(
        metrics: _metrics(pixels: 0),
        context: context,
        direction: ScrollDirection.reverse,
      ),
    );
    expect(chrome.hidden, isTrue);
  });

  testWidgets('可滚动距离不足时不隐藏', (tester) async {
    final context = await _context(tester);
    final chrome = ScrollChromeController();

    chrome.handle(
      UserScrollNotification(
        metrics: _metrics(pixels: 20, maxScrollExtent: 40),
        context: context,
        direction: ScrollDirection.reverse,
      ),
    );
    expect(chrome.hidden, isFalse);
  });

  testWidgets('触顶与触底都恢复可见', (tester) async {
    final context = await _context(tester);
    final chrome = ScrollChromeController();
    void hide() => chrome.handle(
      UserScrollNotification(
        metrics: _metrics(pixels: 200),
        context: context,
        direction: ScrollDirection.reverse,
      ),
    );

    hide();
    chrome.handle(
      ScrollUpdateNotification(
        metrics: _metrics(pixels: 1000),
        context: context,
      ),
    );
    expect(chrome.hidden, isFalse, reason: '触底恢复');

    hide();
    chrome.handle(
      ScrollUpdateNotification(metrics: _metrics(pixels: 0), context: context),
    );
    expect(chrome.hidden, isFalse, reason: '触顶恢复');
  });

  testWidgets('内层滚动（depth > 0）不改变状态', (tester) async {
    final context = await _context(tester);
    final chrome = ScrollChromeController();

    chrome.handle(
      UserScrollNotification(
        metrics: _metrics(pixels: 200),
        context: context,
        direction: ScrollDirection.reverse,
      ),
    );
    // 内层列表触顶不该把外层的 chrome 拉回来。
    chrome.handle(
      ScrollUpdateNotification(
        metrics: _metrics(pixels: 0),
        context: context,
        depth: 1,
      ),
    );
    expect(chrome.hidden, isTrue);
  });

  testWidgets('reveal 主动恢复，且只在值变化时通知', (tester) async {
    final context = await _context(tester);
    final chrome = ScrollChromeController();
    var notifications = 0;
    chrome.addListener(() => notifications++);

    for (var i = 0; i < 2; i++) {
      chrome.handle(
        UserScrollNotification(
          metrics: _metrics(pixels: 200),
          context: context,
          direction: ScrollDirection.reverse,
        ),
      );
    }
    expect(notifications, 1, reason: '重复隐藏不重复通知');

    chrome.reveal();
    expect(chrome.hidden, isFalse);
    expect(notifications, 2);

    chrome.reveal();
    expect(notifications, 2);
  });
}
