import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool_call.freezed.dart';
part 'tool_call.g.dart';

enum ToolCallStatus { started, completed, failed }

/// 后端未来新增终态时不至于整条轨迹解码失败：未知状态按「已结束」处理，
/// 至少不会永远转圈。
const _statusKey = JsonKey(unknownEnumValue: ToolCallStatus.completed);

/// 智能体的一次工具调用。同一 [callId] 会先后收到 `started` 与终态两条，
/// 客户端按 [callId] 就地替换而不是追加。
///
/// 与 SSE `tool` 事件、`Answer.trace` 是同一形状：实时轨迹与落库轨迹共用一套渲染。
@freezed
abstract class ToolCall with _$ToolCall {
  const factory ToolCall({
    required String callId,
    @Default('') String server,
    @Default('') String tool,
    @_statusKey @Default(ToolCallStatus.completed) ToolCallStatus status,
    @Default(<String, dynamic>{}) Map<String, dynamic> args,
    int? durationMs,
    String? error,
  }) = _ToolCall;

  factory ToolCall.fromJson(Map<String, Object?> json) =>
      _$ToolCallFromJson(json);
}
