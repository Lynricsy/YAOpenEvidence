import { useEffect, useState } from 'react'
import { applyEvent, EMPTY_LIVE, type JobLive } from '@/lib/jobLive'
import { authStore } from '@/auth/session'
import { getMe, queryClient } from './queries'
import { readJobEvents } from './sse'
import { ApiError } from './errors'
export type Connection =
  'idle' | 'connecting' | 'open' | 'reconnecting' | 'closed'
export function useJobEvents(
  jobId: string | null | undefined,
  enabled: boolean,
): { live: JobLive; connection: Connection } {
  const [state, setState] = useState<{
    id?: string | null
    live: JobLive
    connection: Connection
  }>({ live: EMPTY_LIVE, connection: 'idle' })
  useEffect(() => {
    if (!jobId || !enabled) return
    const controller = new AbortController()
    const cursor: { id?: string } = {}
    let live = EMPTY_LIVE
    let delay = 1000
    let started = false
    const update = (connection: Connection) => {
      if (!controller.signal.aborted) setState({ id: jobId, live, connection })
    }
    const wait = () =>
      new Promise<void>((resolve) => {
        const finish = () => {
          clearTimeout(timer)
          controller.signal.removeEventListener('abort', finish)
          resolve()
        }
        const timer = setTimeout(finish, delay)
        controller.signal.addEventListener('abort', finish, { once: true })
      })
    const connect = async () => {
      update('connecting')
      while (!controller.signal.aborted && authStore.getToken()) {
        try {
          await readJobEvents({
            jobId,
            cursor,
            signal: controller.signal,
            onOpen: () => update('open'),
            onEvent(event, data) {
              live = applyEvent(live, event, data)
              update('open')
              if (event === 'stage' && !started) {
                started = true
                void queryClient.invalidateQueries({ queryKey: ['answer'] })
              }
              if (live.terminal) {
                void queryClient.invalidateQueries({ queryKey: ['answer'] })
                void queryClient.invalidateQueries({ queryKey: ['answers'] })
                void queryClient.invalidateQueries({ queryKey: ['job', jobId] })
                if (live.terminal.kind === 'succeeded') {
                  void queryClient.invalidateQueries({ queryKey: ['papers'] })
                  void queryClient.invalidateQueries({ queryKey: ['kbStats'] })
                }
              }
            },
          })
        } catch (error) {
          if (controller.signal.aborted) return
          if (
            error instanceof ApiError &&
            [401, 403, 404, 422].includes(error.status)
          ) {
            update('closed')
            return
          }
        }
        if (controller.signal.aborted) return
        if (live.terminal) {
          update('closed')
          return
        }
        update('reconnecting')
        try {
          await getMe(controller.signal)
        } catch (error) {
          if (controller.signal.aborted) return
          if (error instanceof ApiError && error.status === 401) {
            update('closed')
            return
          }
        }
        await wait()
        delay = Math.min(delay * 2, 10000)
      }
    }
    void connect()
    return () => controller.abort()
  }, [jobId, enabled])
  return state.id === jobId
    ? {
        live: state.live,
        connection: enabled
          ? state.connection
          : state.live.terminal
            ? 'closed'
            : 'idle',
      }
    : { live: EMPTY_LIVE, connection: 'idle' }
}
