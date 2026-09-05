import { useEffect, useState } from 'react'
import { Navigate, useNavigate, useSearchParams } from 'react-router'
import { BookOpenCheck, ArrowRight, Loader2, Eye, EyeOff } from 'lucide-react'
import { toast } from 'sonner'
import { useAuth } from '@/auth/store'
import { ApiError, problemMessage } from '@/api/errors'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
export default function LoginPage() {
  const { login, user, ready } = useAuth()
  const [params] = useSearchParams()
  const navigate = useNavigate()
  const rawNext = params.get('next') ?? '/'
  const next =
    rawNext.startsWith('/') &&
    !rawNext.startsWith('//') &&
    !rawNext.includes('\\') &&
    !rawNext.startsWith('/login')
      ? rawNext
      : '/'
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [show, setShow] = useState(false)
  const [pending, setPending] = useState(false)
  const [wait, setWait] = useState(0)
  useEffect(() => {
    if (!wait) return
    const id = setTimeout(() => setWait((v) => Math.max(0, v - 1)), 1000)
    return () => clearTimeout(id)
  }, [wait])
  if (ready && user) return <Navigate to={next} replace />
  return (
    <div className="login-page">
      <div className="login-wordmark">
        <BookOpenCheck className="size-8 text-primary" strokeWidth={1.5} />
        <span>YAOpenEvidence</span>
      </div>
      <section className="login-panel">
        <p className="section-eyebrow">循证医学文献问答</p>
        <h1 className="mb-8 mt-3 text-2xl font-semibold">登录工作台</h1>
        <form
          className="space-y-5"
          onSubmit={async (e) => {
            e.preventDefault()
            if (pending || wait) return
            setPending(true)
            try {
              await login(username.trim(), password)
              navigate(next, { replace: true })
            } catch (error) {
              toast.error(
                error instanceof ApiError && error.code === 'unauthenticated'
                  ? '用户名或密码错误'
                  : problemMessage(error),
              )
              if (
                error instanceof ApiError &&
                error.code === 'login_rate_limited'
              )
                setWait(error.retryAfter ?? 60)
            } finally {
              setPending(false)
            }
          }}
        >
          <div className="space-y-2">
            <Label htmlFor="username">用户名</Label>
            <Input
              id="username"
              autoComplete="username"
              autoFocus
              required
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">密码</Label>
            <div className="relative">
              <Input
                id="password"
                type={show ? 'text' : 'password'}
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="pr-11"
              />
              <Button
                type="button"
                variant="ghost"
                size="icon-sm"
                className="absolute top-0.5 right-1"
                aria-label={show ? '隐藏密码' : '显示密码'}
                onClick={() => setShow(!show)}
              >
                {show ? <EyeOff /> : <Eye />}
              </Button>
            </div>
          </div>
          <Button
            className="mt-2 h-11 w-full"
            disabled={pending || wait > 0 || !username.trim() || !password}
          >
            {pending ? <Loader2 className="animate-spin" /> : null}
            {wait ? wait + ' 秒后重试' : '登录'}
            {!pending && <ArrowRight className="ml-auto" />}
          </Button>
        </form>
      </section>
      <p className="mt-8 text-xs text-muted-foreground">
        仅供科研与教学参考，不构成医疗建议
      </p>
    </div>
  )
}
