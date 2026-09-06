import 'package:freezed_annotation/freezed_annotation.dart';

part 'health.freezed.dart';
part 'health.g.dart';

@freezed
abstract class HealthResponse with _$HealthResponse {
  const factory HealthResponse({
    @Default('') String status,
    @Default('') String version,
    required DateTime time,
  }) = _HealthResponse;

  factory HealthResponse.fromJson(Map<String, Object?> json) =>
      _$HealthResponseFromJson(json);
}

@freezed
abstract class DependencyCheck with _$DependencyCheck {
  const factory DependencyCheck({
    @Default(false) bool ok,
    @Default('') String detail,
  }) = _DependencyCheck;

  factory DependencyCheck.fromJson(Map<String, Object?> json) =>
      _$DependencyCheckFromJson(json);
}

@freezed
abstract class ReadinessChecks with _$ReadinessChecks {
  const factory ReadinessChecks({
    required DependencyCheck db,
    required DependencyCheck redis,
    required DependencyCheck llm,
    required DependencyCheck kb,
    required DependencyCheck ranks,
  }) = _ReadinessChecks;

  factory ReadinessChecks.fromJson(Map<String, Object?> json) =>
      _$ReadinessChecksFromJson(json);
}

/// `/v1/health/ready` 是唯一一个非 2xx 也不返回 Problem 的端点（503 仍是本模型）。
@freezed
abstract class ReadinessResponse with _$ReadinessResponse {
  const factory ReadinessResponse({
    @Default('') String status,
    required ReadinessChecks checks,
  }) = _ReadinessResponse;

  factory ReadinessResponse.fromJson(Map<String, Object?> json) =>
      _$ReadinessResponseFromJson(json);
}
