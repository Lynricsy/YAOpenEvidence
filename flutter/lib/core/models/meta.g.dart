// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankTable _$RankTableFromJson(Map<String, dynamic> json) => _RankTable(
  file: json['file'] as String? ?? '',
  year: (json['year'] as num?)?.toInt(),
  journals: (json['journals'] as num?)?.toInt() ?? 0,
  source: json['source'] as String? ?? 'custom',
);

Map<String, dynamic> _$RankTableToJson(_RankTable instance) =>
    <String, dynamic>{
      'file': instance.file,
      'year': ?instance.year,
      'journals': instance.journals,
      'source': instance.source,
    };

_RankTables _$RankTablesFromJson(Map<String, dynamic> json) => _RankTables(
  tables:
      (json['tables'] as List<dynamic>?)
          ?.map((e) => RankTable.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RankTable>[],
  issns: (json['issns'] as num?)?.toInt() ?? 0,
  titles: (json['titles'] as num?)?.toInt() ?? 0,
  loadedAt: json['loaded_at'] == null
      ? null
      : DateTime.parse(json['loaded_at'] as String),
);

Map<String, dynamic> _$RankTablesToJson(_RankTables instance) =>
    <String, dynamic>{
      'tables': instance.tables.map((e) => e.toJson()).toList(),
      'issns': instance.issns,
      'titles': instance.titles,
      'loaded_at': ?instance.loadedAt?.toIso8601String(),
    };

_PaywallStatus _$PaywallStatusFromJson(Map<String, dynamic> json) =>
    _PaywallStatus(
      configured: json['configured'] as bool? ?? false,
      savedAt: json['saved_at'] == null
          ? null
          : DateTime.parse(json['saved_at'] as String),
      finalUrl: json['final_url'] as String?,
      hasSessionStorage: json['has_session_storage'] as bool? ?? false,
      hasContextMeta: json['has_context_meta'] as bool? ?? false,
      playwrightAvailable: json['playwright_available'] as bool? ?? false,
    );

Map<String, dynamic> _$PaywallStatusToJson(_PaywallStatus instance) =>
    <String, dynamic>{
      'configured': instance.configured,
      'saved_at': ?instance.savedAt?.toIso8601String(),
      'final_url': ?instance.finalUrl,
      'has_session_storage': instance.hasSessionStorage,
      'has_context_meta': instance.hasContextMeta,
      'playwright_available': instance.playwrightAvailable,
    };
