import { useEffect, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { Link } from 'react-router'
import { Loader2 } from 'lucide-react'
import {
  ingestDoi,
  queryClient,
  uploadPaper,
  useJob,
  usePaywallStatus,
} from '@/api/queries'
import { useJobEvents } from '@/api/useJobEvents'
import { jobErrorMessage } from '@/api/errors'
import { StatusBadge } from '@/components/common/StatusBadge'
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

/** 入库流水线的两个阶段，与 core/ingest.py 发出的 stage 事件一一对应。 */
const STAGES: [string, string][] = [
  ['fulltext', '解析 PDF'],
  ['kb', '抽取事实并入库'],
]

export function IngestDialog({ onClose }: { onClose: () => void }) {
  const [jobId, setJobId] = useState<string | null>(null)
  return (
    <Dialog open onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-h-[90dvh] overflow-y-auto sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>添加文献</DialogTitle>
          <DialogDescription>
            上传 PDF 或按 DOI 取全文，解析后写入文献库与知识库。
          </DialogDescription>
        </DialogHeader>
        {jobId ? (
          <IngestProgress jobId={jobId} onClose={onClose} />
        ) : (
          <IngestForms onStarted={setJobId} />
        )}
      </DialogContent>
    </Dialog>
  )
}

function IngestForms({ onStarted }: { onStarted: (jobId: string) => void }) {
  const [file, setFile] = useState<File | null>(null)
  const [title, setTitle] = useState('')
  const [doi, setDoi] = useState('')
  const [journal, setJournal] = useState('')
  const [year, setYear] = useState('')
  const [authors, setAuthors] = useState('')
  const [ingestId, setIngestId] = useState('')
  const paywall = usePaywallStatus()
  const start = useMutation({
    gcTime: 0,
    mutationFn: (kind: 'upload' | 'doi') =>
      kind === 'upload'
        ? uploadPaper({ file: file!, title, doi, journal, year, authors })
        : ingestDoi({ doi: ingestId.trim() }),
    onSuccess(job) {
      queryClient.setQueryData(['job', job.id], job)
      onStarted(job.id)
    },
  })
  const paywallReady =
    !!paywall.data?.configured && !!paywall.data.playwright_available
  const doiReason = !paywall.data
    ? '正在读取机构访问状态…'
    : !paywall.data.playwright_available
      ? '服务端未安装浏览器，无法按 DOI 取全文'
      : !paywall.data.configured
        ? '机构访问未配置，请先在「机构访问」页上传登录态'
        : ''
  return (
    <Tabs defaultValue="upload">
      <TabsList className="w-full">
        <TabsTrigger value="upload">上传 PDF</TabsTrigger>
        <TabsTrigger value="doi">按 DOI 获取</TabsTrigger>
      </TabsList>
      <TabsContent value="upload">
        <form
          className="space-y-5 pt-2"
          onSubmit={(event) => {
            event.preventDefault()
            if (file && title.trim() && !start.isPending) start.mutate('upload')
          }}
        >
          <div className="space-y-2">
            <Label htmlFor="ingest-file">PDF 文件</Label>
            <Input
              id="ingest-file"
              type="file"
              accept="application/pdf"
              required
              className="h-10 py-2"
              disabled={start.isPending}
              onChange={(event) => setFile(event.target.files?.[0] ?? null)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="ingest-title">标题</Label>
            <Input
              id="ingest-title"
              className="h-10"
              required
              maxLength={300}
              value={title}
              disabled={start.isPending}
              onChange={(event) => setTitle(event.target.value)}
            />
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="ingest-doi">DOI（选填）</Label>
              <Input
                id="ingest-doi"
                className="h-10"
                placeholder="10.1016/…"
                value={doi}
                disabled={start.isPending}
                onChange={(event) => setDoi(event.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="ingest-journal">期刊（选填）</Label>
              <Input
                id="ingest-journal"
                className="h-10"
                value={journal}
                disabled={start.isPending}
                onChange={(event) => setJournal(event.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="ingest-year">年份（选填）</Label>
              <Input
                id="ingest-year"
                className="h-10"
                inputMode="numeric"
                maxLength={4}
                value={year}
                disabled={start.isPending}
                onChange={(event) => setYear(event.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="ingest-authors">作者（选填）</Label>
              <Input
                id="ingest-authors"
                className="h-10"
                placeholder="逗号分隔"
                value={authors}
                disabled={start.isPending}
                onChange={(event) => setAuthors(event.target.value)}
              />
            </div>
          </div>
          <p className="metadata">
            填了 DOI 会先向上游补全元数据；取不到时用这里填的内容。
          </p>
          <DialogFooter>
            <Button
              type="submit"
              disabled={!file || !title.trim() || start.isPending}
            >
              {start.isPending && <Loader2 className="animate-spin" />}
              开始入库
            </Button>
          </DialogFooter>
        </form>
      </TabsContent>
      <TabsContent value="doi">
        <form
          className="space-y-5 pt-2"
          onSubmit={(event) => {
            event.preventDefault()
            if (paywallReady && ingestId.trim() && !start.isPending)
              start.mutate('doi')
          }}
        >
          <div className="space-y-2">
            <Label htmlFor="ingest-only-doi">DOI</Label>
            <Input
              id="ingest-only-doi"
              className="h-10"
              required
              placeholder="10.1016/S0140-6736(20)30183-5"
              value={ingestId}
              disabled={start.isPending || !paywallReady}
              onChange={(event) => setIngestId(event.target.value)}
            />
          </div>
          <p className="metadata">
            {doiReason || '经机构订阅下载 PDF，元数据从上游解析。'}
          </p>
          <DialogFooter>
            <Button
              type="submit"
              disabled={!paywallReady || !ingestId.trim() || start.isPending}
            >
              {start.isPending && <Loader2 className="animate-spin" />}
              获取并入库
            </Button>
          </DialogFooter>
        </form>
      </TabsContent>
    </Tabs>
  )
}

function IngestProgress({
  jobId,
  onClose,
}: {
  jobId: string
  onClose: () => void
}) {
  const job = useJob(jobId)
  const active =
    !job.data || job.data.status === 'queued' || job.data.status === 'running'
  const { live, connection } = useJobEvents(jobId, active)
  const status = job.data?.status
  useEffect(() => {
    if (status === 'succeeded') {
      void queryClient.invalidateQueries({ queryKey: ['papers'] })
      void queryClient.invalidateQueries({ queryKey: ['kbStats'] })
    }
  }, [status])
  const key =
    typeof job.data?.result?.key === 'string'
      ? job.data.result.key
      : live.terminal?.kind === 'succeeded'
        ? live.terminal.key
        : undefined
  return (
    <div className="space-y-4" aria-live="polite">
      <div className="flex flex-wrap items-center gap-3">
        <span className="text-sm font-medium">入库任务</span>
        <StatusBadge status={status ?? 'queued'} />
        {active && connection === 'reconnecting' && (
          <span className="text-sm text-warning">连接中断，正在重连…</span>
        )}
      </div>
      <ol className="space-y-2">
        {STAGES.map(([stage, label]) => (
          <li key={stage} className="flex items-center gap-2 text-sm">
            <span
              className="size-1.5 rounded-full"
              style={{
                background:
                  live.stages[stage as 'fulltext' | 'kb']?.status === 'finished'
                    ? 'var(--success)'
                    : live.stages[stage as 'fulltext' | 'kb']
                      ? 'var(--primary)'
                      : 'var(--border)',
              }}
            />
            {label}
          </li>
        ))}
      </ol>
      {live.logs.length > 0 && (
        <div className="max-h-32 overflow-y-auto rounded-lg bg-muted/50 p-3">
          {live.logs.slice(-6).map((log, index) => (
            <p
              key={index}
              className={
                'break-words font-mono text-xs ' +
                (log.level === 'warning'
                  ? 'text-warning'
                  : 'text-muted-foreground')
              }
            >
              {log.message}
            </p>
          ))}
        </div>
      )}
      {status === 'succeeded' && (
        <p className="text-sm text-success">
          已入库
          {key && (
            <>
              {' · '}
              <Link
                className="underline"
                to={'/library/' + key}
                onClick={onClose}
              >
                查看文献
              </Link>
            </>
          )}
        </p>
      )}
      {status === 'failed' && (
        <div role="alert" className="error-panel">
          {jobErrorMessage(job.data?.error?.code ?? 'internal_error')}
          {job.data?.error?.message && (
            <p className="mt-1 break-words text-sm">{job.data.error.message}</p>
          )}
        </div>
      )}
      <DialogFooter>
        <Button variant="outline" onClick={onClose}>
          {active ? '后台运行' : '关闭'}
        </Button>
      </DialogFooter>
    </div>
  )
}
