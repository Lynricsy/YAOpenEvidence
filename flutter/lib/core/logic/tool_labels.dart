import 'package:flutter/material.dart';

/// MCP 工具名 → 中文动作与图标；三端共用同一张表，轨迹在哪读都一样。
const _tools = <String, (String, IconData)>{
  'search_papers': ('检索 Semantic Scholar', Icons.search),
  'pubmed_search': ('检索 PubMed', Icons.search),
  'get_paper': ('查看论文详情', Icons.description_outlined),
  'pubmed_fetch': ('获取 PubMed 记录', Icons.description_outlined),
  'get_citations': ('查看引用文献', Icons.format_quote),
  'get_references': ('查看参考文献', Icons.menu_book_outlined),
  'get_recommendations': ('查找相似论文', Icons.auto_awesome),
  'search_authors': ('检索作者', Icons.person_outline),
  'get_fulltext': ('读取全文（PMC）', Icons.article_outlined),
  'read_pdf': ('读取 PDF', Icons.picture_as_pdf_outlined),
  'kb_search': ('查询知识库', Icons.storage_outlined),
  'exec': ('执行命令', Icons.terminal),
};

/// 未登记的工具退回 `server/tool` 原文：宁可难看，也不要把它藏起来。
String toolLabel(String server, String tool) =>
    _tools[tool]?.$1 ?? '$server/$tool';

IconData toolIcon(String tool) => _tools[tool]?.$2 ?? Icons.build_outlined;

/// 参数里最能说明「在查什么」的那一个键；顺序即优先级。
const _argKeys = <String>[
  'query',
  'name',
  'paper_id',
  'pmids',
  'path',
  'command',
];

String describeToolArgs(Map<String, dynamic> args) {
  for (final key in _argKeys) {
    final value = args[key];
    if (value == null) continue;
    final raw = '$value';
    final chars = raw.characters;
    final clipped = chars.length > 60 ? '${chars.take(60)}…' : raw;
    final section = args['section'];
    final suffix = section is String && section.isNotEmpty ? ' · $section' : '';
    return '「$clipped」$suffix';
  }
  return '';
}

String formatDuration(int? ms) =>
    ms == null ? '' : '${(ms / 1000).toStringAsFixed(1)}s';
