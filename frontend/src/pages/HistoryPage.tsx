import { useEffect, useState } from 'react'
import { Link, useLocation, useSearchParams } from 'react-router'
import { useMutation } from '@tanstack/react-query'
import { AlertCircle, History, LoaderCircle, MoreHorizontal, Plus, RotateCcw, Search, Square, Trash2 } from 'lucide-react'
import { toast } from 'sonner'
import type { components } from '@/api/schema'
import { cancelJob, useAnswers } from '@/api/queries'
import { jobErrorMessage, problemMessage } from '@/api/errors'
import { useAuth } from '@/auth/store'
import { DeleteAnswerDialog } from '@/components/DeleteAnswerDialog'
import { EmptyState } from '@/components/EmptyState'
import { Pagination } from '@/components/Pagination'
import { StatusBadge } from '@/components/StatusBadge'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu'
import { dateTime, relativeTime } from '@/lib/format'

type AnswerStatus = components['schemas']['AnswerSummary']['status']
const statuses: { value: AnswerStatus; label: string }[] = [
  { value: 'queued', label: '排队中' },
  { value: 'running', label: '进行中' },
  { value: 'ready', label: '已完成' },
  { value: 'failed', label: '失败' },
  { value: 'cancelled', label: '已取消' },
]
const limit = 20

export default function HistoryPage() {
  const { isAdmin } = useAuth()
  const location = useLocation()
  const [searchParams, setSearchParams] = useSearchParams()
  const status = statuses.find(item => item.value === searchParams.get('status'))?.value
  const q = searchParams.get('q') ?? ''
  const rawOffset = Number(searchParams.get('offset') ?? 0)
  const offset = Number.isSafeInteger(rawOffset) && rawOffset >= 0 ? rawOffset : 0
  const [draft, setDraft] = useState({ key: location.key, value: q })
  const [composing, setComposing] = useState(false)
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const [cancelRequested, setCancelRequested] = useState<Set<string>>(() => new Set())

  // 导航时同步草稿并取消旧防抖，不由同步副作用反向覆盖历史记录。
  if (draft.key !== location.key) setDraft({ key: location.key, value: q })
  useEffect(() => {
    if (draft.key !== location.key || draft.value === q || composing) return
    const timer = window.setTimeout(() => {
      setSearchParams(current => {
        const next = new URLSearchParams(current)
        if (draft.value) next.set('q', draft.value)
        else next.delete('q')
        next.delete('offset')
        return next
      })
    }, 300)
    return () => window.clearTimeout(timer)
  }, [draft, location.key, q, composing, setSearchParams])

  const answers = useAnswers({ status, q: q || undefined, limit, offset })
  const cancel = useMutation({
    mutationFn: cancelJob,
    onSuccess: (_job, id) => {
      setCancelRequested(current => new Set(current).add(id))
      toast.success('已请求取消，等待任务响应')
    },
  })
  function changeOffset(value: number) {
    setSearchParams(current => {
      const next = new URLSearchParams(current)
      if (value > 0) next.set('offset', String(value))
      else next.delete('offset')
      return next
    })
  }
  function clearFilters() {
    setSearchParams(current => {
      const next = new URLSearchParams(current)
      next.delete('q')
      next.delete('status')
      next.delete('offset')
      return next
    })
  }
  const filtered = !!q || !!status
  const items = answers.data?.items ?? []

  return <main className="page">
    <div className="page-heading">
      <h1 className="page-title">问答历史</h1>
      <Button asChild><Link to="/"><Plus />新建问答</Link></Button>
    </div>
    <div className="toolbar">
      <div className="relative min-w-0 flex-1 sm:min-w-64">
        <Search className="pointer-events-none absolute top-2.5 left-3 size-4 text-muted-foreground" />
        <Input aria-label="搜索历史问题" placeholder="搜索历史问题" className="pl-9" value={draft.key === location.key ? draft.value : q} onChange={event => setDraft({ key: location.key, value: event.target.value })} onCompositionStart={() => setComposing(true)} onCompositionEnd={() => setComposing(false)} />
      </div>
      <Select value={status ?? 'all'} onValueChange={value => setSearchParams(current => {
        const next = new URLSearchParams(current)
        if (value === 'all') next.delete('status')
        else next.set('status', value)
        next.delete('offset')
        return next
      })}>
        <SelectTrigger aria-label="问答状态" className="w-36"><SelectValue /></SelectTrigger>
        <SelectContent><SelectItem value="all">全部状态</SelectItem>{statuses.map(item => <SelectItem key={item.value} value={item.value}>{item.label}</SelectItem>)}</SelectContent>
      </Select>
      {filtered && <Button variant="ghost" onClick={clearFilters}><RotateCcw />清除筛选</Button>}
    </div>
    {answers.isError && <div role="alert" className="error-panel my-5 flex flex-wrap items-center gap-3"><AlertCircle className="size-4 shrink-0" /><span className="min-w-0 flex-1 break-words">{problemMessage(answers.error)}</span><Button variant="outline" disabled={answers.isFetching} onClick={() => void answers.refetch()}><RotateCcw />重试</Button></div>}
    {answers.isPending ? <div role="status" className="flex items-center justify-center gap-2 py-20 text-sm text-muted-foreground"><LoaderCircle className="size-4 animate-spin" />正在加载问答历史…</div> : answers.data && <>
      {items.length === 0 ? answers.data.total > 0 ? <EmptyState icon={History} title="本页暂无问答" action={<Button variant="outline" onClick={() => changeOffset(0)}>返回第一页</Button>} /> : filtered ? <EmptyState icon={Search} title="没有符合条件的问答" action={<Button variant="outline" onClick={clearFilters}><RotateCcw />清除筛选</Button>} /> : <EmptyState icon={History} title="还没有问答，去提问" action={<Button asChild><Link to="/"><Plus />新建问答</Link></Button>} /> : <div aria-label="问答列表" className="border-t">
        {items.map(answer => {
          const active = answer.status === 'queued' || answer.status === 'running'
          const cancelling = !!answer.job_id && (cancelRequested.has(answer.job_id) || (cancel.isPending && cancel.variables === answer.job_id))
          return <article key={answer.id} className="list-row flex items-start gap-3">
            <div className="min-w-0 flex-1">
              <div className="mb-2 flex flex-wrap items-center gap-2">
                <StatusBadge status={answer.status} />
                {isAdmin && answer.status === 'ready' && answer.filters_label === null && answer.n_papers === null && <Badge variant="secondary">历史导入</Badge>}
                {active && cancelling && <span className="text-xs text-muted-foreground">取消中…</span>}
              </div>
              <Link className="block text-base leading-7 font-medium break-words hover:text-primary hover:underline" to={`/a/${answer.id}`}>{answer.question}</Link>
              {answer.filters_label && <p className="mt-2 text-xs leading-6 break-words text-muted-foreground">{answer.filters_label}</p>}
              <div className="metadata mt-2 flex flex-wrap gap-x-4 gap-y-1">
                {answer.n_papers != null && <span>{answer.n_papers} 篇文献</span>}
                {answer.n_fulltext != null && <span>{answer.n_fulltext} 篇全文</span>}
                <time dateTime={answer.created_at} title={dateTime(answer.created_at)}>{relativeTime(answer.created_at)}</time>
              </div>
              {answer.error && <p className="mt-2 text-xs leading-6 break-words text-destructive">{jobErrorMessage(answer.error.code)}</p>}
            </div>
            {(!active || answer.job_id) && <DropdownMenu>
              <DropdownMenuTrigger asChild><Button variant="ghost" size="icon" className="shrink-0" aria-label={`问答操作：${answer.question}`} title="问答操作"><MoreHorizontal /></Button></DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                {active ? <DropdownMenuItem disabled={cancelling || cancel.isPending} onSelect={() => { if (answer.job_id) cancel.mutate(answer.job_id) }}><Square />{cancelling ? '取消中…' : '取消任务'}</DropdownMenuItem> : <DropdownMenuItem variant="destructive" onSelect={() => setDeleteId(answer.id)}><Trash2 />删除</DropdownMenuItem>}
              </DropdownMenuContent>
            </DropdownMenu>}
          </article>
        })}
      </div>}
      {items.length > 0 && <Pagination total={answers.data.total} limit={limit} offset={offset} onChange={changeOffset} />}
    </>}
    <DeleteAnswerDialog id={deleteId} onClose={() => setDeleteId(null)} onDeleted={() => { if (items.length <= 1 && offset > 0) changeOffset(Math.max(0, offset - limit)) }} />
  </main>
}
