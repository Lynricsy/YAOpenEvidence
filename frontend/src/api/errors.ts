type ValidationIssue = { loc: string[]; msg: string; type: string }
export class ApiError extends Error {
  status: number
  code: string
  detail: string
  errors?: ValidationIssue[]
  retryAfter?: number
  constructor(
    status: number,
    code: string,
    detail = '',
    errors?: ValidationIssue[],
    retryAfter?: number,
  ) {
    super(detail || code)
    this.name = 'ApiError'
    this.status = status
    this.code = code
    this.detail = detail
    this.errors = errors
    this.retryAfter = retryAfter
  }
}
export async function toApiError(response: Response): Promise<ApiError> {
  let problem: { code?: string; detail?: string; errors?: ValidationIssue[] } =
    {}
  try {
    problem = await response.json()
  } catch {
    /* 反向代理可能返回非 JSON 错误页。 */
  }
  const retry = Number(response.headers.get('Retry-After'))
  return new ApiError(
    response.status,
    problem.code ?? 'internal_error',
    problem.detail ?? '',
    problem.errors,
    Number.isFinite(retry) && retry > 0 ? retry : undefined,
  )
}
const messages: Record<string, string> = {
  unauthenticated: '登录已失效，请重新登录',
  forbidden: '需要管理员权限',
  not_found: '资源不存在或无权访问',
  not_ready: '答案尚未生成完成',
  conflict: '当前状态不允许该操作',
  username_exists: '用户名已存在',
  cannot_disable_self: '不能禁用自己',
  last_admin: '必须保留至少一个活跃管理员',
  too_many_jobs: '进行中的任务已达上限，请等待完成或先取消',
  unavailable: '服务暂不可用',
  fulltext_unavailable: '无可用全文',
}
export function problemMessage(error: unknown): string {
  if (!(error instanceof ApiError)) return '网络连接失败，请稍后重试'
  if (error.code === 'validation_error')
    return (
      '参数校验失败：' +
      (error.errors?.map((e) => e.msg).join('；') || error.detail)
    )
  if (error.code === 'login_rate_limited')
    return error.retryAfter
      ? '登录尝试过多，请 ' + error.retryAfter + ' 秒后再试'
      : '登录尝试过多，请稍后再试'
  if (error.code === 'upstream_unavailable')
    return '上游服务不可用：' + error.detail
  // 反向代理打不到 api 时返回的是 HTML 错误页，解析不出 code，会落到 internal_error。
  // 这类故障在网关层，不在后端代码里，必须与真正的 500 区分开，否则排查方向被带偏。
  if (error.status === 502 || error.status === 504)
    return '无法连接到后端服务（网关 ' + error.status + '），请确认 API 服务正在运行'
  if (error.status === 503) return '服务暂不可用，请稍后重试'
  return messages[error.code] ?? '服务器内部错误'
}
export function jobErrorMessage(code: string): string {
  return (
    (
      {
        no_papers:
          '没有文献通过筛选，请放宽年份 / 分区 / 期刊，或勾选「含未收录期刊」',
        nothing_relevant: '检索到的文献都与问题无关，请换个问法或放宽筛选',
        llm_unavailable: '模型服务不可用，请稍后重试',
        timeout: '任务超时',
        internal_error: '内部错误',
      } as Record<string, string>
    )[code] ?? '任务执行失败'
  )
}
