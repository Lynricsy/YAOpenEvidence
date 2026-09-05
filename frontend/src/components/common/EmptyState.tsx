import { BookOpen, type LucideIcon } from 'lucide-react'
import type { ReactNode } from 'react'
export function EmptyState({
  icon: Icon = BookOpen,
  title,
  description,
  action,
}: {
  icon?: LucideIcon
  title: string
  description?: string
  action?: ReactNode
}) {
  return (
    <div className="empty-state">
      <span className="mb-4 grid size-10 place-items-center rounded-xl bg-muted">
        <Icon className="size-5 text-muted-foreground" strokeWidth={1.75} />
      </span>
      <h2 className="font-serif text-lg font-semibold">{title}</h2>
      {description && (
        <p className="mt-2 max-w-lg text-sm leading-7 text-muted-foreground">
          {description}
        </p>
      )}
      {action && <div className="mt-5">{action}</div>}
    </div>
  )
}
