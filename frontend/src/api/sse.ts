import { createParser } from 'eventsource-parser'
import { authStore } from '@/auth/session'
import { toApiError } from './errors'
import { expireSession } from './client'
export async function readJobEvents({ jobId, cursor, signal, onEvent, onOpen }: { jobId: string; cursor: { id?: string }; signal: AbortSignal; onEvent: (event: string, data: unknown) => void; onOpen?: () => void }) {
  const response = await fetch('/v1/jobs/' + encodeURIComponent(jobId) + '/events', { headers: { Authorization: 'Bearer ' + authStore.getToken(), 'Last-Event-ID': cursor.id ?? '0-0' }, signal })
  if (!response.ok) { if (response.status === 401) expireSession(); throw await toApiError(response) }
  if (!response.body) throw new Error('Event stream body unavailable')
  onOpen?.()
  const parser = createParser({ onEvent(event) { onEvent(event.event || 'message', JSON.parse(event.data)); if (event.id !== undefined) cursor.id = event.id }, onError(error) { throw error } })
  const reader = response.body.getReader()
  const decoder = new TextDecoder()
  try { while (true) { const { value, done } = await reader.read(); if (done) { parser.feed(decoder.decode()); break }; parser.feed(decoder.decode(value, { stream: true })) } }
  finally { await reader.cancel().catch(() => {}); reader.releaseLock() }
}
