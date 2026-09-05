import { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { KeyRound, Loader2, RefreshCw, UserPlus, Users } from 'lucide-react'
import { toast } from 'sonner'
import type { components } from '@/api/schema'
import { createUser, resetUserPassword, updateUser, useUsers } from '@/api/queries'
import { problemMessage } from '@/api/errors'
import { useAuth } from '@/auth/store'
import { EmptyState } from '@/components/EmptyState'
import { Pagination } from '@/components/Pagination'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'

type User = components['schemas']['UserRead']

function CreateUserDialog({ onClose }: { onClose: () => void }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [role, setRole] = useState<User['role']>('user')
  const usernameValid = /^[A-Za-z0-9][A-Za-z0-9_.-]{2,63}$/.test(username)
  const passwordValid = password.length >= 12 && password.length <= 128
  const create = useMutation({
    gcTime: 0,
    mutationFn: () => createUser({ username, password, role }),
    onSuccess: () => { setPassword(''); setUsername(''); toast.success('用户已创建'); onClose() },
  })
  return <Dialog open onOpenChange={open => { if (!open && !create.isPending) onClose() }}>
    <DialogContent showCloseButton={!create.isPending} className="max-h-[90dvh] overflow-y-auto">
      <DialogHeader><DialogTitle>新建用户</DialogTitle><DialogDescription>设置新用户的账号与权限。</DialogDescription></DialogHeader>
      <form className="space-y-5" onSubmit={event => { event.preventDefault(); if (!create.isPending && usernameValid && passwordValid) create.mutate() }}>
        <div className="space-y-2"><Label htmlFor="create-username">用户名</Label><Input id="create-username" autoComplete="off" required minLength={3} maxLength={64} pattern="[A-Za-z0-9][A-Za-z0-9_.\-]{2,63}" value={username} disabled={create.isPending} aria-invalid={!!username && !usernameValid} aria-describedby="create-username-hint" onChange={event => setUsername(event.target.value)} /><p id="create-username-hint" className={username && !usernameValid ? 'text-xs text-destructive' : 'text-xs text-muted-foreground'}>3–64 个字符，以字母或数字开头，仅含字母、数字、下划线、点或连字符</p></div>
        <div className="space-y-2"><Label htmlFor="create-password">密码</Label><Input id="create-password" type="password" autoComplete="new-password" required minLength={12} maxLength={128} value={password} disabled={create.isPending} aria-invalid={!!password && !passwordValid} aria-describedby="create-password-hint" onChange={event => setPassword(event.target.value)} /><p id="create-password-hint" className={password && !passwordValid ? 'text-xs text-destructive' : 'text-xs text-muted-foreground'}>密码须为 12–128 个字符</p></div>
        <div className="space-y-2"><Label htmlFor="create-role">角色</Label><Select value={role} disabled={create.isPending} onValueChange={value => { if (value === 'user' || value === 'admin') setRole(value) }}><SelectTrigger id="create-role" className="w-full"><SelectValue /></SelectTrigger><SelectContent><SelectItem value="user">普通用户</SelectItem><SelectItem value="admin">管理员</SelectItem></SelectContent></Select></div>
        <DialogFooter><Button type="button" variant="outline" disabled={create.isPending} onClick={onClose}>取消</Button><Button type="submit" disabled={create.isPending || !usernameValid || !passwordValid}>{create.isPending ? <Loader2 className="animate-spin" /> : <UserPlus />}{create.isPending ? '正在创建…' : '创建用户'}</Button></DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
}

function ResetPasswordDialog({ user, onClose }: { user: User; onClose: () => void }) {
  const [password, setPassword] = useState('')
  const valid = password.length >= 12 && password.length <= 128
  const reset = useMutation({
    gcTime: 0,
    mutationFn: () => resetUserPassword({ id: user.id, new_password: password }),
    onSuccess: () => { setPassword(''); toast.success('已重置，该用户所有会话已失效'); onClose() },
  })
  return <Dialog open onOpenChange={open => { if (!open && !reset.isPending) onClose() }}>
    <DialogContent showCloseButton={!reset.isPending} className="max-h-[90dvh] overflow-y-auto">
      <DialogHeader><DialogTitle>重置密码</DialogTitle><DialogDescription className="break-all">用户：{user.username}。重置后，该用户所有会话将失效。</DialogDescription></DialogHeader>
      <form className="space-y-5" onSubmit={event => { event.preventDefault(); if (!reset.isPending && valid) reset.mutate() }}>
        <div className="space-y-2"><Label htmlFor="reset-password">新密码</Label><Input id="reset-password" type="password" autoComplete="new-password" required minLength={12} maxLength={128} value={password} disabled={reset.isPending} aria-invalid={!!password && !valid} aria-describedby="reset-password-hint" onChange={event => setPassword(event.target.value)} /><p id="reset-password-hint" className={password && !valid ? 'text-xs text-destructive' : 'text-xs text-muted-foreground'}>密码须为 12–128 个字符</p></div>
        <DialogFooter><Button type="button" variant="outline" disabled={reset.isPending} onClick={onClose}>取消</Button><Button type="submit" disabled={reset.isPending || !valid}>{reset.isPending ? <Loader2 className="animate-spin" /> : <KeyRound />}{reset.isPending ? '正在重置…' : '重置密码'}</Button></DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
}

export default function UsersPage() {
  const { user: currentUser } = useAuth()
  const [offset, setOffset] = useState(0)
  const [creating, setCreating] = useState(false)
  const [resetUser, setResetUser] = useState<User | null>(null)
  const users = useUsers({ limit: 20, offset })
  const update = useMutation({ mutationFn: updateUser, onSuccess: () => toast.success('用户状态已更新') })

  return <div className="page w-full min-w-0 max-w-6xl">
    <header className="page-heading flex flex-wrap items-center justify-between gap-4"><h1 className="page-title">用户管理</h1><Button onClick={() => setCreating(true)}><UserPlus />新建用户</Button></header>
    {users.isPending && <div className="py-12 text-center text-sm text-muted-foreground" role="status"><Loader2 className="mr-2 inline size-4 animate-spin" />正在加载用户…</div>}
    {users.isError && <div className="error-panel my-4" role="alert"><p>{problemMessage(users.error)}</p><Button className="mt-3" variant="outline" disabled={users.isFetching} onClick={() => void users.refetch()}><RefreshCw className={users.isFetching ? 'animate-spin' : undefined} />重试</Button></div>}
    {users.data && <>
      {users.data.items.length ? <div className="min-w-0 max-w-full overflow-x-auto">
        <Table className="min-w-[640px]">
          <TableHeader><TableRow><TableHead>用户名</TableHead><TableHead>角色</TableHead><TableHead>状态</TableHead><TableHead>创建时间</TableHead><TableHead className="text-right">操作</TableHead></TableRow></TableHeader>
          <TableBody>{users.data.items.map(user => <TableRow key={user.id}>
            <TableCell className="max-w-64 whitespace-normal break-all font-medium">{user.username}{user.id === currentUser?.id && <Badge variant="outline" className="ml-2">我</Badge>}</TableCell>
            <TableCell><Badge variant="secondary">{user.role === 'admin' ? '管理员' : '普通用户'}</Badge></TableCell>
            <TableCell><div className="flex items-center gap-2"><Switch checked={user.is_active} disabled={update.isPending} aria-label={`${user.is_active ? '禁用' : '启用'}用户 ${user.username}`} onCheckedChange={is_active => { if (!update.isPending) update.mutate({ id: user.id, is_active }) }} /><span className="text-xs text-muted-foreground">{update.isPending && update.variables?.id === user.id ? '更新中…' : user.is_active ? '已启用' : '已禁用'}</span></div></TableCell>
            <TableCell className="text-xs text-muted-foreground"><time dateTime={user.created_at}>{new Date(user.created_at).toLocaleString('zh-CN')}</time></TableCell>
            <TableCell className="text-right"><Button variant="ghost" size="sm" onClick={() => setResetUser(user)}><KeyRound />重置密码</Button></TableCell>
          </TableRow>)}</TableBody>
        </Table>
      </div> : <EmptyState icon={Users} title={offset ? '此页暂无用户' : '暂无用户'} action={offset ? <Button variant="outline" onClick={() => setOffset(0)}>返回第一页</Button> : <Button onClick={() => setCreating(true)}><UserPlus />新建用户</Button>} />}
      <Pagination total={users.data.total} limit={20} offset={offset} onChange={setOffset} />
    </>}
    {creating && <CreateUserDialog onClose={() => setCreating(false)} />}
    {resetUser && <ResetPasswordDialog key={resetUser.id} user={resetUser} onClose={() => setResetUser(null)} />}
  </div>
}
