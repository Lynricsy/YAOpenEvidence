import { AlertCircle, RotateCw } from 'lucide-react'
import { problemMessage } from '@/api/errors'
import { Button } from '@/components/ui/button'

export function QueryError({
  error,
  retry,
}: {
  error: unknown
  retry: () => unknown
}) {
  return (
    <div
      role="alert"
      className="error-panel flex flex-wrap items-center justify-between gap-3"
    >
      <span className="flex min-w-0 items-start gap-2.5">
        <AlertCircle className="mt-1 size-4 shrink-0 text-danger" />
        <span className="min-w-0 break-words">{problemMessage(error)}</span>
      </span>
      <Button variant="outline" size="sm" onClick={() => void retry()}>
        <RotateCw />
        重试
      </Button>
    </div>
  )
}
