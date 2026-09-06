import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/logic/inline_highlight.dart';
import 'package:yaopenevidence/core/logic/markdown_document.dart';

void main() {
  test('命中引文时拆分 run 并加高亮', () {
    final runs = highlightQuotes(const [
      InlineRun(text: '结论：恩格列净降低住院风险，安全性良好。'),
    ], const ['恩格列净降低住院风险']);
    expect(runs.map((r) => r.text), ['结论：', '恩格列净降低住院风险', '，安全性良好。']);
    expect(
      runs.map((r) => r.style.has(InlineStyle.highlight)),
      [false, true, false],
    );
  });

  test('长度小于 4 的引文忽略', () {
    const original = [InlineRun(text: 'abcdef')];
    expect(highlightQuotes(original, const ['abc']), same(original));
  });

  test('只高亮首次出现', () {
    final runs = highlightQuotes(const [
      InlineRun(text: 'quote here and quote here again'),
    ], const ['quote here']);
    final highlighted = runs
        .where((r) => r.style.has(InlineStyle.highlight))
        .toList();
    expect(highlighted, hasLength(1));
    expect(highlighted.single.text, 'quote here');
  });

  test('跨 run 边界按码点定位并保留原样式', () {
    final runs = highlightQuotes(const [
      InlineRun(text: '甲乙', style: InlineStyle.bold),
      InlineRun(text: '丙丁戊'),
    ], const ['乙丙丁戊']);
    expect(runs.map((r) => r.text), ['甲', '乙', '丙丁戊']);
    expect(runs[0].style.has(InlineStyle.highlight), isFalse);
    expect(runs[1].style.has(InlineStyle.bold), isTrue);
    expect(runs[1].style.has(InlineStyle.highlight), isTrue);
    expect(runs[2].style.has(InlineStyle.highlight), isTrue);
  });

  test('星号外的组合符号不会让偏移错位', () {
    // 'e' + U+0301 是一个字素、两个码点：按字素计数会把高亮切歪。
    final runs = highlightQuotes(const [
      InlineRun(text: 'cafe\u0301 latte'),
    ], const ['latte']);
    expect(runs.map((r) => r.text), ['cafe\u0301 ', 'latte']);
    expect(runs.last.style.has(InlineStyle.highlight), isTrue);
  });
}
