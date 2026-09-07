import { Navigate, Outlet, useLocation } from 'react-router'
import { useAuth } from './store'
import { ShieldAlert } from 'lucide-react'
import { BrandSplash } from '@/components/common/BrandSplash'
import { EmptyState } from '@/components/common/EmptyState'
export function RequireAuth({ admin = false }: { admin?: boolean }) {
  const { user, ready, isAdmin } = useAuth()
  const location = useLocation()
  if (!ready) return <BrandSplash label="正在验证会话" />
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
