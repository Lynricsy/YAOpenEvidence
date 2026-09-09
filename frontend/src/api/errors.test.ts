import { describe, it, expect } from 'vitest'
import { ApiError, jobErrorMessage, problemMessage, toApiError } from './errors'

describe('错误文案', () => {
  it('把网关故障与后端 500 区分开', () => {
    // nginx 打不到 api 时返回 HTML 错误页，code 落成 internal_error；
    // 若也说成「服务器内部错误」，排查会被带向后端代码而不是网关。
    expect(problemMessage(new ApiError(502, 'internal_error'))).toContain(
      '无法连接到后端服务',
    )
    expect(problemMessage(new ApiError(504, 'internal_error'))).toContain(
      '无法连接到后端服务',
    )
    expect(problemMessage(new ApiError(500, 'internal_error'))).toBe(
      '服务器内部错误',
    )
  })

  it('结构化 problem 的 code 优先于状态码', () => {
    expect(problemMessage(new ApiError(401, 'unauthenticated'))).toBe(
      '登录已失效，请重新登录',
    )
    expect(
      problemMessage(new ApiError(503, 'upstream_unavailable', 'PubMed 超时')),
    ).toBe('上游服务不可用：PubMed 超时')
  })

  it('非 JSON 错误页仍产出带状态码的 ApiError', async () => {
    const html = new Response('<html><body>502 Bad Gateway</body></html>', {
      status: 502,
      headers: { 'Content-Type': 'text/html' },
    })
    const error = await toApiError(html)
    expect(error.status).toBe(502)
    expect(error.code).toBe('internal_error')
    expect(problemMessage(error)).toContain('无法连接到后端服务')
  })

  it('智能体特有的失败有自己的说法', () => {
    expect(jobErrorMessage('codex_failed')).toBe(
      '智能体本轮执行失败，请重试或改用标准引擎',
    )
    expect(problemMessage(new ApiError(409, 'thread_busy'))).toBe(
      '上一轮还在进行中，稍后再追问',
    )
  })
})
