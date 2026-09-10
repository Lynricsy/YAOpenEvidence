import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

/// 「随滚动收起的底部 chrome」状态：向下滚（内容上移）隐藏，向上滚 / 触顶 /
/// 触底 / 主动 [reveal] 恢复。提问框与手机底部导航栏共用同一实例。
class ScrollChromeController extends ChangeNotifier {
  bool _hidden = false;

  bool get hidden => _hidden;

  /// 内容可滚动距离不足此值时永不隐藏（短页面收起 chrome 不划算）。
  static const minScrollExtent = 96.0;

  void handle(ScrollNotification notification) {
    if (notification.depth != 0) return;
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return;

    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          if (metrics.maxScrollExtent > minScrollExtent && metrics.pixels > 0) {
            _set(true);
          }
        case ScrollDirection.forward:
          _set(false);
        case ScrollDirection.idle:
          break;
      }
      return;
    }

    if (notification is ScrollUpdateNotification) {
      if (metrics.pixels <= 0 ||
          metrics.pixels >= metrics.maxScrollExtent - 1) {
        _set(false);
      }
    }
  }

  /// 主动恢复可见（切页、输入框获得焦点时调用）。
  void reveal() => _set(false);

  void _set(bool value) {
    if (_hidden == value) return;
    _hidden = value;
    notifyListeners();
  }
}

/// 由 `AppShell` 提供，页面通过 [ScrollChrome.of] 取控制器。
class ScrollChrome extends InheritedNotifier<ScrollChromeController> {
  const ScrollChrome({
    super.key,
    required ScrollChromeController super.notifier,
    required super.child,
  });

  static ScrollChromeController of(BuildContext context) {
    final chrome = context
        .dependOnInheritedWidgetOfExactType<ScrollChrome>()
        ?.notifier;
    assert(chrome != null, '缺少 ScrollChrome 祖先');
    return chrome!;
  }
}
