// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankInfo _$RankInfoFromJson(Map<String, dynamic> json) => _RankInfo(
  title: json['title'] as String? ?? '',
  issns:
      (json['issns'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  zone: (json['zone'] as num?)?.toInt() ?? 0,
  quartile: json['quartile'] as String? ?? '',
  sjr: (json['sjr'] as num?)?.toDouble(),
  hIndex: json['h_index'] as String?,
  categories: json['categories'] as String? ?? '',
  top: json['top'] as bool? ?? false,
  source: json['source'] as String? ?? '',
);

Map<String, dynamic> _$RankInfoToJson(_RankInfo instance) => <String, dynamic>{
  'title': instance.title,
  'issns': instance.issns,
  'zone': instance.zone,
  'quartile': instance.quartile,
  'sjr': ?instance.sjr,
  'h_index': ?instance.hIndex,
  'categories': instance.categories,
  'top': instance.top,
  'source': instance.source,
};

_RankQuery _$RankQueryFromJson(Map<String, dynamic> json) => _RankQuery(
  issn: json['issn'] as String? ?? '',
  title: json['title'] as String? ?? '',
);

Map<String, dynamic> _$RankQueryToJson(_RankQuery instance) =>
    <String, dynamic>{'issn': instance.issn, 'title': instance.title};

_RankResult _$RankResultFromJson(Map<String, dynamic> json) => _RankResult(
  query: RankQuery.fromJson(json['query'] as Map<String, dynamic>),
  found: json['found'] as bool? ?? false,
  rank: json['rank'] == null
      ? null
      : RankInfo.fromJson(json['rank'] as Map<String, dynamic>),
  label: json['label'] as String? ?? '',
);

Map<String, dynamic> _$RankResultToJson(_RankResult instance) =>
    <String, dynamic>{
      'query': instance.query.toJson(),
      'found': instance.found,
      'rank': ?instance.rank?.toJson(),
      'label': instance.label,
    };

_LiteratureRecord _$LiteratureRecordFromJson(Map<String, dynamic> json) =>
    _LiteratureRecord(
      source: $enumDecode(_$LiteratureSourceEnumMap, json['source']),
      id: json['id'] as String,
      pmid: json['pmid'] as String?,
      pmcid: json['pmcid'] as String?,
      doi: json['doi'] as String?,
      s2Id: json['s2_id'] as String?,
      title: json['title'] as String? ?? '',
      abstract: json['abstract'] as String?,
      year: json['year'] as String?,
      journal: json['journal'] as String?,
      issn: json['issn'] as String?,
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      citedBy: (json['cited_by'] as num?)?.toInt(),
      openAccessPdf: json['open_access_pdf'] as String?,
      tldr: json['tldr'] as String?,
      rank: json['rank'] == null
          ? null
          : RankInfo.fromJson(json['rank'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiteratureRecordToJson(_LiteratureRecord instance) =>
    <String, dynamic>{
      'source': _$LiteratureSourceEnumMap[instance.source]!,
      'id': instance.id,
      'pmid': ?instance.pmid,
      'pmcid': ?instance.pmcid,
      'doi': ?instance.doi,
      's2_id': ?instance.s2Id,
      'title': instance.title,
      'abstract': ?instance.abstract,
      'year': ?instance.year,
      'journal': ?instance.journal,
      'issn': ?instance.issn,
      'authors': instance.authors,
      'types': instance.types,
      'cited_by': ?instance.citedBy,
      'open_access_pdf': ?instance.openAccessPdf,
      'tldr': ?instance.tldr,
      'rank': ?instance.rank?.toJson(),
    };

const _$LiteratureSourceEnumMap = {
  LiteratureSource.auto: 'auto',
  LiteratureSource.pubmed: 'pubmed',
  LiteratureSource.s2: 's2',
};

_LiteratureSearchResult _$LiteratureSearchResultFromJson(
  Map<String, dynamic> json,
) => _LiteratureSearchResult(
  source: $enumDecode(_$LiteratureSourceEnumMap, json['source']),
  total: (json['total'] as num?)?.toInt() ?? 0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => LiteratureRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LiteratureRecord>[],
  fallbackReason: json['fallback_reason'] as String?,
);

Map<String, dynamic> _$LiteratureSearchResultToJson(
  _LiteratureSearchResult instance,
) => <String, dynamic>{
  'source': _$LiteratureSourceEnumMap[instance.source]!,
  'total': instance.total,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'fallback_reason': ?instance.fallbackReason,
};

_FulltextSection _$FulltextSectionFromJson(Map<String, dynamic> json) =>
    _FulltextSection(
      title: json['title'] as String? ?? '',
      chars: (json['chars'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FulltextSectionToJson(_FulltextSection instance) =>
    <String, dynamic>{'title': instance.title, 'chars': instance.chars};

_FulltextResult _$FulltextResultFromJson(Map<String, dynamic> json) =>
    _FulltextResult(
      pmcid: json['pmcid'] as String? ?? '',
      citation: json['citation'] as String? ?? '',
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => FulltextSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FulltextSection>[],
      abstract: json['abstract'] as String? ?? '',
      section: json['section'] as String?,
      text: json['text'] as String?,
      truncated: json['truncated'] as bool? ?? false,
    );

Map<String, dynamic> _$FulltextResultToJson(_FulltextResult instance) =>
    <String, dynamic>{
      'pmcid': instance.pmcid,
      'citation': instance.citation,
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'abstract': instance.abstract,
      'section': ?instance.section,
      'text': ?instance.text,
      'truncated': instance.truncated,
    };
