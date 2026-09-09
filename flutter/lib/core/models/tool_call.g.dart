// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ToolCall _$ToolCallFromJson(Map<String, dynamic> json) => _ToolCall(
  callId: json['call_id'] as String,
  server: json['server'] as String? ?? '',
  tool: json['tool'] as String? ?? '',
  status:
      $enumDecodeNullable(
        _$ToolCallStatusEnumMap,
        json['status'],
        unknownValue: ToolCallStatus.completed,
      ) ??
      ToolCallStatus.completed,
  args: json['args'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  durationMs: (json['duration_ms'] as num?)?.toInt(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$ToolCallToJson(_ToolCall instance) => <String, dynamic>{
  'call_id': instance.callId,
  'server': instance.server,
  'tool': instance.tool,
  'status': _$ToolCallStatusEnumMap[instance.status]!,
  'args': instance.args,
  'duration_ms': ?instance.durationMs,
  'error': ?instance.error,
};

const _$ToolCallStatusEnumMap = {
  ToolCallStatus.started: 'started',
  ToolCallStatus.completed: 'completed',
  ToolCallStatus.failed: 'failed',
};
