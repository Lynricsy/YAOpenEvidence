import { describe, it, expect } from 'vitest'
import { EMPTY_LIVE, applyEvent } from './jobLive'
describe('任务事件状态', () => {
  it('从检索、进度过渡到成功并接受相同游标的合成终态', () => {
    let state = applyEvent(EMPTY_LIVE, 'stage', {
      stage: 'search',
      status: 'started',
    })
    state = applyEvent(state, 'progress', {
      stage: 'read',
      current: 2,
      total: 5,
    })
    state = applyEvent(state, 'stage', {
      stage: 'search',
      status: 'finished',
      detail: { candidates: 7, kept: 1, papers: [{ n: 1, title: 'A paper' }] },
    })
    state = applyEvent(state, 'succeeded', { answer_id: 'a' })
    expect(state.stages.search?.status).toBe('finished')
    expect(state.search?.papers).toEqual([{ n: 1, title: 'A paper' }])
    expect(state.progress).toMatchObject({ current: 2, total: 5 })
    expect(state.terminal).toEqual({ kind: 'succeeded', answerId: 'a' })
    expect(applyEvent(state, 'succeeded', { answer_id: 'a' }).terminal).toEqual(
      state.terminal,
    )
  })
  it('入库任务的成功事件带出 library key', () => {
    const state = applyEvent(EMPTY_LIVE, 'succeeded', {
      key: 'Smoke_Upload',
      n_paragraphs: 12,
      n_facts: 4,
      items: 16,
    })
    // items 与索引重建共用字段名，入库事件同样带上
    expect(state.terminal).toEqual({
      kind: 'succeeded',
      key: 'Smoke_Upload',
      items: 16,
    })
  })
  it('保留最近200条日志且忽略未知事件', () => {
    let state = EMPTY_LIVE
    for (let n = 0; n < 205; n++)
      state = applyEvent(state, 'log', { level: 'warning', message: String(n) })
    expect(state.logs[0].message).toBe('5')
    expect(state.logs.at(-1)?.message).toBe('204')
    expect(state.logs).toHaveLength(200)
    expect(applyEvent(state, 'unknown', {})).toBe(state)
  })
})
