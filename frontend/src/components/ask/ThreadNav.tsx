import { Link } from 'react-router'
import { cn } from 'cn'
import type { components } from '@/api/schema'
import { StatusBadge } from '@/components/common/StatusBadge'

/** 一条智能体会话的全部回合：追问把上下文摊平在页面上，不用回历史里翻。 */
export function ThreadNav({
  turns,
  currentId,
}: {
  turns: components['schemas']['AnswerSummary'][]
  currentId: string
}) {
  const at = turns.findIndex((t) => t.id === currentId)
  return (
    <nav
      aria-label="对话脉络"
      className="mt-4 rounded-lg border bg-muted/40 p-3"
    >
      <p className="text-xs text-muted-foreground">
        对话脉络 · 第 {at + 1}/{turns.length} 轮
      </p>
      <ol className="mt-2 space-y-1">
        {turns.map((turn, i) => {
          const current = turn.id === currentId
          return (
            <li key={turn.id}>
              <Link
                to={`/a/${turn.id}`}
                aria-current={current ? 'page' : undefined}
                className={cn(
                  'flex items-center gap-2 text-sm transition-colors',
                  current
                    ? 'font-medium text-foreground'
                    : 'text-muted-foreground hover:text-foreground',
                )}
              >
                <span className="grid size-5 shrink-0 place-items-center rounded-full border text-[11px] tabular-nums">
                  {i + 1}
                </span>
                <span className="line-clamp-1">{turn.question}</span>
                {turn.status !== 'ready' && (
                  <StatusBadge status={turn.status} />
                )}
              </Link>
            </li>
          )
        })}
      </ol>
    </nav>
  )
}
