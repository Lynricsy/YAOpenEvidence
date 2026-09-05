import { Skeleton } from '@/components/ui/skeleton'

export function PageSkeleton() {
  return (
    <div role="status" className="page space-y-4">
      <span className="sr-only">正在加载…</span>
      <Skeleton className="h-8 w-1/3" />
      <Skeleton className="h-4 w-1/2" />
      <Skeleton className="h-40 w-full" />
    </div>
  )
}
