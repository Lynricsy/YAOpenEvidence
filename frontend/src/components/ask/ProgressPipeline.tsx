import { useEffect, useRef, type CSSProperties } from 'react'
import { useMutation } from '@tanstack/react-query'
import { Check, ChevronDown, Loader2, Square } from 'lucide-react'
import * as m from 'motion/react-m'
import { toast } from 'sonner'
import { cn } from 'cn'
import { cancelJob } from '@/api/queries'
import type { Connection } from '@/api/useJobEvents'
import type { JobLive, StageKey } from '@/lib/jobLive'
import { ease } from '@/lib/motion'
import { Button } from '@/components/ui/button'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'

const steps: [StageKey, string][] = [
  ['queries', '生成检索式'],
  ['search', '检索文献'],
  ['fulltext', '获取全文'],
  ['read', '逐篇阅读'],
  ['kb', '写入知识库'],
  ['synthesize', '综合成稿'],
]
// codex 一轮对话内部没有固定步骤，只有一个 agent 阶段，工具调用走日志
const codexSteps: [StageKey, string][] = [['agent', 'Codex 检索与作答']]

const connections: Record<Connection, [string, string]> = {
  idle: ['同步任务状态', 'bg-muted-foreground'],
  open: ['实时更新中', 'bg-success'],
  connecting: ['正在连接…', 'bg-muted-foreground animate-pulse'],
  reconnecting: ['连接中断，正在重连…', 'bg-warning'],
  closed: ['同步任务状态', 'bg-muted-foreground'],
}

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

export function ProgressPipeline({
  live,
  connection,
  jobId,
  useKb,
  engine,
}: {
  live: JobLive
  connection: Connection
  jobId: string | null
  useKb: boolean
  engine: 'ask' | 'codex'
}) {
  const cancel = useMutation({
    mutationFn: cancelJob,
    onSuccess: () => toast.success('已请求取消，等待任务响应'),
  })
  const logRef = useRef<HTMLUListElement>(null)
  useEffect(() => {
    const el = logRef.current
    if (el) el.scrollTop = el.scrollHeight
  }, [live.logs.length])
  const visible =
    engine === 'codex'
      ? codexSteps
      : steps.filter(([stage]) => stage !== 'kb' || useKb)
  const [connectionLabel, dotClass] = connections[connection]
  const finished = visible.filter(
    ([stage]) => live.stages[stage]?.status === 'finished',
  )
  const progress =
    live.progress && live.stages[live.progress.stage]?.status !== 'finished'
      ? live.progress
      : null
  return (
    <section className="rounded-xl border bg-card p-5 md:p-6">
      <div className="flex flex-wrap items-center gap-3">
        <p className="text-sm font-medium">证据流水线</p>
        <span
          className={cn(
            'inline-flex items-center gap-1.5 text-xs',
            connection === 'reconnecting'
              ? 'text-warning'
              : 'text-muted-foreground',
          )}
        >
          <span className={cn('size-1.5 rounded-full', dotClass)} />
          {connectionLabel}
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
      <ol
        className="mt-6 grid gap-4 md:grid-cols-[repeat(var(--n),minmax(0,1fr))] md:gap-0"
        style={{ '--n': visible.length } as CSSProperties}
      >
        {visible.map(([stage, label], index) => {
          const state = live.stages[stage]
          const done = state?.status === 'finished'
          return (
            <li
              key={stage}
              className="relative flex gap-3 md:flex-col md:items-center md:text-center"
            >
              {index !== visible.length - 1 && (
                <span
                  className={cn(
                    'absolute top-7 left-3.5 h-[calc(100%+1rem-1.75rem)] w-px md:top-3.5 md:left-1/2 md:h-px md:w-full',
                    done ? 'bg-primary' : 'bg-border',
                  )}
                />
              )}
              <span
                className={cn(
                  'relative z-1 grid size-7 shrink-0 place-items-center rounded-full border text-[11px] font-medium',
                  done
                    ? 'border-primary bg-primary text-primary-foreground'
                    : state
                      ? 'border-primary bg-primary/10 text-primary'
                      : 'bg-background text-muted-foreground',
                )}
              >
                {done ? (
                  <m.span
                    initial={{ scale: 0.4 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                  >
                    <Check className="size-3.5" />
                  </m.span>
                ) : state ? (
                  <>
                    <Loader2 className="size-3.5 animate-spin" />
                    <m.span
                      className="absolute inset-0 rounded-full border border-primary"
                      animate={{ scale: [1, 1.7], opacity: [0.6, 0] }}
                      transition={{
                        duration: 1.4,
                        repeat: Infinity,
                        ease: 'easeOut',
                      }}
                    />
                  </>
                ) : (
                  index + 1
                )}
              </span>
              <p
                className={cn(
                  'text-xs md:mt-2',
                  state
                    ? 'font-medium text-foreground'
                    : 'text-muted-foreground',
                )}
              >
                {label}
              </p>
            </li>
          )
        })}
      </ol>
      <div className="mt-5 space-y-3">
        {progress && (
          <div className="space-y-1.5">
            <div className="flex justify-between gap-3 text-xs text-muted-foreground">
              <span className="truncate">{progress.title}</span>
              <span className="tabular-nums">
                {progress.current}/{progress.total}
              </span>
            </div>
            <div className="h-1.5 overflow-hidden rounded-full bg-muted">
              <m.div
                className="h-full rounded-full bg-primary"
                animate={{
                  width:
                    (progress.total > 0
                      ? (progress.current / progress.total) * 100
                      : 0) + '%',
                }}
                transition={{ duration: 0.4, ease }}
              />
            </div>
          </div>
        )}
        {finished.length > 0 && (
          <ul className="space-y-1 text-xs text-muted-foreground">
            {finished.map(([stage, label]) => (
              <li key={stage} className="flex items-start gap-1.5">
                <Check className="mt-1 size-3 shrink-0 text-success" />
                <span className="min-w-0 break-words">
                  {label}：{summary(stage, live.stages[stage]?.detail ?? {})}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>
      <Collapsible className="mt-5 border-t pt-3">
        <CollapsibleTrigger className="flex items-center gap-1 text-xs text-muted-foreground transition-colors hover:text-foreground [&>svg]:transition-transform [&[data-state=open]>svg]:rotate-180">
          <ChevronDown className="size-3.5" />
          运行日志（{live.logs.length}）
        </CollapsibleTrigger>
        <CollapsibleContent>
          <ul
            ref={logRef}
            className="mt-2 max-h-56 space-y-0.5 overflow-y-auto rounded-md bg-muted/60 p-3 font-mono text-[11.5px] leading-5"
          >
            {live.logs.map((log, i) => (
              <li
                key={i}
                className={
                  log.level === 'warning'
                    ? 'text-warning'
                    : 'text-muted-foreground'
                }
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
