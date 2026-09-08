import { describe, expect, it } from 'vitest'
import {
  hasKnownSections,
  splitAnswerSections,
  type AnswerSection,
} from './answerSections'

const kinds = (sections: AnswerSection[]) => sections.map((s) => s.kind)

describe('答案分节', () => {
  it('V1 破折号同行标签切出四节', () => {
    const sections = splitAnswerSections(
      [
        '**结论 / Bottom line** — 依据现有证据给出简要结论 [1¶2]。',
        '',
        '**证据 / Evidence**',
        '- 队列研究报告了主要结局 [1¶2]。',
        '',
        '**PICOS 证据表 / PICOS table**',
        '',
        '| [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |',
        '|---|---|---|---|---|---|',
        '| [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |',
        '',
        '**局限 / Caveats**',
        '- 观察性设计，存在残余混杂。',
      ].join('\n'),
    )
    expect(kinds(sections)).toEqual([
      'conclusion',
      'evidence',
      'picos',
      'caveats',
    ])
    expect(sections[0]?.markdown).toBe('依据现有证据给出简要结论 [1¶2]。')
    expect(sections[1]?.markdown).toBe('- 队列研究报告了主要结局 [1¶2]。')
    expect(sections[2]?.markdown).toBe(
      [
        '| [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |',
        '|---|---|---|---|---|---|',
        '| [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |',
      ].join('\n'),
    )
    expect(sections[3]?.markdown).toBe('- 观察性设计，存在残余混杂。')
  })

  it('V2 冒号加行尾硬换行，缺 PICOS，子弹内粗体不当分节头', () => {
    const sections = splitAnswerSections(
      [
        '**结论 / Bottom line**:  ',
        '阿司匹林可降低事件风险。',
        '',
        '**证据 / Evidence**:  ',
        '- **糖尿病患者**：HR 0.88 [1]。  ',
        '',
        '**局限 / Caveats**:  ',
        '- 人群异质性大。',
      ].join('\n'),
    )
    expect(kinds(sections)).toEqual(['conclusion', 'evidence', 'caveats'])
    expect(sections[0]?.markdown).toBe('阿司匹林可降低事件风险。')
    expect(sections[1]?.markdown).toBe('- **糖尿病患者**：HR 0.88 [1]。')
    expect(sections[2]?.markdown).toBe('- 人群异质性大。')
  })

  it('V3 识别标题形态与英文标签', () => {
    const sections = splitAnswerSections('## 结论\nA\n\n### Evidence\n- b')
    expect(sections).toEqual([
      { kind: 'conclusion', markdown: 'A' },
      { kind: 'evidence', markdown: '- b' },
    ])
  })

  it('V4 无标签正文整体归为 other', () => {
    const sections = splitAnswerSections('# Q: 问题\n\n正文 [1]')
    expect(sections).toEqual([
      { kind: 'other', markdown: '# Q: 问题\n\n正文 [1]' },
    ])
    expect(hasKnownSections(sections)).toBe(false)
  })

  it('问题标题里的关键词不构成分节头（前缀匹配）', () => {
    const md = '# Q: SGLT2 抑制剂在 HFpEF 的证据强度\n\n正文 [1]'
    expect(splitAnswerSections(md)).toEqual([{ kind: 'other', markdown: md }])
    expect(hasKnownSections(splitAnswerSections(md))).toBe(false)
  })

  it('V5 保留前言并合并重复分节', () => {
    const sections = splitAnswerSections(
      '前言\n\n**结论**\nA\n\n**证据**\n- x\n\n**证据**\n- y',
    )
    expect(sections).toEqual([
      { kind: 'other', markdown: '前言' },
      { kind: 'conclusion', markdown: 'A' },
      { kind: 'evidence', markdown: '- x\n\n- y' },
    ])
    expect(hasKnownSections(sections)).toBe(true)
  })

  it('V6 未识别的粗体行留在内容里', () => {
    const sections = splitAnswerSections(
      '**结论 / Bottom line**\nA\n\n**其他要点**\nB',
    )
    expect(sections).toEqual([
      { kind: 'conclusion', markdown: 'A\n\n**其他要点**\nB' },
    ])
  })

  it('V7 空输入返回空数组', () => {
    expect(splitAnswerSections('')).toEqual([])
    expect(splitAnswerSections('  \n\n')).toEqual([])
  })
})
