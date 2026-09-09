import '../models/problem.dart';

/// 所有 API 调用的统一错误类型。
sealed class ApiError implements Exception {
  const ApiError();

  int? get status => switch (this) {
    HttpProblem(:final status) => status,
    _ => null,
  };

  String? get code => switch (this) {
    HttpProblem(:final code) => code,
    _ => null,
  };

  String get detail => switch (this) {
    HttpProblem(:final detail) => detail,
    _ => '',
  };

  int? get retryAfter => switch (this) {
    HttpProblem(:final retryAfter) => retryAfter,
    _ => null,
  };

  /// 与 Web 端 `problemMessage` 逐字一致的用户可见文案。
  String get userMessage {
    if (this is! HttpProblem) return '网络连接失败，请稍后重试';
    final problem = this as HttpProblem;
    switch (problem.code) {
      case 'validation_error':
        final joined = (problem.errors ?? const <ValidationIssue>[])
            .map((e) => e.msg)
            .join('；');
        return '参数校验失败：${joined.isEmpty ? problem.detail : joined}';
      case 'login_rate_limited':
        final retryAfter = problem.retryAfter;
        if (retryAfter != null) return '登录尝试过多，请 $retryAfter 秒后再试';
        return '登录尝试过多，请稍后再试';
      case 'upstream_unavailable':
        return '上游服务不可用：${problem.detail}';
      default:
        return _messages[problem.code] ?? '服务器内部错误';
    }
  }
}

/// 后端返回非 2xx；`code` 取自 Problem，缺省 `internal_error`。
final class HttpProblem extends ApiError {
  const HttpProblem({
    required this.status,
    required this.code,
    this.detail = '',
    this.errors,
    this.retryAfter,
  });

  @override
  final int status;
  @override
  final String code;
  @override
  final String detail;
  final List<ValidationIssue>? errors;
  @override
  final int? retryAfter;

  @override
  String toString() => 'HttpProblem($status, $code, $detail)';
}

/// 网络层失败（连接被拒、超时等）。
final class Transport extends ApiError {
  const Transport(this.underlying);

  final Object underlying;

  @override
  String toString() => 'Transport($underlying)';
}

/// 响应体无法按预期模型解码。
final class Decoding extends ApiError {
  const Decoding(this.underlying);

  final Object underlying;

  @override
  String toString() => 'Decoding($underlying)';
}

/// 响应缺少必要信息等异常情况。
final class InvalidResponse extends ApiError {
  const InvalidResponse();

  @override
  String toString() => 'InvalidResponse()';
}

const Map<String, String> _messages = {
  'unauthenticated': '登录已失效，请重新登录',
  'forbidden': '需要管理员权限',
  'not_found': '资源不存在或无权访问',
  'not_ready': '答案尚未生成完成',
  'conflict': '当前状态不允许该操作',
  'thread_busy': '上一轮还在进行中，稍后再追问',
  'username_exists': '用户名已存在',
  'cannot_disable_self': '不能禁用自己',
  'last_admin': '必须保留至少一个活跃管理员',
  'too_many_jobs': '进行中的任务已达上限，请等待完成或先取消',
  'unavailable': '服务暂不可用',
  'fulltext_unavailable': '无可用全文',
};

/// 任务失败码 → 中文文案（与 Web 端 `jobErrorMessage` 一致）。
String jobErrorMessage(String code) => switch (code) {
  'no_papers' => '没有文献通过筛选，请放宽年份 / 分区 / 期刊，或勾选「含未收录期刊」',
  'nothing_relevant' => '检索到的文献都与问题无关，请换个问法或放宽筛选',
  'llm_unavailable' => '模型服务不可用，请稍后重试',
  'codex_failed' => '智能体本轮执行失败，请重试或改用标准引擎',
  'timeout' => '任务超时',
  'internal_error' => '内部错误',
  _ => '任务执行失败',
};
