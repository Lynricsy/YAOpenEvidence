import { useMutation } from '@tanstack/react-query'
import { Check, Circle, Loader2, ChevronDown, Square } from 'lucide-react'
import { toast } from 'sonner'
import { cancelJob } from '@/api/queries'
import type { Connection } from '@/api/useJobEvents'
import type { JobLive, StageKey } from '@/lib/jobLive'
import { StatusBadge } from './StatusBadge'
import { Button } from './ui/button'
import {
  Collapsible,
  CollapsibleTrigger,
  CollapsibleContent,
} from './ui/collapsible'
const steps: [StageKey, string][] = [
  ['queries', '生成检索式'],
  ['search', '检索文献'],
  ['fulltext', '获取全文'],
  ['read', '逐篇阅读'],
  ['kb', '写入知识库'],
  ['synthesize', '综合成稿'],
]
function summary(stage: StageKey, detail: Record<string, unknown>) {
  if (stage === 'search') {
    const dropped = (detail.dropped ?? {}) as Record<string, number>
    return (
      '候选 ' +
      (detail.candidates ?? 0) +
      ' → 保留 ' +
      (detail.kept ?? 0) +
      '（年份 -' +
      (dropped.year ?? 0) +
      ' / 分区 -' +
      (dropped.quartile ?? 0) +
      ' / 未收录 -' +
      (dropped.unranked ?? 0) +
      ' / 期刊 -' +
      (dropped.journal ?? 0) +
      '）'
    )
  }
  if (stage === 'read')
    return '相关 ' + (detail.relevant ?? 0) + '/' + (detail.total ?? 0)
  const labels: Record<string, string> = {
    queries: '检索式',
    papers: '文献',
    items: '条目',
    total: '总计',
    fulltext: '全文',
    n_fulltext: '全文',
    chars: '字符',
    count: '数量',
    facts: '事实',
  }
  return Object.entries(detail)
    .filter(([, v]) => typeof v === 'number')
    .map(([k, v]) => (labels[k] ?? k) + ' ' + v)
    .join(' · ')
}
export function ProgressTimeline({
  live,
  connection,
  status,
  jobId,
  useKb,
}: {
  live: JobLive
  connection: Connection
  status: string
  jobId: string | null
  useKb: boolean
}) {
  const cancel = useMutation({
    mutationFn: cancelJob,
    onSuccess: () => toast.success('已请求取消，等待任务响应'),
  })
  return (
    <section className="py-7">
      <div className="mb-7 flex flex-wrap items-center gap-3">
        <StatusBadge status={status} />
        <span
          className={
            'text-xs ' +
            (connection === 'reconnecting'
              ? 'text-amber-600'
              : 'text-muted-foreground')
          }
        >
          {connection === 'reconnecting'
            ? '连接中断，正在重连…'
            : connection === 'open'
              ? '实时更新中'
              : connection === 'connecting'
                ? '正在连接…'
                : '同步任务状态'}
        </span>
        {jobId && (
          <Button
            className="ml-auto"
            variant="outline"
            size="sm"
            disabled={cancel.isPending || cancel.isSuccess}
            onClick={() => cancel.mutate(jobId)}
          >
            <Square className="size-3" />
            {cancel.isPending || cancel.isSuccess ? '取消中…' : '取消'}
          </Button>
        )}
      </div>
      <ol className="space-y-0">
        {steps
          .filter(([stage]) => stage !== 'kb' || useKb)
          .map(([stage, label], index, all) => {
            const state = live.stages[stage]
            const progress =
              live.progress?.stage === stage && state?.status !== 'finished'
                ? live.progress
                : null
            return (
              <li className="relative flex gap-4 pb-6" key={stage}>
                {index !== all.length - 1 && (
                  <span className="absolute top-6 left-3 h-[calc(100%-1.5rem)] border-l" />
                )}
                <span
                  className={
                    'relative z-1 grid size-6 shrink-0 place-items-center rounded-full ' +
                    (state?.status === 'finished'
                      ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300'
                      : state
                        ? 'bg-primary/10 text-primary'
                        : 'bg-muted text-muted-foreground')
                  }
                >
                  {state?.status === 'finished' ? (
                    <Check className="size-3.5" />
                  ) : state ? (
                    <Loader2 className="size-3.5 animate-spin" />
                  ) : (
                    <Circle className="size-2" />
                  )}
                </span>
                <div className="min-w-0 flex-1">
                  <p
                    className={
                      'text-sm ' +
                      (state ? 'font-medium' : 'text-muted-foreground')
                    }
                  >
                    {label}
                  </p>
                  {state?.status === 'finished' && (
                    <p className="mt-1 text-xs leading-6 text-muted-foreground">
                      {summary(stage, state.detail)}
                    </p>
                  )}
                  {progress && (
                    <div className="mt-2 space-y-2">
                      <div className="flex gap-3 text-xs text-muted-foreground">
                        <span className="min-w-0 flex-1 truncate">
                          {progress.title}
                        </span>
                        <span>
                          {progress.current}/{progress.total}
                        </span>
                      </div>
                      <progress
                        className="h-1.5 w-full accent-primary"
                        value={progress.current}
                        max={Math.max(1, progress.total)}
                      />
                    </div>
                  )}
                </div>
              </li>
            )
          })}
      </ol>
      <Collapsible className="border-t pt-4">
        <CollapsibleTrigger className="flex items-center gap-2 text-xs text-muted-foreground">
          <ChevronDown className="size-3" />
          运行日志 ({live.logs.length})
        </CollapsibleTrigger>
        <CollapsibleContent>
          <ul className="mt-3 max-h-60 space-y-1 overflow-y-auto rounded-md bg-muted p-3 font-mono text-xs leading-6">
            {live.logs.map((log, i) => (
              <li
                className={
                  log.level === 'warning'
                    ? 'text-amber-700 dark:text-amber-300'
                    : 'text-muted-foreground'
                }
                key={i}
              >
                {log.message}
              </li>
            ))}
          </ul>
        </CollapsibleContent>
      </Collapsible>
    </section>
  )
}
