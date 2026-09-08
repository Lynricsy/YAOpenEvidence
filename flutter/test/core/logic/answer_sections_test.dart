import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/logic/answer_sections.dart';

List<AnswerSectionKind> _kinds(List<AnswerSection> sections) =>
    sections.map((section) => section.kind).toList();

void main() {
  test('V1 破折号同行标签切出四个模块', () {
    const source = '''
**结论 / Bottom line** — 依据现有证据给出简要结论 [1¶2]。

**证据 / Evidence**
- 队列研究报告了主要结局 [1¶2]。

**PICOS 证据表 / PICOS table**

| [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |
|---|---|---|---|---|---|
| [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |

**局限 / Caveats**
- 观察性设计，存在残余混杂。''';
    final sections = splitAnswerSections(source);
    expect(_kinds(sections), [
      AnswerSectionKind.conclusion,
      AnswerSectionKind.evidence,
      AnswerSectionKind.picos,
      AnswerSectionKind.caveats,
    ]);
    expect(sections[0].markdown, '依据现有证据给出简要结论 [1¶2]。');
    expect(sections[1].markdown, '- 队列研究报告了主要结局 [1¶2]。');
    expect(
      sections[2].markdown,
      '| [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |\n'
      '|---|---|---|---|---|---|\n'
      '| [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |',
    );
    expect(sections[3].markdown, '- 观察性设计，存在残余混杂。');
  });

  test('V2 冒号标签、行尾空白、无 PICOS，子弹内粗体不是分节头', () {
    const source =
        '**结论 / Bottom line**:\n'
        '阿司匹林可降低事件风险。\n'
        '\n'
        '**证据 / Evidence**:  \n'
        '- **糖尿病患者**：HR 0.88 [1]。\n'
        '\n'
        '**局限 / Caveats**:\n'
        '- 人群异质性大。';
    final sections = splitAnswerSections(source);
    expect(_kinds(sections), [
      AnswerSectionKind.conclusion,
      AnswerSectionKind.evidence,
      AnswerSectionKind.caveats,
    ]);
    expect(sections[0].markdown, '阿司匹林可降低事件风险。');
    expect(sections[1].markdown, '- **糖尿病患者**：HR 0.88 [1]。');
    expect(sections[2].markdown, '- 人群异质性大。');
  });

  test('V3 标题形式与英文标签', () {
    final sections = splitAnswerSections('## 结论\nA\n\n### Evidence\n- b');
    expect(sections, const [
      AnswerSection(AnswerSectionKind.conclusion, 'A'),
      AnswerSection(AnswerSectionKind.evidence, '- b'),
    ]);
  });

  test('V4 无标签的旧渲染稿整段作为 other', () {
    const source = '# Q: 问题\n\n正文 [1]';
    final sections = splitAnswerSections(source);
    expect(sections, const [AnswerSection(AnswerSectionKind.other, source)]);
    expect(hasKnownSections(sections), isFalse);
  });

  test('问题标题里含关键词不算分节头（前缀匹配回归）', () {
    const source = '# Q: SGLT2 抑制剂在 HFpEF 的证据强度\n\n正文 [1]';
    final sections = splitAnswerSections(source);
    expect(sections, const [AnswerSection(AnswerSectionKind.other, source)]);
    expect(hasKnownSections(sections), isFalse);
  });

  test('V5 前言保留，同类模块重复出现时合并', () {
    final sections = splitAnswerSections(
      '前言\n\n**结论**\nA\n\n**证据**\n- x\n\n**证据**\n- y',
    );
    expect(sections, const [
      AnswerSection(AnswerSectionKind.other, '前言'),
      AnswerSection(AnswerSectionKind.conclusion, 'A'),
      AnswerSection(AnswerSectionKind.evidence, '- x\n\n- y'),
    ]);
    expect(hasKnownSections(sections), isTrue);
  });

  test('V6 非模块的粗体行留在内容里', () {
    final sections = splitAnswerSections(
      '**结论 / Bottom line**\nA\n\n**其他要点**\nB',
    );
    expect(sections, const [
      AnswerSection(AnswerSectionKind.conclusion, 'A\n\n**其他要点**\nB'),
    ]);
  });

  test('V7 空输入返回空列表', () {
    expect(splitAnswerSections(''), isEmpty);
    expect(splitAnswerSections('  \n\n'), isEmpty);
    expect(hasKnownSections(const []), isFalse);
  });

  test('标签判定：PICOS 优先于证据', () {
    expect(
      answerSectionKind('PICOS 证据表 / PICOS table'),
      AnswerSectionKind.picos,
    );
    expect(answerSectionKind('证据 / Evidence'), AnswerSectionKind.evidence);
    expect(answerSectionKind('Bottom line'), AnswerSectionKind.conclusion);
    expect(answerSectionKind('Limitations'), AnswerSectionKind.caveats);
    expect(answerSectionKind('其他要点'), isNull);
  });
}
