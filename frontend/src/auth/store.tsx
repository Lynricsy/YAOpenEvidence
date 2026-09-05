import {
  createContext,
  useContext,
  useEffect,
  useState,
  useSyncExternalStore,
  type ReactNode,
} from 'react'
import { api, dataOf } from '@/api/client'
import { getMe, queryClient } from '@/api/queries'
import { problemMessage } from '@/api/errors'
import { authStore } from './session'
import { toast } from 'sonner'
import type { components } from '@/api/schema'

type Auth = {
  user: components['schemas']['UserRead'] | null
  isAdmin: boolean
  ready: boolean
  login: (username: string, password: string) => Promise<void>
  logout: () => Promise<void>
}
const Context = createContext<Auth | null>(null)
export function AuthProvider({ children }: { children: ReactNode }) {
  const user = useSyncExternalStore(authStore.subscribe, authStore.getUser)
  const [ready, setReady] = useState(!authStore.getToken())
  useEffect(() => {
    const controller = new AbortController()
    if (authStore.getToken())
      getMe(controller.signal)
        .then(authStore.setUser)
        .catch((error) => {
          if (!controller.signal.aborted) {
            toast.error(problemMessage(error))
            authStore.clear()
          }
        })
        .finally(() => {
          if (!controller.signal.aborted) setReady(true)
        })
    return () => controller.abort()
  }, [])
  useEffect(
    () =>
      authStore.subscribe(() => {
        if (!authStore.getToken()) queryClient.clear()
      }),
    [],
  )
  async function login(username: string, password: string) {
    const session = await dataOf(
      api.POST('/v1/auth/login', { body: { username, password } }),
    )
    queryClient.clear()
    authStore.save(session)
    setReady(true)
  }
  async function logout() {
    try {
      await api.POST('/v1/auth/logout')
    } catch {
      /* 无论注销请求是否成功，都移除本地会话。 */
    } finally {
      authStore.clear()
      queryClient.clear()
      window.location.assign('/login')
    }
  }
  return (
    <Context.Provider
      value={{ user, isAdmin: user?.role === 'admin', ready, login, logout }}
    >
      {children}
    </Context.Provider>
  )
}
export function useAuth() {
  const value = useContext(Context)
  if (!value) throw new Error('AuthProvider required')
  return value
}
