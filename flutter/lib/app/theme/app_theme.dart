
import 'package:flutter/material.dart';

import '../../core/models/answers.dart';
import '../../core/models/jobs.dart';
import 'tokens.dart';

/// 正文/数字用 Inter，中文交给系统无衬线回退（不打包 CJK 无衬线字体）。
const _bodyFallback = <String>[
  'PingFang SC',
  'Microsoft YaHei',
  'Noto Sans CJK SC',
  'Noto Sans SC',
  'sans-serif',
];

const _monoFallback = <String>[
  'SF Mono',
  'Menlo',
  'Consolas',
  'DejaVu Sans Mono',
  'monospace',
];

/// 等宽 + 表格数字：PMID/DOI/分数/引用编号对齐用。
const monoStyle = TextStyle(
  fontFamilyFallback: _monoFallback,
  fontFeatures: [FontFeature.tabularFigures()],
);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: dark ? YaoeTokens.primaryDark : YaoeTokens.primaryLight,
    brightness: brightness,
  ).copyWith(
    primary: dark ? YaoeTokens.primaryDark : YaoeTokens.primaryLight,
    onPrimary: dark ? YaoeTokens.onPrimaryDark : YaoeTokens.onPrimaryLight,
    surface: dark ? YaoeTokens.surfaceDark : YaoeTokens.surfaceLight,
    surfaceContainerLowest: dark ? YaoeTokens.cardDark : YaoeTokens.cardLight,
    surfaceContainerLow: dark ? YaoeTokens.cardDark : YaoeTokens.cardLight,
    surfaceContainer: dark ? YaoeTokens.sidebarDark : YaoeTokens.sidebarLight,
    surfaceContainerHigh: dark ? YaoeTokens.mutedDark : YaoeTokens.mutedLight,
    surfaceContainerHighest: dark
        ? YaoeTokens.mutedDark
        : YaoeTokens.mutedLight,
    onSurface: dark ? YaoeTokens.foregroundDark : YaoeTokens.foregroundLight,
    onSurfaceVariant: (dark
            ? YaoeTokens.foregroundDark
            : YaoeTokens.foregroundLight)
        .withValues(alpha: 0.68),
    outlineVariant: dark ? YaoeTokens.borderDark : YaoeTokens.borderLight,
    outline: (dark ? YaoeTokens.borderDark : YaoeTokens.borderLight),
    error: dark ? YaoeTokens.errorDark : YaoeTokens.errorLight,
    onError: dark ? YaoeTokens.onPrimaryDark : YaoeTokens.onPrimaryLight,
  );

  final extension = dark ? YaoeColors.dark : YaoeColors.light;
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final text = _textTheme(base.textTheme, scheme);

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [extension],
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: extension.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleMedium,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: extension.sidebar,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.14),
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: extension.card,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: extension.card,
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
      ),
      labelStyle: text.labelMedium,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: scheme.primary,
      dividerColor: scheme.outlineVariant,
      labelStyle: text.labelLarge,
      unselectedLabelStyle: text.labelLarge,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
      ),
      textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusMd),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: extension.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YaoeTokens.radiusXl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(YaoeTokens.radiusXl),
        ),
      ),
    ),
  );
}

TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
  TextStyle? serif(TextStyle? style) => style?.copyWith(
    fontFamily: 'NotoSerifSC',
    fontWeight: FontWeight.w600,
    color: scheme.onSurface,
    height: 1.35,
  );
  TextStyle? sans(TextStyle? style, {double height = 1.6}) => style?.copyWith(
    fontFamily: 'Inter',
    fontFamilyFallback: _bodyFallback,
    color: scheme.onSurface,
    height: height,
  );

  return base.copyWith(
    displayLarge: serif(base.displayLarge),
    displayMedium: serif(base.displayMedium),
    displaySmall: serif(base.displaySmall),
    headlineLarge: serif(base.headlineLarge),
    headlineMedium: serif(base.headlineMedium),
    headlineSmall: serif(base.headlineSmall),
    titleLarge: serif(base.titleLarge),
    titleMedium: serif(base.titleMedium),
    titleSmall: serif(base.titleSmall),
    bodyLarge: sans(base.bodyLarge),
    bodyMedium: sans(base.bodyMedium),
    bodySmall: sans(base.bodySmall, height: 1.5),
    labelLarge: sans(base.labelLarge, height: 1.3),
    labelMedium: sans(base.labelMedium, height: 1.3),
    labelSmall: sans(base.labelSmall, height: 1.3),
  );
}

/// 答案状态色。
Color answerStatusColor(BuildContext context, AnswerStatus status) {
  final scheme = Theme.of(context).colorScheme;
  final colors = context.yaoe;
  return switch (status) {
    AnswerStatus.queued => scheme.onSurfaceVariant,
    AnswerStatus.running => colors.info,
    AnswerStatus.ready => colors.success,
    AnswerStatus.failed => scheme.error,
    AnswerStatus.cancelled => colors.warning,
  };
}

/// 任务状态色（与答案状态一致的语义映射）。
Color jobStatusColor(BuildContext context, JobStatus status) {
  final scheme = Theme.of(context).colorScheme;
  final colors = context.yaoe;
  return switch (status) {
    JobStatus.queued => scheme.onSurfaceVariant,
    JobStatus.running => colors.info,
    JobStatus.succeeded => colors.success,
    JobStatus.failed => scheme.error,
    JobStatus.cancelled => colors.warning,
  };
}
