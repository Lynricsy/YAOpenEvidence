import { useJob } from '@/api/queries'

/** 答案交付后才排队的写库任务；`unknown` 表示状态读不到，而不是没有任务。 */
export type KbBackground = {
  status:
    'queued' | 'running' | 'succeeded' | 'failed' | 'cancelled' | 'unknown'
  current: number
  total: number
}

/**
 * 后台写库任务的状态：ask 任务成功时才会在 `result.kb_job_id` 挂出子任务，
 * 所以要先读父任务再读它。两个查询在 `queued`/`running` 期间自轮询。
 */
export function useBackgroundKb(
  jobId: string | null | undefined,
  enabled: boolean,
): KbBackground | null {
  const parent = useJob(enabled ? jobId : null)
  const rawId = parent.data?.result?.kb_job_id
  const background = useJob(typeof rawId === 'string' ? rawId : null)
  if (!enabled) return null
  if (parent.isError || background.isError)
    return { status: 'unknown', current: 0, total: 0 }
  const job = background.data
  if (!job) return null
  return {
    status: job.status,
    current: job.progress?.current ?? 0,
    total: job.progress?.total ?? 0,
  }
}
