import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 内容卡片：圆角 16、无描边、柔和阴影（对齐 iOS `Surface.swift` 的 `card()`）。
///
/// 可点按时 `Material` 位于 `InkWell` 之上，水波不会被卡片底色遮住。
class YaoeCard extends StatelessWidget {
  const YaoeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.onLongPress,
    this.color,
    this.tint,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 底色，默认 `context.yaoe.card`。
  final Color? color;

  /// 语义色提示卡：底色与描边取自该色的低透明度版本，且不带阴影。
  final Color? tint;

  /// false 时不画阴影（用于 `surfaceContainerHigh` 底色的次级卡）。
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final tint = this.tint;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(YaoeTokens.radiusCard),
      side: tint == null
          ? BorderSide.none
          : BorderSide(
              color: tint.withValues(alpha: YaoeTokens.tintBorderAlpha),
            ),
    );
    final content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        shadows: (elevated && tint == null)
            ? context.yaoe.cardShadow
            : const [],
      ),
      child: Material(
        color:
            tint?.withValues(alpha: YaoeTokens.tintFillAlpha) ??
            color ??
            context.yaoe.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: (onTap == null && onLongPress == null)
            ? content
            : InkWell(onTap: onTap, onLongPress: onLongPress, child: content),
      ),
    );
  }
}

/// 毛玻璃浮层：模糊背景 + 半透明卡片色 + 悬浮阴影，用于提问框这类控件层。
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = YaoeTokens.radiusComposer,
    this.padding = EdgeInsets.zero,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alpha = theme.brightness == Brightness.dark
        ? YaoeTokens.glassAlphaDark
        : YaoeTokens.glassAlphaLight;
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        shadows: shadow ? context.yaoe.floatShadow : const [],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: YaoeTokens.glassBlur,
            sigmaY: YaoeTokens.glassBlur,
          ),
          child: ColoredBox(
            color: context.yaoe.card.withValues(alpha: alpha),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// 筛选面板里的一组控件：一张内容卡。
class FilterGroup extends StatelessWidget {
  const FilterGroup({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      YaoeCard(padding: const EdgeInsets.all(14), child: child);
}
