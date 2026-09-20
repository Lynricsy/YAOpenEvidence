import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';

/// 统一的 loading / error / data 三态渲染。
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
    this.keepPreviousOnRefresh = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  /// 刷新（已有数据）时保留旧内容，不闪回骨架。
  final bool keepPreviousOnRefresh;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue && (keepPreviousOnRefresh || !value.isLoading)) {
      return builder(value.requireValue);
    }
    if (value.hasError && !value.isLoading) {
      return ErrorView(error: value.error!, onRetry: onRetry);
    }
    return loading ?? const LoadingView();
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.padding = PicoSeekTokens.space6});

  final double padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(padding),
    child: const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

/// 错误态：中文文案 + 重试按钮。
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(PicoSeekTokens.space5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(height: PicoSeekTokens.space2),
          Text(
            errorMessageOf(error),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: PicoSeekTokens.space3),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 任意异常 → 用户可见文案。
String errorMessageOf(Object error) => switch (error) {
  ApiError() => error.userMessage,
  StateError() => '当前状态不可用，请重新登录',
  _ => '网络连接失败，请稍后重试',
};
