import type { components } from '@/api/schema'

type User = components['schemas']['UserRead']
const listeners = new Set<() => void>()
let user: User | null = null
let token: string | null = null
try {
  const expires = Date.parse(localStorage.getItem('yaoe.token_expires_at') ?? '')
  if (expires > Date.now()) {
    token = localStorage.getItem('yaoe.token')
    user = JSON.parse(localStorage.getItem('yaoe.user') ?? 'null')
  }
} catch { /* 损坏或不可用的浏览器存储按未登录处理。 */ }
function notify() { listeners.forEach((listener) => listener()) }
export const authStore = {
  getToken: () => token,
  getUser: () => user,
  subscribe(listener: () => void) { listeners.add(listener); return () => { listeners.delete(listener) } },
  save(session: components['schemas']['LoginResponse']) {
    token = session.access_token
    user = session.user
    localStorage.setItem('yaoe.token', token)
    localStorage.setItem('yaoe.token_expires_at', session.expires_at)
    localStorage.setItem('yaoe.user', JSON.stringify(user))
    notify()
  },
  setUser(value: User) { user = value; localStorage.setItem('yaoe.user', JSON.stringify(value)); notify() },
  clear() {
    token = null; user = null
    for (const key of ['yaoe.token', 'yaoe.token_expires_at', 'yaoe.user']) localStorage.removeItem(key)
    notify()
  },
}
if (!token) authStore.clear()
window.addEventListener('storage', (event) => {
  if (event.key === 'yaoe.token' && event.newValue !== token) window.location.reload()
})
