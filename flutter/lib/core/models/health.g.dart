// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    _HealthResponse(
      status: json['status'] as String? ?? '',
      version: json['version'] as String? ?? '',
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$HealthResponseToJson(_HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'version': instance.version,
      'time': instance.time.toIso8601String(),
    };

_DependencyCheck _$DependencyCheckFromJson(Map<String, dynamic> json) =>
    _DependencyCheck(
      ok: json['ok'] as bool? ?? false,
      detail: json['detail'] as String? ?? '',
    );

Map<String, dynamic> _$DependencyCheckToJson(_DependencyCheck instance) =>
    <String, dynamic>{'ok': instance.ok, 'detail': instance.detail};

_ReadinessChecks _$ReadinessChecksFromJson(Map<String, dynamic> json) =>
    _ReadinessChecks(
      db: DependencyCheck.fromJson(json['db'] as Map<String, dynamic>),
      redis: DependencyCheck.fromJson(json['redis'] as Map<String, dynamic>),
      llm: DependencyCheck.fromJson(json['llm'] as Map<String, dynamic>),
      kb: DependencyCheck.fromJson(json['kb'] as Map<String, dynamic>),
      ranks: DependencyCheck.fromJson(json['ranks'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadinessChecksToJson(_ReadinessChecks instance) =>
    <String, dynamic>{
      'db': instance.db.toJson(),
      'redis': instance.redis.toJson(),
      'llm': instance.llm.toJson(),
      'kb': instance.kb.toJson(),
      'ranks': instance.ranks.toJson(),
    };

_ReadinessResponse _$ReadinessResponseFromJson(Map<String, dynamic> json) =>
    _ReadinessResponse(
      status: json['status'] as String? ?? '',
      checks: ReadinessChecks.fromJson(json['checks'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadinessResponseToJson(_ReadinessResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'checks': instance.checks.toJson(),
    };
