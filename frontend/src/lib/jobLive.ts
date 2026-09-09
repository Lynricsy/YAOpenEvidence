export type StageKey =
  | 'queries'
  | 'search'
  | 'fulltext'
  | 'read'
  | 'kb'
  | 'synthesize'
  | 'reindex'
  | 'agent'
export type CandidatePaper = {
  n: number
  pmid: string
  title: string
  year: string
  journal: string
  rank_label: string
  pmcid: string
}
export type ToolCall = {
  callId: string
  server: string
  tool: string
  status: 'started' | 'completed' | 'failed'
  args: Record<string, unknown>
  durationMs: number | null
  error: string | null
}
export type JobLive = {
  stages: Partial<
    Record<
      StageKey,
      { status: 'running' | 'finished'; detail: Record<string, unknown> }
    >
  >
  progress: {
    stage: StageKey
    current: number
    total: number
    title?: string | null
  } | null
  logs: { level: 'info' | 'warning'; message: string }[]
  tools: ToolCall[]
  search: {
    candidates: number
    kept: number
    dropped: Record<string, number>
    papers: CandidatePaper[]
  } | null
  terminal:
    | {
        kind: 'succeeded'
        answerId?: string
        items?: number
        papers?: number
        key?: string
      }
    | { kind: 'failed'; code: string; message: string }
    | { kind: 'cancelled' }
    | null
}
export const EMPTY_LIVE: JobLive = {
  stages: {},
  progress: null,
  logs: [],
  tools: [],
  search: null,
  terminal: null,
}
const stageKeys = new Set([
  'queries',
  'search',
  'fulltext',
  'read',
  'kb',
  'synthesize',
  'reindex',
  'agent',
])
const record = (v: unknown): Record<string, unknown> =>
  v && typeof v === 'object' && !Array.isArray(v)
    ? (v as Record<string, unknown>)
    : {}
const count = (v: unknown) =>
  typeof v === 'number' && Number.isFinite(v) ? v : 0
/** SSE 帧与 `Answer.trace` 的落库行是同一份 JSON 形状，解析只写一次。 */
export function toolCallOf(raw: unknown): ToolCall | null {
  const d = record(raw)
  if (typeof d.call_id !== 'string') return null
  return {
    callId: d.call_id,
    server: typeof d.server === 'string' ? d.server : '',
    tool: typeof d.tool === 'string' ? d.tool : '',
    status:
      d.status === 'started' || d.status === 'failed' ? d.status : 'completed',
    args: record(d.args),
    durationMs: typeof d.duration_ms === 'number' ? d.duration_ms : null,
    error: typeof d.error === 'string' ? d.error : null,
  }
}
export function applyEvent(
  state: JobLive,
  event: string,
  data: unknown,
): JobLive {
  const d = record(data)
  if (
    event === 'stage' &&
    typeof d.stage === 'string' &&
    stageKeys.has(d.stage) &&
    (d.status === 'started' || d.status === 'finished')
  ) {
    const stage = d.stage as StageKey
    const detail = record(d.detail)
    return {
      ...state,
      stages: {
        ...state.stages,
        [stage]: {
          status: d.status === 'started' ? 'running' : 'finished',
          detail,
        },
      },
      search:
        stage === 'search' && d.status === 'finished'
          ? {
              candidates: count(detail.candidates),
              kept: count(detail.kept),
              dropped: Object.fromEntries(
                Object.entries(record(detail.dropped)).map(([key, v]) => [
                  key,
                  count(v),
                ]),
              ),
              papers: Array.isArray(detail.papers)
                ? (detail.papers as CandidatePaper[])
                : [],
            }
          : state.search,
    }
  }
  if (
    event === 'progress' &&
    typeof d.stage === 'string' &&
    stageKeys.has(d.stage)
  )
    return {
      ...state,
      progress: {
        stage: d.stage as StageKey,
        current: count(d.current),
        total: count(d.total),
        title: typeof d.title === 'string' ? d.title : null,
      },
    }
  if (event === 'log' && typeof d.message === 'string')
    return {
      ...state,
      logs: [
        ...state.logs.slice(-199),
        {
          level: d.level === 'warning' ? 'warning' : 'info',
          message: d.message,
        },
      ],
    }
  if (event === 'tool') {
    const call = toolCallOf(d)
    if (!call) return state
    // 同一 call_id 先 started 后终态：就地替换，轨迹行不能翻倍
    const at = state.tools.findIndex((t) => t.callId === call.callId)
    return {
      ...state,
      tools:
        at === -1
          ? [...state.tools, call]
          : state.tools.map((t, i) => (i === at ? call : t)),
    }
  }
  if (event === 'succeeded')
    return {
      ...state,
      terminal: {
        kind: 'succeeded',
        ...(typeof d.answer_id === 'string' ? { answerId: d.answer_id } : {}),
        ...(typeof d.items === 'number' ? { items: d.items } : {}),
        ...(typeof d.papers === 'number' ? { papers: d.papers } : {}),
        ...(typeof d.key === 'string' ? { key: d.key } : {}),
      },
    }
  if (event === 'failed')
    return {
      ...state,
      terminal: {
        kind: 'failed',
        code: typeof d.code === 'string' ? d.code : 'internal_error',
        message: typeof d.message === 'string' ? d.message : '',
      },
    }
  if (event === 'cancelled')
    return { ...state, terminal: { kind: 'cancelled' } }
  return state
}
