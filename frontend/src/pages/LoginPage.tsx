import { useEffect, useState } from 'react'
import { Navigate, useNavigate, useSearchParams } from 'react-router'
import {
  ArrowRight,
  Loader2,
  Eye,
  EyeOff,
  ListChecks,
  Quote,
  Database,
} from 'lucide-react'
import * as m from 'motion/react-m'
import { toast } from 'sonner'
import { useAuth } from '@/auth/store'
import { ApiError, problemMessage } from '@/api/errors'
import { BrandLogo } from '@/components/common/BrandLogo'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { fadeUp } from '@/lib/motion'
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
    <div className="grid min-h-dvh lg:grid-cols-[1.1fr_1fr]">
      <div className="hidden lg:flex flex-col justify-between border-r bg-sidebar p-12">
        <div className="flex items-center gap-2.5">
          <BrandLogo size={32} />
          <span className="font-serif text-lg font-semibold tracking-tight">
            YAOpenEvidence
          </span>
        </div>
        <m.div variants={fadeUp} initial="hidden" animate="show">
          <h1 className="font-serif text-[34px] font-semibold leading-tight tracking-tight">
            让每一条结论，
            <br />
            都能回到原文。
          </h1>
          <p className="mt-5 max-w-md text-[15px] leading-7 text-muted-foreground">
            YAOpenEvidence 从 PubMed / Europe PMC
            检索并逐篇核实，生成带段落级引用定位的循证综述。
          </p>
          <ul className="mt-8 space-y-3 text-sm">
            <li className="flex items-center gap-2.5">
              <ListChecks className="size-4 text-primary" />
              逐篇核实每一条引文
            </li>
            <li className="flex items-center gap-2.5">
              <Quote className="size-4 text-primary" />
              段落级溯源，点击即达原文
            </li>
            <li className="flex items-center gap-2.5">
              <Database className="size-4 text-primary" />
              证据沉淀为本地知识库
            </li>
          </ul>
        </m.div>
        <p className="text-xs text-muted-foreground">
          仅供科研与教学参考，不构成医疗建议
        </p>
      </div>
      <div className="flex items-center justify-center px-6 py-12">
        <m.div
          variants={fadeUp}
          initial="hidden"
          animate="show"
          className="w-full max-w-sm"
        >
          <div className="mb-8 flex items-center gap-2.5 lg:hidden">
            <BrandLogo size={32} />
            <span className="font-serif text-base font-semibold tracking-tight">
              YAOpenEvidence
            </span>
          </div>
          <p className="section-label">循证医学文献问答</p>
          <h2 className="mt-2 mb-8 font-serif text-2xl font-semibold">
            登录工作台
          </h2>
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
                className="h-10"
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
                  className="h-10 pr-11"
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
              className="mt-2 h-10 w-full"
              disabled={pending || wait > 0 || !username.trim() || !password}
            >
              {pending ? <Loader2 className="animate-spin" /> : null}
              {wait ? wait + ' 秒后重试' : '登录'}
              {!pending && <ArrowRight className="ml-auto" />}
            </Button>
          </form>
          <p className="mt-8 text-center text-xs text-muted-foreground lg:hidden">
            仅供科研与教学参考，不构成医疗建议
          </p>
        </m.div>
      </div>
    </div>
  )
}
