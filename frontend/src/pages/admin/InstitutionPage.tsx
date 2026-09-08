import { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { Loader2, Trash2, Upload } from 'lucide-react'
import { toast } from 'sonner'
import {
  clearPaywallState,
  uploadPaywallState,
  usePaywallStatus,
} from '@/api/queries'
import { Loading } from '@/components/common/Loading'
import { PageHeader } from '@/components/common/PageHeader'
import { Pill } from '@/components/common/Pill'
import { QueryError } from '@/components/common/QueryError'
import { StatBlock } from '@/components/common/StatBlock'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { dateTime } from '@/lib/format'

export default function InstitutionPage() {
  const status = usePaywallStatus()
  const [storageState, setStorageState] = useState<File | null>(null)
  const [sessionStorage, setSessionStorage] = useState<File | null>(null)
  const [contextMeta, setContextMeta] = useState<File | null>(null)
  const [confirming, setConfirming] = useState(false)
  const upload = useMutation({
    gcTime: 0,
    mutationFn: () =>
      uploadPaywallState({
        storage_state: storageState!,
        ...(sessionStorage ? { session_storage: sessionStorage } : {}),
        ...(contextMeta ? { context_meta: contextMeta } : {}),
      }),
    onSuccess: () => toast.success('机构登录态已更新'),
  })
  const clear = useMutation({
    gcTime: 0,
    mutationFn: clearPaywallState,
    onSuccess: () => {
      setConfirming(false)
      toast.success('机构登录态已清除')
    },
  })
  return (
    <div className="h-full overflow-y-auto">
      <div className="page min-w-0 max-w-3xl">
        <PageHeader
          title="机构访问"
          description="付费全文靠机构订阅的浏览器登录态获取；这里只做观测与替换，不在应用内代理登录"
        />
        {status.isPending ? (
          <Loading />
        ) : status.isError ? (
          <QueryError error={status.error} retry={status.refetch} />
        ) : (
          <section className="space-y-4 rounded-xl border bg-card p-6">
            <div className="flex flex-wrap items-center gap-2">
              <Pill tone={status.data.configured ? 'success' : 'warning'}>
                {status.data.configured ? '已配置' : '未配置'}
              </Pill>
              {!status.data.playwright_available && (
                <Pill tone="danger">服务端未安装浏览器</Pill>
              )}
            </div>
            <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
              <StatBlock
                label="保存时间"
                value={dateTime(status.data.saved_at) || '—'}
              />
              <StatBlock
                label="登录站点"
                value={status.data.final_url ?? '—'}
              />
              <StatBlock
                label="session_storage"
                value={status.data.has_session_storage ? '有' : '无'}
              />
              <StatBlock
                label="context.json"
                value={status.data.has_context_meta ? '有' : '无'}
              />
            </div>
            {status.data.configured && (
              <Button
                variant="outline"
                onClick={() => setConfirming(true)}
                disabled={clear.isPending}
              >
                <Trash2 />
                清除登录态
              </Button>
            )}
          </section>
        )}
        <section className="mt-6 space-y-5 rounded-xl border bg-card p-6">
          <div>
            <h2 className="text-sm font-medium">上传登录态</h2>
            <p className="metadata mt-2">
              在有桌面的机器上运行 <code>core/PICOSGpt paywall login</code>
              ，把生成的 <code>sd_state.json</code>、
              <code>sd_state.json.session_storage.json</code>、
              <code>sd_state.json.context.json</code>{' '}
              上传到这里。三份是一个整体： 只有 storage_state 必填，但
              <strong>没一起上传的伴随文件会被删除</strong>
              ，避免旧机构的会话与新 cookies 混用。
            </p>
          </div>
          <form
            className="space-y-5"
            onSubmit={(event) => {
              event.preventDefault()
              if (storageState && !upload.isPending) upload.mutate()
            }}
          >
            <div className="space-y-2">
              <Label htmlFor="storage-state">storage_state（必填）</Label>
              <Input
                id="storage-state"
                type="file"
                accept="application/json"
                required
                className="h-10 py-2"
                disabled={upload.isPending}
                onChange={(event) =>
                  setStorageState(event.target.files?.[0] ?? null)
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="session-storage">session_storage（选填）</Label>
              <Input
                id="session-storage"
                type="file"
                accept="application/json"
                className="h-10 py-2"
                disabled={upload.isPending}
                onChange={(event) =>
                  setSessionStorage(event.target.files?.[0] ?? null)
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="context-meta">context.json（选填）</Label>
              <Input
                id="context-meta"
                type="file"
                accept="application/json"
                className="h-10 py-2"
                disabled={upload.isPending}
                onChange={(event) =>
                  setContextMeta(event.target.files?.[0] ?? null)
                }
              />
            </div>
            <Button type="submit" disabled={!storageState || upload.isPending}>
              {upload.isPending ? (
                <Loader2 className="animate-spin" />
              ) : (
                <Upload />
              )}
              上传并替换
            </Button>
          </form>
        </section>
        {confirming && (
          <Dialog
            open
            onOpenChange={(open) =>
              !open && !clear.isPending && setConfirming(false)
            }
          >
            <DialogContent>
              <DialogHeader>
                <DialogTitle>清除机构登录态？</DialogTitle>
                <DialogDescription>
                  三份文件会被删除，付费全文将回退到摘要，按 DOI
                  入库也会被拒绝。
                </DialogDescription>
              </DialogHeader>
              <DialogFooter>
                <Button
                  variant="outline"
                  onClick={() => setConfirming(false)}
                  disabled={clear.isPending}
                >
                  取消
                </Button>
                <Button
                  variant="destructive"
                  onClick={() => clear.mutate()}
                  disabled={clear.isPending}
                >
                  {clear.isPending && <Loader2 className="animate-spin" />}
                  确认清除
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        )}
      </div>
    </div>
  )
}
