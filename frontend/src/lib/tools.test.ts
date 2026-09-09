import { describe, it, expect } from 'vitest'
import { describeToolArgs, formatDuration, toolLabel } from './tools'
describe('工具轨迹展示', () => {
  it('未登记的工具退回 server/tool 原文', () => {
    expect(toolLabel('semantic_scholar', 'read_pdf')).toBe('读取 PDF')
    expect(toolLabel('shell', 'whoami')).toBe('shell/whoami')
  })
  it('参数摘要按固定优先级取一个键，并追加 section', () => {
    expect(describeToolArgs({ path: 'x.pdf', query: 'sglt2' })).toBe(
      '「sglt2」',
    )
    expect(describeToolArgs({ pmids: '123', section: '方法' })).toBe(
      '「123」 · 方法',
    )
    expect(describeToolArgs({ limit: 5 })).toBe('')
  })
  it('过长的参数截断到 60 字符', () => {
    const long = 'a'.repeat(80)
    expect(describeToolArgs({ query: long })).toBe(`「${'a'.repeat(60)}…」`)
  })
  it('耗时统一一位小数', () => {
    expect(formatDuration(820)).toBe('0.8s')
    expect(formatDuration(12340)).toBe('12.3s')
    expect(formatDuration(null)).toBe('')
  })
})
