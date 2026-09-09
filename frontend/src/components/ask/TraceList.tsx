import { Check, Loader2, X } from 'lucide-react'
import type { ToolCall } from '@/lib/jobLive'
import {
  describeToolArgs,
  formatDuration,
  toolIcon,
  toolLabel,
} from '@/lib/tools'

/** 智能体的检索轨迹：实时（live）与落库两处共用同一行结构。 */
export function TraceList({ calls }: { calls: ToolCall[] }) {
  if (!calls.length) return null
  return (
    <ol className="space-y-1.5">
      {calls.map((call) => {
        const Icon = toolIcon(call.tool)
        const args = describeToolArgs(call.args)
        return (
          <li
            key={call.callId}
            className="grid grid-cols-[auto_1fr_auto] items-center gap-2.5"
          >
            <span className="grid size-6 place-items-center rounded-md bg-muted">
              <Icon className="size-3.5 text-muted-foreground" />
            </span>
            <span className="flex min-w-0 items-baseline gap-1.5">
              <span className="shrink-0 text-sm">
                {toolLabel(call.server, call.tool)}
              </span>
              {args && (
                <span className="truncate text-xs text-muted-foreground">
                  {args}
                </span>
              )}
            </span>
            {call.status === 'started' ? (
              <Loader2 className="size-3.5 animate-spin text-primary" />
            ) : call.status === 'completed' ? (
              <span className="flex items-center gap-1.5">
                <Check className="size-3.5 text-success" />
                <span className="font-mono text-[11px] tabular-nums text-muted-foreground">
                  {formatDuration(call.durationMs)}
                </span>
              </span>
            ) : (
              <span className="flex min-w-0 items-center gap-1.5">
                <X className="size-3.5 shrink-0 text-danger" />
                <span
                  className="max-w-40 truncate text-xs text-danger"
                  title={call.error ?? ''}
                >
                  {call.error ?? '失败'}
                </span>
              </span>
            )}
          </li>
        )
      })}
    </ol>
  )
}
