import { AlertCircle, Ban, Check, Clock, Loader2 } from 'lucide-react'
import type { CSSProperties } from 'react'
import * as m from 'motion/react-m'
import { cn } from 'cn'
import { ease } from '@/lib/motion'
import type { RailNode, RailStatus } from './askRail'

const bullet: Record<RailStatus, string> = {
  todo: 'bg-background text-muted-foreground',
  waiting: 'border-primary/40 bg-background text-primary',
  running: 'border-primary bg-primary/10 text-primary',
  done: 'border-primary bg-primary text-primary-foreground',
  failed: 'border-danger bg-danger/10 text-danger',
  cancelled: 'bg-background text-muted-foreground',
}

function Glyph({ status, index }: { status: RailStatus; index: number }) {
  if (status === 'done')
    return (
      <m.span
        initial={{ scale: 0.4 }}
        animate={{ scale: 1 }}
        transition={{ type: 'spring', stiffness: 500, damping: 30 }}
      >
        <Check className="size-3.5" />
      </m.span>
    )
  if (status === 'running')
    return (
      <>
        <Loader2 className="size-3.5 animate-spin" />
        <m.span
          className="absolute inset-0 rounded-full border border-primary"
          animate={{ scale: [1, 1.7], opacity: [0.6, 0] }}
          transition={{ duration: 1.4, repeat: Infinity, ease: 'easeOut' }}
        />
      </>
    )
  if (status === 'waiting') return <Clock className="size-3.5" />
  if (status === 'failed') return <AlertCircle className="size-3.5" />
  if (status === 'cancelled') return <Ban className="size-3.5" />
  return <>{index + 1}</>
}

/** 阶段节点条：运行中的流水线与答案页的后台写库共用同一套视觉语言。 */
export function StageRail({
  nodes,
  progress,
  className,
}: {
  nodes: RailNode[]
  progress?: { title?: string | null; current: number; total: number } | null
  className?: string
}) {
  return (
    <div className={className}>
      <ol
        className="grid gap-4 md:grid-cols-[repeat(var(--n),minmax(0,1fr))] md:gap-0"
        style={{ '--n': nodes.length } as CSSProperties}
      >
        {nodes.map((node, index) => (
          <li
            key={node.key}
            className="relative flex gap-3 md:flex-col md:items-center md:text-center"
          >
            {index !== nodes.length - 1 && (
              <span
                className={cn(
                  'absolute top-7 left-3.5 h-[calc(100%+1rem-1.75rem)] w-px md:top-3.5 md:left-1/2 md:h-px md:w-full',
                  node.status === 'done' ? 'bg-primary' : 'bg-border',
                )}
              />
            )}
            <span
              className={cn(
                'relative z-1 grid size-7 shrink-0 place-items-center rounded-full border text-[11px] font-medium',
                bullet[node.status],
              )}
            >
              <Glyph status={node.status} index={index} />
            </span>
            <div className="min-w-0 md:mt-2">
              <p
                className={cn(
                  'text-xs',
                  node.status === 'todo'
                    ? 'text-muted-foreground'
                    : 'font-medium text-foreground',
                )}
              >
                {node.label}
              </p>
              {node.hint && (
                <p
                  role="status"
                  className="mt-0.5 text-[11px] break-words text-muted-foreground"
                >
                  {node.hint}
                </p>
              )}
            </div>
          </li>
        ))}
      </ol>
      {progress && (
        <div className="mt-5 space-y-1.5">
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
    </div>
  )
}
