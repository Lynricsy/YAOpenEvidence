import { Navigate, Outlet, useLocation } from 'react-router'
import { useAuth } from './store'
import { Loader2, ShieldAlert } from 'lucide-react'
import { EmptyState } from '@/components/EmptyState'
export function RequireAuth({ admin = false }: { admin?: boolean }) {
  const { user, ready, isAdmin } = useAuth()
  const location = useLocation()
  if (!ready)
    return (
      <div className="grid min-h-screen place-items-center">
        <Loader2 className="animate-spin" aria-label="正在验证会话" />
      </div>
    )
  if (!user)
    return (
      <Navigate
        to={
          '/login?next=' +
          encodeURIComponent(location.pathname + location.search)
        }
        replace
      />
    )
  if (admin && !isAdmin)
    return (
      <div role="alert">
        <EmptyState icon={ShieldAlert} title="需要管理员权限" />
      </div>
    )
  return <Outlet />
}
