import { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { KeyRound, Loader2, LogOut, Monitor, Moon, Sun } from 'lucide-react'
import { toast } from 'sonner'
import { changePassword } from '@/api/queries'
import { useAuth } from '@/auth/store'
import { useTheme } from '@/lib/theme'
import { Loading } from '@/components/common/Loading'
import { PageHeader } from '@/components/common/PageHeader'
import { Pill } from '@/components/common/Pill'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'

export default function AccountPage() {
  const { user, ready, logout } = useAuth()
  const { theme, setTheme } = useTheme()
  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmation, setConfirmation] = useState('')
  const [loggingOut, setLoggingOut] = useState(false)
  const passwordValid = newPassword.length >= 12 && newPassword.length <= 128
  const matches = confirmation === newPassword
  const passwordChange = useMutation({
    gcTime: 0,
    mutationFn: () =>
      changePassword({
        current_password: currentPassword,
        new_password: newPassword,
      }),
    onSuccess: async () => {
      setCurrentPassword('')
      setNewPassword('')
      setConfirmation('')
      toast.success('密码已修改，请重新登录')
      await logout()
    },
  })
  const busy = passwordChange.isPending || loggingOut

  if (!ready || !user)
    return (
      <div className="h-full overflow-y-auto">
        <div className="page">
          <Loading>正在加载账号…</Loading>
        </div>
      </div>
    )

  return (
    <div className="h-full overflow-y-auto">
      <div className="page max-w-3xl">
        <PageHeader title="账号设置" />
        <div className="space-y-6">
          <section
            className="rounded-xl border bg-card p-6"
            aria-labelledby="account-heading"
          >
            <h2
              id="account-heading"
              className="mb-5 font-serif text-lg font-semibold"
            >
              账号
            </h2>
            <dl className="grid grid-cols-[auto_minmax(0,1fr)] items-start gap-x-8 gap-y-4 text-sm">
              <dt className="section-label">用户名</dt>
              <dd className="break-all">{user.username}</dd>
              <dt className="section-label">角色</dt>
              <dd>
                <Pill tone={user.role === 'admin' ? 'primary' : 'neutral'}>
                  {user.role === 'admin' ? '管理员' : '普通用户'}
                </Pill>
              </dd>
            </dl>
          </section>
          <section
            className="rounded-xl border bg-card p-6"
            aria-labelledby="password-heading"
          >
            <h2
              id="password-heading"
              className="mb-5 font-serif text-lg font-semibold"
            >
              修改密码
            </h2>
            <form
              className="max-w-md space-y-5"
              onSubmit={(event) => {
                event.preventDefault()
                if (busy || !currentPassword || !passwordValid || !matches)
                  return
                passwordChange.mutate()
              }}
            >
              <div className="space-y-2">
                <Label htmlFor="current-password">当前密码</Label>
                <Input
                  id="current-password"
                  className="h-10"
                  type="password"
                  autoComplete="current-password"
                  required
                  maxLength={128}
                  disabled={busy}
                  value={currentPassword}
                  onChange={(event) => setCurrentPassword(event.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="new-password">新密码</Label>
                <Input
                  id="new-password"
                  className="h-10"
                  type="password"
                  autoComplete="new-password"
                  required
                  minLength={12}
                  maxLength={128}
                  disabled={busy}
                  value={newPassword}
                  aria-invalid={!!newPassword && !passwordValid}
                  aria-describedby="new-password-hint"
                  onChange={(event) => setNewPassword(event.target.value)}
                />
                <p
                  id="new-password-hint"
                  className={
                    newPassword && !passwordValid
                      ? 'text-xs text-danger'
                      : 'text-xs text-muted-foreground'
                  }
                >
                  密码须为 12–128 个字符
                </p>
              </div>
              <div className="space-y-2">
                <Label htmlFor="confirm-password">确认新密码</Label>
                <Input
                  id="confirm-password"
                  className="h-10"
                  type="password"
                  autoComplete="new-password"
                  required
                  minLength={12}
                  maxLength={128}
                  disabled={busy}
                  value={confirmation}
                  aria-invalid={!!confirmation && !matches}
                  aria-describedby={
                    confirmation && !matches
                      ? 'confirm-password-error'
                      : undefined
                  }
                  onChange={(event) => setConfirmation(event.target.value)}
                />
                {confirmation && !matches && (
                  <p
                    id="confirm-password-error"
                    className="text-xs text-danger"
                  >
                    两次输入的新密码不一致
                  </p>
                )}
              </div>
              <Button
                type="submit"
                disabled={
                  busy ||
                  !currentPassword ||
                  !passwordValid ||
                  !confirmation ||
                  !matches
                }
              >
                {passwordChange.isPending ? (
                  <Loader2 className="animate-spin" />
                ) : (
                  <KeyRound />
                )}
                {passwordChange.isPending ? '正在修改…' : '修改密码'}
              </Button>
            </form>
          </section>
          <section
            className="rounded-xl border bg-card p-6"
            aria-labelledby="appearance-heading"
          >
            <h2
              id="appearance-heading"
              className="mb-5 font-serif text-lg font-semibold"
            >
              外观
            </h2>
            <ToggleGroup
              type="single"
              value={theme}
              aria-label="外观主题"
              spacing={1}
              className="flex gap-1.5"
              onValueChange={(value) => {
                if (value === 'system' || value === 'light' || value === 'dark')
                  setTheme(value)
              }}
            >
              <ToggleGroupItem className="chip" value="system">
                <Monitor className="size-3.5" />
                跟随系统
              </ToggleGroupItem>
              <ToggleGroupItem className="chip" value="light">
                <Sun className="size-3.5" />
                浅色
              </ToggleGroupItem>
              <ToggleGroupItem className="chip" value="dark">
                <Moon className="size-3.5" />
                深色
              </ToggleGroupItem>
            </ToggleGroup>
          </section>
          <div className="pt-2">
            <Button
              variant="outline"
              disabled={busy}
              onClick={async () => {
                setLoggingOut(true)
                try {
                  await logout()
                } finally {
                  setLoggingOut(false)
                }
              }}
            >
              {loggingOut ? <Loader2 className="animate-spin" /> : <LogOut />}
              {loggingOut ? '正在退出…' : '退出登录'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
