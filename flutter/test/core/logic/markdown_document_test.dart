import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/logic/citations.dart';
import 'package:picoseek/core/logic/markdown_document.dart';

List<InlineRun> runsOf(MarkdownBlock? block) => switch (block) {
  MdParagraph(:final runs) => runs,
  MdHeading(:final runs) => runs,
  _ => const [],
};

void main() {
  test('裸标记只在 1…limit 内识别为引用', () {
    final blocks = parseMarkdown('A[1¶12] B[2] C[9] D[2024]', citationLimit: 3);
    final runs = runsOf(blocks.first);
    expect(runs.map((r) => r.citation).whereType<CitationRef>(), [
      const CitationRef(1, 12),
      const CitationRef(2, null),
    ]);
    expect(plainTextOf(runs), 'A[1¶12] B[2] C[9] D[2024]');
  });

  test('citationLimit 为 null 时不识别裸标记', () {
    final blocks = parseMarkdown('A[1¶12]');
    expect(runsOf(blocks.first).every((r) => r.citation == null), isTrue);
  });

  test('链接与行内代码里的方括号不算引用', () {
    final blocks = parseMarkdown(
      '[1](https://example.com) 与 `[2]`',
      citationLimit: 5,
    );
    final runs = runsOf(blocks.first);
    expect(runs.every((r) => r.citation == null), isTrue);
    expect(
      runs.any((r) => r.link?.toString() == 'https://example.com'),
      isTrue,
    );
    expect(
      runs.any((r) => r.style.has(InlineStyle.code) && r.text == '[2]'),
      isTrue,
    );
  });

  test('反斜杠转义的标记不识别', () {
    final blocks = parseMarkdown(r'A\[1] B[2]', citationLimit: 5);
    final runs = runsOf(blocks.first);
    expect(runs.map((r) => r.citation).whereType<CitationRef>(), [
      const CitationRef(2, null),
    ]);
    expect(plainTextOf(runs), 'A[1] B[2]');
  });

  test('渲染稿链接形式的引用', () {
    final blocks = parseMarkdown('见 [3¶7](/v1/answers/x/papers/3/markdown#p7)。');
    final runs = runsOf(blocks.first);
    expect(runs.map((r) => r.citation).whereType<CitationRef>(), [
      const CitationRef(3, 7),
    ]);
    expect(runs.firstWhere((r) => r.citation != null).text, '3¶7');
  });

  test('段落锚点与加粗段号', () {
    final blocks = parseMarkdown('<a id="p12"></a>**¶12** 正文内容');
    final block = blocks.first;
    expect(block, isA<MdParagraph>());
    final paragraph = block as MdParagraph;
    expect(paragraph.anchor, 12);
    expect(paragraph.runs.first.text, '¶12');
    expect(paragraph.runs.first.style.has(InlineStyle.bold), isTrue);
    expect(plainTextOf(paragraph.runs), '¶12 正文内容');
  });

  test('<mark> 切换高亮样式', () {
    final blocks = parseMarkdown('前 <mark>命中</mark> 后');
    final runs = runsOf(blocks.first);
    final marked = runs.where((r) => r.style.has(InlineStyle.highlight));
    expect(marked.map((r) => r.text).join(), '命中');
    expect(plainTextOf(runs), '前 命中 后');
  });

  test('标题、列表、引用块、代码块与分隔线', () {
    const source = '''
# 标题

- 甲
- 乙

1. 第一
2. 第二

> 引文

```dart
final x = 1;
```

---
''';
    final blocks = parseMarkdown(source);
    expect(blocks, hasLength(6));
    expect((blocks[0] as MdHeading).level, 1);
    final unordered = blocks[1] as MdList;
    expect(unordered.ordered, isFalse);
    expect(unordered.items, hasLength(2));
    final ordered = blocks[2] as MdList;
    expect(ordered.ordered, isTrue);
    expect(ordered.start, 1);
    expect((blocks[3] as MdBlockQuote).blocks, hasLength(1));
    final code = blocks[4] as MdCodeBlock;
    expect(code.language, 'dart');
    expect(code.code, contains('final x = 1;'));
    expect(blocks[5], isA<MdThematicBreak>());
  });

  test('表格解析为表头与数据行', () {
    const source = '''
| 指标 | 值 |
| --- | --- |
| HR | 0.8 |
| CI | 0.6–0.9 |
''';
    final block = parseMarkdown(source).first;
    expect(block, isA<MdTable>());
    final table = block as MdTable;
    expect(table.header.map(plainTextOf), ['指标', '值']);
    expect(table.rows, hasLength(2));
    expect(table.rows[1].map(plainTextOf), ['CI', '0.6–0.9']);
  });

  test('中文段落里的引用位置正确切分', () {
    final blocks = parseMarkdown(
      '恩格列净降低住院风险[1¶45]，且耐受良好[2¶7]。',
      citationLimit: 2,
    );
    final runs = runsOf(blocks.first);
    expect(runs.map((r) => r.text), [
      '恩格列净降低住院风险',
      '[1¶45]',
      '，且耐受良好',
      '[2¶7]',
      '。',
    ]);
    expect(runs.map((r) => r.citation).whereType<CitationRef>(), [
      const CitationRef(1, 45),
      const CitationRef(2, 7),
    ]);
  });
}
