import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem.freezed.dart';
part 'problem.g.dart';

/// FastAPI 的 `loc` 元素可能是字符串或整数（数组下标），统一转成字符串。
List<String> _locFromJson(Object? raw) {
  if (raw is! List) return const <String>[];
  return raw
      .map((e) => e is String ? e : (e is num ? '$e' : ''))
      .toList(growable: false);
}

@freezed
abstract class ValidationIssue with _$ValidationIssue {
  const factory ValidationIssue({
    @JsonKey(fromJson: _locFromJson) @Default(<String>[]) List<String> loc,
    @Default('') String msg,
    @Default('') String type,
  }) = _ValidationIssue;

  factory ValidationIssue.fromJson(Map<String, Object?> json) =>
      _$ValidationIssueFromJson(json);
}

/// RFC 9457 Problem Details。全部字段可选：反向代理或网关可能返回非标准错误体。
@freezed
abstract class Problem with _$Problem {
  const factory Problem({
    String? type,
    String? title,
    int? status,
    String? detail,
    String? instance,
    String? code,
    List<ValidationIssue>? errors,
  }) = _Problem;

  factory Problem.fromJson(Map<String, Object?> json) =>
      _$ProblemFromJson(json);
}
