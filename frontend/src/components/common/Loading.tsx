import type { ReactNode } from 'react'
import { Skeleton } from '@/components/ui/skeleton'

export function Loading({ children = '正在加载…' }: { children?: ReactNode }) {
  return (
    <div role="status" className="space-y-3 py-6">
      <span className="sr-only">{children}</span>
      <Skeleton className="h-4 w-2/3" />
      <Skeleton className="h-4 w-1/2" />
      <Skeleton className="h-24 w-full" />
    </div>
  )
}
