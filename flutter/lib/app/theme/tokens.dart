import 'package:flutter/material.dart';

/// 设计令牌：颜色取自 Web 端 OKLCH 令牌换算后的 sRGB 值，主色对齐 Apple 端 AccentColor。
abstract final class YaoeTokens {
  // 浅色
  static const primaryLight = Color(0xFF1F7583);
  static const onPrimaryLight = Color(0xFFFDFCF8);
  static const surfaceLight = Color(0xFFFCFAF6);
  static const cardLight = Color(0xFFFFFEFD);
  static const sidebarLight = Color(0xFFF6F3EE);
  static const mutedLight = Color(0xFFF3F0EA);
  static const foregroundLight = Color(0xFF261D16);
  static const borderLight = Color(0xFFE1DDD7);
  static const errorLight = Color(0xFFC53637);
  static const infoLight = Color(0xFF006D95);
  static const successLight = Color(0xFF0B7643);
  static const warningLight = Color(0xFF945A00);
  static const q1Light = Color(0xFF0B7643);
  static const q2Light = Color(0xFF006D95);
  static const q3Light = Color(0xFF945A00);
  static const q4Light = Color(0xFF72665E);

  // 深色
  static const primaryDark = Color(0xFF6FC2CF);
  static const onPrimaryDark = Color(0xFF0A191A);
  static const surfaceDark = Color(0xFF17130F);
  static const cardDark = Color(0xFF1E1A16);
  static const sidebarDark = Color(0xFF110E0B);
  static const mutedDark = Color(0xFF25211D);
  static const foregroundDark = Color(0xFFE8E4DD);
  static const borderDark = Color(0xFF342F2B);
  static const errorDark = Color(0xFFF2716A);
  static const infoDark = Color(0xFF61B7DE);
  static const successDark = Color(0xFF66C189);
  static const warningDark = Color(0xFFEFB062);
  static const q1Dark = Color(0xFF50C08B);
  static const q2Dark = Color(0xFF57B8E3);
  static const q3Dark = Color(0xFFECA851);
  static const q4Dark = Color(0xFF9DA5B1);

  // 圆角
  static const radiusSm = 4.0;
  static const radiusMd = 6.0;
  static const radiusLg = 8.0;
  static const radiusXl = 12.0;

  // 间距
  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 24.0;
  static const space6 = 32.0;

  // 布局断点
  static const compactMaxWidth = 768.0;
  static const expandedMinWidth = 1280.0;

  /// 侧栏宽度：折叠仅图标 / 展开带文字。
  static const sidebarCollapsedWidth = 64.0;
  static const sidebarExpandedWidth = 240.0;

  /// 统一动效曲线与时长。
  static const motionCurve = Curves.easeOutQuint;
  static const motionFast = Duration(milliseconds: 180);
  static const motionMedium = Duration(milliseconds: 300);
}

/// 主题扩展色：Material 3 配色方案里没有的语义色与分区色。
@immutable
class YaoeColors extends ThemeExtension<YaoeColors> {
  const YaoeColors({
    required this.info,
    required this.success,
    required this.warning,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.highlight,
    required this.card,
    required this.sidebar,
  });

  final Color info;
  final Color success;
  final Color warning;
  final Color q1;
  final Color q2;
  final Color q3;
  final Color q4;

  /// 引文命中底色（黄 35%）。
  final Color highlight;
  final Color card;
  final Color sidebar;

  static const light = YaoeColors(
    info: YaoeTokens.infoLight,
    success: YaoeTokens.successLight,
    warning: YaoeTokens.warningLight,
    q1: YaoeTokens.q1Light,
    q2: YaoeTokens.q2Light,
    q3: YaoeTokens.q3Light,
    q4: YaoeTokens.q4Light,
    highlight: Color(0x59FFD54F),
    card: YaoeTokens.cardLight,
    sidebar: YaoeTokens.sidebarLight,
  );

  static const dark = YaoeColors(
    info: YaoeTokens.infoDark,
    success: YaoeTokens.successDark,
    warning: YaoeTokens.warningDark,
    q1: YaoeTokens.q1Dark,
    q2: YaoeTokens.q2Dark,
    q3: YaoeTokens.q3Dark,
    q4: YaoeTokens.q4Dark,
    highlight: Color(0x59B58900),
    card: YaoeTokens.cardDark,
    sidebar: YaoeTokens.sidebarDark,
  );

  /// 期刊分区色（未收录返回 null，由调用方用灰色）。
  Color? quartile(String quartile) => switch (quartile.toUpperCase()) {
    'Q1' => q1,
    'Q2' => q2,
    'Q3' => q3,
    'Q4' => q4,
    _ => null,
  };

  @override
  YaoeColors copyWith({
    Color? info,
    Color? success,
    Color? warning,
    Color? q1,
    Color? q2,
    Color? q3,
    Color? q4,
    Color? highlight,
    Color? card,
    Color? sidebar,
  }) => YaoeColors(
    info: info ?? this.info,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    q1: q1 ?? this.q1,
    q2: q2 ?? this.q2,
    q3: q3 ?? this.q3,
    q4: q4 ?? this.q4,
    highlight: highlight ?? this.highlight,
    card: card ?? this.card,
    sidebar: sidebar ?? this.sidebar,
  );

  @override
  YaoeColors lerp(YaoeColors? other, double t) {
    if (other == null) return this;
    return YaoeColors(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      q1: Color.lerp(q1, other.q1, t)!,
      q2: Color.lerp(q2, other.q2, t)!,
      q3: Color.lerp(q3, other.q3, t)!,
      q4: Color.lerp(q4, other.q4, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      card: Color.lerp(card, other.card, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
    );
  }
}

/// 便捷取扩展色。
extension YaoeColorsOf on BuildContext {
  YaoeColors get yaoe =>
      Theme.of(this).extension<YaoeColors>() ?? YaoeColors.light;
}
