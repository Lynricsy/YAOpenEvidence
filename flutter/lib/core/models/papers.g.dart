// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'papers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Paragraph _$ParagraphFromJson(Map<String, dynamic> json) => _Paragraph(
  id: (json['id'] as num).toInt(),
  sec: json['sec'] as String? ?? '',
  page: (json['page'] as num?)?.toInt(),
  text: json['text'] as String? ?? '',
);

Map<String, dynamic> _$ParagraphToJson(_Paragraph instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sec': instance.sec,
      'page': ?instance.page,
      'text': instance.text,
    };

_Fact _$FactFromJson(Map<String, dynamic> json) => _Fact(
  fact: json['fact'] as String? ?? '',
  factZh: json['fact_zh'] as String? ?? '',
  kind: json['kind'] as String? ?? '',
  pid: (json['pid'] as num?)?.toInt(),
  sec: json['sec'] as String?,
  page: (json['page'] as num?)?.toInt(),
  quote: json['quote'] as String? ?? '',
  score: (json['score'] as num?)?.toDouble() ?? 0,
  verified: json['verified'] as bool? ?? false,
);

Map<String, dynamic> _$FactToJson(_Fact instance) => <String, dynamic>{
  'fact': instance.fact,
  'fact_zh': instance.factZh,
  'kind': instance.kind,
  'pid': ?instance.pid,
  'sec': ?instance.sec,
  'page': ?instance.page,
  'quote': instance.quote,
  'score': instance.score,
  'verified': instance.verified,
};

_VerifiedQuote _$VerifiedQuoteFromJson(Map<String, dynamic> json) =>
    _VerifiedQuote(
      claimedPid: (json['claimed_pid'] as num?)?.toInt() ?? 0,
      pid: (json['pid'] as num?)?.toInt(),
      sec: json['sec'] as String?,
      page: (json['page'] as num?)?.toInt(),
      quote: json['quote'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      verified: json['verified'] as bool? ?? false,
      noteSection: json['note_section'] as String?,
      keyFinding: json['key_finding'] as bool? ?? false,
    );

Map<String, dynamic> _$VerifiedQuoteToJson(_VerifiedQuote instance) =>
    <String, dynamic>{
      'claimed_pid': instance.claimedPid,
      'pid': ?instance.pid,
      'sec': ?instance.sec,
      'page': ?instance.page,
      'quote': instance.quote,
      'score': instance.score,
      'verified': instance.verified,
      'note_section': ?instance.noteSection,
      'key_finding': instance.keyFinding,
    };

_PaperMeta _$PaperMetaFromJson(Map<String, dynamic> json) => _PaperMeta(
  key: json['key'] as String,
  pmid: json['pmid'] as String? ?? '',
  doi: json['doi'] as String? ?? '',
  pmcid: json['pmcid'] as String? ?? '',
  title: json['title'] as String? ?? '',
  year: json['year'] as String? ?? '',
  journal: json['journal'] as String? ?? '',
  issn: json['issn'] as String? ?? '',
  quartile: json['quartile'] as String? ?? '',
  authors: json['authors'] as String? ?? '',
  source: json['source'] as String? ?? '',
  types:
      (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  indexedAt: json['indexed_at'] == null
      ? null
      : DateTime.parse(json['indexed_at'] as String),
  nParagraphs: (json['n_paragraphs'] as num?)?.toInt() ?? 0,
  nFacts: (json['n_facts'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PaperMetaToJson(_PaperMeta instance) =>
    <String, dynamic>{
      'key': instance.key,
      'pmid': instance.pmid,
      'doi': instance.doi,
      'pmcid': instance.pmcid,
      'title': instance.title,
      'year': instance.year,
      'journal': instance.journal,
      'issn': instance.issn,
      'quartile': instance.quartile,
      'authors': instance.authors,
      'source': instance.source,
      'types': instance.types,
      'indexed_at': ?instance.indexedAt?.toIso8601String(),
      'n_paragraphs': instance.nParagraphs,
      'n_facts': instance.nFacts,
    };
