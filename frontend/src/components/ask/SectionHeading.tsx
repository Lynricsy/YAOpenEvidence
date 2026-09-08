import {
  BookOpen,
  CircleCheck,
  Database,
  FlaskConical,
  Table2,
  TriangleAlert,
  type LucideIcon,
} from 'lucide-react'
import type { ReactNode } from 'react'
import { cn } from 'cn'
import type { Tone } from '@/components/common/Pill'

export type AnswerModule =
  'conclusion' | 'evidence' | 'picos' | 'caveats' | 'sources' | 'kb'

/**
 * 答案页六个模块的固定展示元数据。标题不取模型写的标签字面量，保证
 * 中英混排、图标与语义色在三端一致。
 */
const MODULES: Record<
  AnswerModule,
  { title: string; eyebrow: string; icon: LucideIcon; tone: Tone }
> = {
  conclusion: {
    title: '结论',
    eyebrow: 'BOTTOM LINE',
    icon: CircleCheck,
    tone: 'primary',
  },
  evidence: {
    title: '证据',
    eyebrow: 'EVIDENCE',
    icon: FlaskConical,
    tone: 'primary',
  },
  picos: {
    title: 'PICOS 证据表',
    eyebrow: 'PICOS TABLE',
    icon: Table2,
    tone: 'primary',
  },
  caveats: {
    title: '局限',
    eyebrow: 'CAVEATS',
    icon: TriangleAlert,
    tone: 'warning',
  },
  sources: {
    title: '参考文献',
    eyebrow: 'REFERENCES',
    icon: BookOpen,
    tone: 'neutral',
  },
  kb: {
    title: '知识库补充',
    eyebrow: 'KNOWLEDGE BASE',
    icon: Database,
    tone: 'neutral',
  },
}

/**
 * 模块分节头：图标方块 + 中文标题 + 英文小字 + 右侧计数，可选下方分隔线。
 * 放进 `<button>`（可折叠模块的触发器）时必须传 `titleAs="span"`。
 */
export function SectionHeading({
  module,
  count,
  rule = true,
  trailing,
  titleAs: Title = 'h2',
  className,
}: {
  module: AnswerModule
  count?: ReactNode
  rule?: boolean
  trailing?: ReactNode
  titleAs?: 'h2' | 'span'
  className?: string
}) {
  const { title, eyebrow, icon: Icon, tone } = MODULES[module]
  return (
    <div
      className={cn(
        'flex items-center gap-2.5',
        rule && 'border-b pb-3',
        className,
      )}
    >
      <span
        data-tone={tone}
        className="tone-surface grid size-7 shrink-0 place-items-center rounded-md border"
      >
        <Icon className="size-[15px]" />
      </span>
      <Title className="font-serif text-[17px] font-semibold leading-none tracking-tight">
        {title}
      </Title>
      <span className="section-label mt-0.5">{eyebrow}</span>
      {count != null && (
        <span className="ml-auto text-xs tabular-nums text-muted-foreground">
          {count}
        </span>
      )}
      {trailing}
    </div>
  )
}
