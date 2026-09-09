import { ChevronDown, Sparkles, Workflow, type LucideIcon } from 'lucide-react'
import { cn } from 'cn'
import type { Engine } from '@/lib/filters'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const ENGINES: {
  value: Engine
  label: string
  hint: string
  icon: LucideIcon
}[] = [
  {
    value: 'ask',
    label: '标准',
    hint: '固定流水线：检索 → 全文 → 逐篇阅读 → 综合，结论可逐条溯源',
    icon: Workflow,
  },
  {
    value: 'codex',
    label: '智能体',
    hint: 'Codex 自主决定检索路径，可多轮追问；不提供逐篇原文快照',
    icon: Sparkles,
  },
]

const triggerClass =
  'inline-flex h-7 shrink-0 items-center gap-1.5 rounded-md border px-2 text-xs text-muted-foreground'

export function EnginePicker({
  value,
  onChange,
  locked,
}: {
  value: Engine
  onChange: (engine: Engine) => void
  /** 追问态：引擎由会话决定，不能中途换。 */
  locked: boolean
}) {
  if (locked)
    return (
      <span className={triggerClass} title="追问会沿用本次会话的引擎">
        <Sparkles className="size-3.5 shrink-0" />
        智能体 · 续接对话
      </span>
    )
  const current = ENGINES.find((e) => e.value === value) ?? ENGINES[0]
  const Icon = current.icon
  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        className={cn(
          triggerClass,
          'transition-colors hover:bg-accent/60 hover:text-foreground',
        )}
        aria-label="选择引擎"
      >
        <Icon className="size-3.5 shrink-0" />
        {current.label}
        <ChevronDown className="size-3 shrink-0" />
      </DropdownMenuTrigger>
      <DropdownMenuContent align="start" className="max-w-80">
        <DropdownMenuRadioGroup
          value={value}
          onValueChange={(v) => onChange(v as Engine)}
        >
          {ENGINES.map((engine) => (
            <DropdownMenuRadioItem key={engine.value} value={engine.value}>
              <span className="flex min-w-0 flex-col gap-0.5">
                <span className="text-sm">{engine.label}</span>
                <span className="text-xs text-wrap text-muted-foreground">
                  {engine.hint}
                </span>
              </span>
            </DropdownMenuRadioItem>
          ))}
        </DropdownMenuRadioGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}

/** 只有智能体才挂徽标：标准引擎是默认值，标出来只是噪音。 */
export function EngineBadge({ engine }: { engine: Engine }) {
  if (engine !== 'codex') return null
  return (
    <span className="inline-flex items-center gap-1 rounded-md bg-primary/10 px-1.5 py-0.5 text-xs font-medium text-primary">
      <Sparkles className="size-3 shrink-0" />
      智能体
    </span>
  )
}
