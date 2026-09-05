import { describe, expect, it } from 'vitest'
import { DEFAULT_FILTERS, toAnswerCreate, fromAnswerOptions, validYears } from './filters'
describe('筛选请求契约', () => {
  it('年份互斥且未启用分区时不发送未收录开关', () => {
    const recent = toAnswerCreate('q', DEFAULT_FILTERS)
    expect(recent).not.toHaveProperty('year_from'); expect(recent).not.toHaveProperty('year_to'); expect(recent).not.toHaveProperty('keep_unranked')
    const f = {...DEFAULT_FILTERS, yearMode:'range' as const, yearFrom:2020, yearTo:2024, quartiles:[1,2], keepUnranked:true, journals:['jama']}
    const range = toAnswerCreate('q', f)
    expect(range).not.toHaveProperty('years'); expect(range).not.toHaveProperty('use_paywall')
    expect(fromAnswerOptions(range)).toEqual(f)
  })
  it('阻止倒置和缺少起始年份的区间', () => {
    expect(validYears({...DEFAULT_FILTERS,yearMode:'range',yearFrom:2024,yearTo:2020})).toBe(false)
    expect(validYears({...DEFAULT_FILTERS,yearMode:'range'})).toBe(false)
    expect(validYears({...DEFAULT_FILTERS,yearMode:'range',yearFrom:2020})).toBe(true)
  })
})
