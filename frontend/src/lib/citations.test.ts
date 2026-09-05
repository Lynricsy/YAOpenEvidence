import { describe, expect, it } from 'vitest'
import { ANSWER_MD_LINK_RE, markersToLinks, parseCiteHref } from './citations'
describe('引用导航', () => {
  it('转换有效标记并保留越界数字和年份', () => {
    expect(markersToLinks('A[1¶12] B[2] C[9] D[2024]', 3)).toBe(
      'A[1¶12](#cite-1-12) B[2](#cite-2-) C[9] D[2024]',
    )
    expect(parseCiteHref('#cite-2-')).toEqual({ n: 2, pid: null })
    expect(
      ANSWER_MD_LINK_RE.exec('/v1/answers/x/papers/3/markdown#p7')?.slice(1),
    ).toEqual(['3', '7'])
  })
  it('不破坏已有链接与代码中的数字', () => {
    expect(markersToLinks('[1](https://example.com) \x60[2]\x60', 3)).toBe(
      '[1](https://example.com) \x60[2]\x60',
    )
    expect(parseCiteHref('#cite-0-1')).toBeNull()
    expect(parseCiteHref('https://example.com/#cite-2-')).toBeNull()
  })
})
