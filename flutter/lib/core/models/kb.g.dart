// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KbHit _$KbHitFromJson(Map<String, dynamic> json) => _KbHit(
  kind: $enumDecode(_$KbKindEnumMap, json['kind']),
  pmid: json['pmid'] as String? ?? '',
  doi: json['doi'] as String? ?? '',
  pmcid: json['pmcid'] as String? ?? '',
  title: json['title'] as String? ?? '',
  year: json['year'] as String? ?? '',
  journal: json['journal'] as String? ?? '',
  quartile: json['quartile'] as String? ?? '',
  source: json['source'] as String? ?? '',
  authors: json['authors'] as String? ?? '',
  pid: (json['pid'] as num?)?.toInt(),
  sec: json['sec'] as String?,
  page: (json['page'] as num?)?.toInt(),
  text: json['text'] as String? ?? '',
  textZh: json['text_zh'] as String?,
  factKind: json['fact_kind'] as String?,
  quote: json['quote'] as String?,
  verified: json['verified'] as bool?,
  score: (json['score'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$KbHitToJson(_KbHit instance) => <String, dynamic>{
  'kind': _$KbKindEnumMap[instance.kind]!,
  'pmid': instance.pmid,
  'doi': instance.doi,
  'pmcid': instance.pmcid,
  'title': instance.title,
  'year': instance.year,
  'journal': instance.journal,
  'quartile': instance.quartile,
  'source': instance.source,
  'authors': instance.authors,
  'pid': ?instance.pid,
  'sec': ?instance.sec,
  'page': ?instance.page,
  'text': instance.text,
  'text_zh': ?instance.textZh,
  'fact_kind': ?instance.factKind,
  'quote': ?instance.quote,
  'verified': ?instance.verified,
  'score': instance.score,
};

const _$KbKindEnumMap = {KbKind.fact: 'fact', KbKind.paragraph: 'paragraph'};

_KbSearchResult _$KbSearchResultFromJson(Map<String, dynamic> json) =>
    _KbSearchResult(
      query: json['query'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => KbHit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <KbHit>[],
    );

Map<String, dynamic> _$KbSearchResultToJson(_KbSearchResult instance) =>
    <String, dynamic>{
      'query': instance.query,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_KbStats _$KbStatsFromJson(Map<String, dynamic> json) => _KbStats(
  items: (json['items'] as num?)?.toInt() ?? 0,
  papers: (json['papers'] as num?)?.toInt() ?? 0,
  byKind:
      (json['by_kind'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  embedder: json['embedder'] as String?,
  dim: (json['dim'] as num?)?.toInt(),
);

Map<String, dynamic> _$KbStatsToJson(_KbStats instance) => <String, dynamic>{
  'items': instance.items,
  'papers': instance.papers,
  'by_kind': instance.byKind,
  'embedder': ?instance.embedder,
  'dim': ?instance.dim,
};
