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
      <Icon className="mb-4 size-8 text-primary" strokeWidth={1.5} />
      <h2 className="text-lg font-semibold">{title}</h2>
      {description && (
        <p className="mt-2 max-w-lg text-sm leading-7 text-muted-foreground">
          {description}
        </p>
      )}
      {action && <div className="mt-5">{action}</div>}
    </div>
  )
}
