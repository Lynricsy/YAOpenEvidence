import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// 品牌标识（圆角书页 + 核验勾）。
///
/// 资源为位图（`tools/generate_brand_assets.py` 由 `docs/assets/logo.svg` 生成），
/// 按 `Theme.of(context).brightness` 选择浅/深两套，随主题切换即时生效；
/// 1x/2x/3x 变体由 Flutter 的资源解析按屏幕密度挑选，不引入 SVG 运行库。
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 28, this.semanticLabel});

  /// 固定边长（图形本身为正方形），避免布局按图片固有尺寸抖动或溢出。
  final double size;

  /// 无伴随品牌文字时才传：读屏会朗读它；与文字同现时留空，避免重复朗读。
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      dark ? 'assets/brand/logo-dark.png' : 'assets/brand/logo-light.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}

/// 品牌组合标记：标识 + 「PicoSeek」文字。语义由文字承载。
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.logoSize = 28,
    this.textStyle,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final double logoSize;

  /// 缺省用 `titleSmall`；不同位置（登录页大标题、侧栏小标题）各自传入。
  final TextStyle? textStyle;

  /// 行内对齐：登录页与启动页居中，侧栏靠左。
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        BrandLogo(size: logoSize),
        const SizedBox(width: PicoSeekTokens.space2),
        // 宽度不足时省略号收尾：折叠动画与窄侧栏都不能溢出。
        Flexible(
          child: Text(
            'PicoSeek',
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: textStyle ?? theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
