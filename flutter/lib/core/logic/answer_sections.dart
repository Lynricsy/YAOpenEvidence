// 答案正文分节：把模型输出的粗体标签行（`**结论 / Bottom line**` 等）切成模块，
// 供答案页按「结论卡 / 证据 / PICOS / 局限」分别渲染。三端算法逐字一致。

/// 一个模块的类型；`other` 是前言或未识别标签之间的内容。
enum AnswerSectionKind { conclusion, evidence, picos, caveats, other }

/// 一节正文：[kind] 决定渲染容器，[markdown] 是去首尾空白后的原始 Markdown。
class AnswerSection {
  const AnswerSection(this.kind, this.markdown);

  final AnswerSectionKind kind;
  final String markdown;

  @override
  bool operator ==(Object other) =>
      other is AnswerSection &&
      other.kind == kind &&
      other.markdown == markdown;

  @override
  int get hashCode => Object.hash(kind, markdown);

  @override
  String toString() => 'AnswerSection(${kind.name}, $markdown)';
}

/// 粗体标签行：`**标签**`、`**标签** — 正文`、`**标签**: 正文`，允许前置 `#` 标题标记。
final _boldLabelRegex = RegExp(
  r'^\s*(?:#{1,6}\s+)?\*\*([^*\n]+?)\*\*\s*(?:[—–\-:：]\s*)?(.*)$',
);

/// 纯标题行：`## 结论`。
final _headingLabelRegex = RegExp(r'^\s*#{1,6}\s+([^\n]+?)\s*$');

/// 标签文字 → 模块类型；不是已知模块返回 null。
///
/// 四类一律「前缀」匹配：问题标题里出现关键词（如 `# Q: … 的证据强度`）不能被
/// 当成分节头。PICOS 必须先判：标签「PICOS 证据表 / PICOS table」也含「证据」。
AnswerSectionKind? answerSectionKind(String label) {
  final l = label.trim();
  final lower = l.toLowerCase();
  if (l.startsWith('结论') || lower.startsWith('bottom line')) {
    return AnswerSectionKind.conclusion;
  }
  if (lower.startsWith('picos')) return AnswerSectionKind.picos;
  if (l.startsWith('证据') || lower.startsWith('evidence')) {
    return AnswerSectionKind.evidence;
  }
  if (l.startsWith('局限') ||
      lower.startsWith('caveat') ||
      lower.startsWith('limitation')) {
    return AnswerSectionKind.caveats;
  }
  return null;
}

/// 按分节头切分正文。无分节头时整段作为一个 `other` 节；空输入返回 `[]`。
List<AnswerSection> splitAnswerSections(String markdown) {
  final out = <AnswerSection>[];
  final buffer = <String>[];
  var kind = AnswerSectionKind.other;

  void flush() {
    final text = buffer.join('\n').trim();
    buffer.clear();
    if (text.isEmpty) return;
    if (kind != AnswerSectionKind.other) {
      // 同类模块重复出现（模型分两段写证据）→ 合并进已有节，不新增。
      final index = out.indexWhere((section) => section.kind == kind);
      if (index >= 0) {
        out[index] = AnswerSection(kind, '${out[index].markdown}\n\n$text');
        return;
      }
    }
    out.add(AnswerSection(kind, text));
  }

  for (final line in markdown.replaceAll('\r\n', '\n').split('\n')) {
    var label = '';
    var rest = '';
    final bold = _boldLabelRegex.firstMatch(line);
    if (bold != null) {
      label = bold.group(1) ?? '';
      rest = bold.group(2) ?? '';
    } else {
      final heading = _headingLabelRegex.firstMatch(line);
      if (heading != null) label = heading.group(1) ?? '';
    }
    final next = label.isEmpty ? null : answerSectionKind(label);
    if (next == null) {
      buffer.add(line);
      continue;
    }
    flush();
    kind = next;
    if (rest.isNotEmpty) buffer.add(rest);
  }
  flush();
  return out;
}

/// 是否识别出了任何已知模块；否则整段按单块渲染（旧答案、模型没按格式写）。
bool hasKnownSections(List<AnswerSection> sections) =>
    sections.any((section) => section.kind != AnswerSectionKind.other);
