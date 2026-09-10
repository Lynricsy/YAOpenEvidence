import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import 'scroll_chrome.dart';

/// 悬浮提问框宿主：[body] 铺满，[composer] 贴底浮在其上（左右 12、下 8 +
/// 底部保留区），并把 composer 的实测高度写进 [body] 的
/// `MediaQuery.padding.bottom`，使 `PageBody` / `ListView` 自动留出空间。
///
/// 随 [ScrollChrome] 状态下滑淡出，与手机底部导航栏同步。
class FloatingComposerHost extends StatefulWidget {
  const FloatingComposerHost({
    super.key,
    required this.body,
    required this.composer,
  });

  final Widget body;
  final Widget composer;

  @override
  State<FloatingComposerHost> createState() => _FloatingComposerHostState();
}

class _FloatingComposerHostState extends State<FloatingComposerHost> {
  final _composerKey = GlobalKey();
  double _composerHeight = 0;
  bool _revealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 进入新页面时恢复可见。
    if (!_revealed) {
      _revealed = true;
      ScrollChrome.of(context).reveal();
    }
  }

  void _measure() {
    final height = _composerKey.currentContext?.size?.height;
    if (height == null) return;
    if ((height - _composerHeight).abs() <= 0.5) return;
    setState(() => _composerHeight = height);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });

    final chrome = ScrollChrome.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : YaoeTokens.motionMedium;

    return LayoutBuilder(
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        // 外壳 Scaffold 已从 body 的 MediaQuery 中移除 viewInsets，键盘状态只能
        // 从 FlutterView 读原始 inset。
        final keyboardOpen = View.of(context).viewInsets.bottom > 0;
        // extendBody 下 padding.bottom 即底部导航栏高度；键盘弹出时导航栏被
        // 盖住，不再为它留位。
        final reserved = keyboardOpen ? 0.0 : mq.padding.bottom;

        return Stack(
          children: [
            MediaQuery(
              data: mq.copyWith(
                padding: mq.padding.copyWith(
                  bottom:
                      reserved +
                      _composerHeight +
                      YaoeTokens.composerInsetBottom,
                ),
              ),
              child: widget.body,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ListenableBuilder(
                listenable: chrome,
                builder: (context, _) => IgnorePointer(
                  ignoring: chrome.hidden,
                  child: AnimatedSlide(
                    offset: chrome.hidden ? const Offset(0, 1.2) : Offset.zero,
                    duration: duration,
                    curve: YaoeTokens.motionCurve,
                    child: AnimatedOpacity(
                      opacity: chrome.hidden ? 0 : 1,
                      duration: duration,
                      curve: YaoeTokens.motionCurve,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          YaoeTokens.composerInsetH,
                          0,
                          YaoeTokens.composerInsetH,
                          reserved + YaoeTokens.composerInsetBottom,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: YaoeTokens.contentMaxWidth,
                            ),
                            child: Focus(
                              onFocusChange: (focused) {
                                if (focused) chrome.reveal();
                              },
                              child: KeyedSubtree(
                                key: _composerKey,
                                child: widget.composer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
