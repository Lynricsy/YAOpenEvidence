import { Loader2 } from 'lucide-react'
import { Pill, type Tone } from './Pill'

const statuses: Record<string, [string, Tone]> = {
  queued: ['排队中', 'neutral'],
  running: ['进行中', 'info'],
  ready: ['已完成', 'success'],
  succeeded: ['已完成', 'success'],
  failed: ['失败', 'danger'],
  cancelled: ['已取消', 'warning'],
}

/** 任务状态对应的语义色，侧边栏「最近问答」的状态点复用。 */
export function statusTone(status: string): Tone {
  return statuses[status]?.[1] ?? 'neutral'
}

export function StatusBadge({ status }: { status: string }) {
  const [label, tone] = statuses[status] ?? [status, 'neutral' as Tone]
  return (
    <Pill tone={tone}>
      {status === 'running' && <Loader2 className="animate-spin" />}
      {label}
    </Pill>
  )
}
