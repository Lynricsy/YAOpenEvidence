// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ValidationIssue _$ValidationIssueFromJson(Map<String, dynamic> json) =>
    _ValidationIssue(
      loc: json['loc'] == null ? const <String>[] : _locFromJson(json['loc']),
      msg: json['msg'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );

Map<String, dynamic> _$ValidationIssueToJson(_ValidationIssue instance) =>
    <String, dynamic>{
      'loc': instance.loc,
      'msg': instance.msg,
      'type': instance.type,
    };

_Problem _$ProblemFromJson(Map<String, dynamic> json) => _Problem(
  type: json['type'] as String?,
  title: json['title'] as String?,
  status: (json['status'] as num?)?.toInt(),
  detail: json['detail'] as String?,
  instance: json['instance'] as String?,
  code: json['code'] as String?,
  errors: (json['errors'] as List<dynamic>?)
      ?.map((e) => ValidationIssue.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProblemToJson(_Problem instance) => <String, dynamic>{
  'type': ?instance.type,
  'title': ?instance.title,
  'status': ?instance.status,
  'detail': ?instance.detail,
  'instance': ?instance.instance,
  'code': ?instance.code,
  'errors': ?instance.errors?.map((e) => e.toJson()).toList(),
};
