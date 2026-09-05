import { useEffect, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { Link } from 'react-router'
import { Database, RefreshCw, Search } from 'lucide-react'
import * as m from 'motion/react-m'
import {
  queryClient,
  reindexKb,
  useJob,
  useKbSearch,
  useKbStats,
  type KbSearchParams,
} from '@/api/queries'
import { useJobEvents } from '@/api/useJobEvents'
import { jobErrorMessage } from '@/api/errors'
import { useAuth } from '@/auth/store'
import { EmptyState } from '@/components/common/EmptyState'
import { ListRow, ListRows } from '@/components/common/ListRows'
import { Loading } from '@/components/common/Loading'
import { PageHeader } from '@/components/common/PageHeader'
import { Pill } from '@/components/common/Pill'
import { QueryError } from '@/components/common/QueryError'
import { RankBadge } from '@/components/common/RankBadge'
import { SourceBadge } from '@/components/common/SourceBadge'
import { StatBlock } from '@/components/common/StatBlock'
import { StatusBadge } from '@/components/common/StatusBadge'
import { VerifiedPill } from '@/components/common/VerifiedPill'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { ease } from '@/lib/motion'
import { kindLabel, PaperLinks } from './shared'

export default function KbSearchPage() {
  const { isAdmin } = useAuth()
  const stats = useKbStats()
  const [q, setQ] = useState('')
  const [kind, setKind] = useState('all')
  const [topK, setTopK] = useState('8')
  const [submitted, setSubmitted] = useState<KbSearchParams | null>(null)
  const results = useKbSearch(submitted)
  const [jobId, setJobId] = useState<string | null>(null)
  const job = useJob(jobId)
  const active =
    !!jobId &&
    (!job.data || job.data.status === 'queued' || job.data.status === 'running')
  const { live, connection } = useJobEvents(jobId, active)
  const reindex = useMutation({
    mutationFn: reindexKb,
    onSuccess(value) {
      queryClient.setQueryData(['job', value.id], value)
      setJobId(value.id)
    },
  })
  useEffect(() => {
    if (job.data?.status === 'succeeded') {
      void queryClient.invalidateQueries({ queryKey: ['kbStats'] })
      void queryClient.invalidateQueries({ queryKey: ['papers'] })
      void queryClient.invalidateQueries({ queryKey: ['kbSearch'] })
    }
  }, [job.data?.status, jobId])
  const progress =
    live.progress?.stage === 'reindex' ? live.progress : job.data?.progress
  const result = job.data?.result
  const terminal = live.terminal?.kind === 'succeeded' ? live.terminal : null
  const items =
    typeof result?.items === 'number' ? result.items : terminal?.items
  const papers =
    typeof result?.papers === 'number' ? result.papers : terminal?.papers
  const pct =
    progress?.total && progress.current != null
      ? Math.min(100, (progress.current / progress.total) * 100)
      : 0

  return (
    <div className="h-full overflow-y-auto">
      <div className="page">
        <PageHeader
          title="知识库"
          description="从已核实的事实与原文段落中做语义检索"
          actions={
            isAdmin && (
              <Button
                variant="outline"
                disabled={reindex.isPending || active}
                onClick={() => reindex.mutate()}
              >
                <RefreshCw
                  className={reindex.isPending || active ? 'animate-spin' : ''}
                />
                重建索引
              </Button>
            )
          }
        />
        <section className="space-y-4 border-b pb-6">
          {stats.isPending ? (
            <Loading />
          ) : stats.isError ? (
            <QueryError error={stats.error} retry={stats.refetch} />
          ) : (
            <>
              <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
                <StatBlock
                  label="条目"
                  value={stats.data.items.toLocaleString()}
                />
                <StatBlock
                  label="论文"
                  value={stats.data.papers.toLocaleString()}
                />
                {Object.entries(stats.data.by_kind).map(([name, count]) => (
                  <StatBlock
                    key={name}
                    label={kindLabel(name)}
                    value={count.toLocaleString()}
                  />
                ))}
              </div>
              <p className="metadata mt-3">
                嵌入模型：{stats.data.embedder ?? '未加载'} · 维度：
                {stats.data.dim ?? '未知'}
              </p>
            </>
          )}
          {jobId && (
            <div className="space-y-3 border-t pt-4" aria-live="polite">
              {job.isError && (
                <QueryError error={job.error} retry={job.refetch} />
              )}
              {job.data && (
                <div className="flex flex-wrap items-center gap-3">
                  <span className="text-sm font-medium">索引重建</span>
                  <StatusBadge status={job.data.status} />
                  {active && connection === 'reconnecting' && (
                    <span className="text-sm text-warning">
                      连接中断，正在重连…
                    </span>
                  )}
                </div>
              )}
              {active &&
                progress?.current != null &&
                progress.total != null && (
                  <div className="space-y-2">
                    <p className="metadata">
                      {progress.current} / {progress.total}
                    </p>
                    {progress.total > 0 && (
                      <div className="h-1.5 overflow-hidden rounded-full bg-muted">
                        <m.div
                          className="h-full rounded-full bg-primary"
                          animate={{ width: pct + '%' }}
                          transition={{ duration: 0.4, ease }}
                          aria-label="索引重建进度"
                        />
                      </div>
                    )}
                  </div>
                )}
              {job.data?.status === 'succeeded' && (
                <p className="text-sm text-success">
                  索引已更新{items != null ? ' · ' + items + ' 条条目' : ''}
                  {papers != null ? ' · ' + papers + ' 篇论文' : ''}
                </p>
              )}
              {job.data?.status === 'failed' && (
                <div role="alert" className="error-panel">
                  {jobErrorMessage(job.data.error?.code ?? 'internal_error')}
                  {job.data.error?.message && (
                    <p className="mt-1 break-words text-sm">
                      {job.data.error.message}
                    </p>
                  )}
                </div>
              )}
            </div>
          )}
        </section>
        <form
          className="mt-8 flex flex-col gap-2 md:flex-row md:items-center"
          onSubmit={(event) => {
            event.preventDefault()
            if (q.trim()) {
              const next: KbSearchParams = {
                q: q.trim(),
                top_k: Number(topK),
                ...(kind === 'fact' || kind === 'paragraph' ? { kind } : {}),
              }
              if (JSON.stringify(next) === JSON.stringify(submitted))
                void results.refetch()
              else setSubmitted(next)
            }
          }}
        >
          <Input
            aria-label="检索内容"
            className="h-10 flex-1"
            value={q}
            onChange={(event) => setQ(event.target.value)}
            required
            placeholder="搜索事实或原文段落"
          />
          <Select value={kind} onValueChange={setKind}>
            <SelectTrigger aria-label="类型" className="h-10 w-full md:w-28">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">全部</SelectItem>
              <SelectItem value="fact">事实</SelectItem>
              <SelectItem value="paragraph">段落</SelectItem>
            </SelectContent>
          </Select>
          <Select value={topK} onValueChange={setTopK}>
            <SelectTrigger aria-label="条数" className="h-10 w-full md:w-24">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {['5', '8', '15', '30'].map((value) => (
                <SelectItem key={value} value={value}>
                  {value}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Button
            type="submit"
            className="h-10"
            disabled={!q.trim() || results.isFetching}
          >
            <Search />
            检索
          </Button>
        </form>
        {submitted &&
          (results.isFetching ? (
            <Loading>首次检索需要加载嵌入模型，约 15 秒…</Loading>
          ) : results.isError ? (
            <QueryError error={results.error} retry={results.refetch} />
          ) : results.data?.items.length ? (
            <ListRows>
              {results.data.items.map((hit, i) => (
                <ListRow index={i} key={i} className="min-w-0 space-y-3">
                  <div className="flex flex-wrap items-center gap-2">
                    <Pill>{kindLabel(hit.kind)}</Pill>
                    {hit.fact_kind && <Pill>{kindLabel(hit.fact_kind)}</Pill>}
                    <VerifiedPill value={hit.verified} />
                    <span className="metadata tabular-nums">
                      相似度 {hit.score.toFixed(3)}
                    </span>
                  </div>
                  <p className="whitespace-pre-wrap break-words text-[14.5px] leading-7">
                    {hit.text}
                  </p>
                  {hit.text_zh && (
                    <p className="whitespace-pre-wrap break-words text-sm leading-7 text-muted-foreground">
                      {hit.text_zh}
                    </p>
                  )}
                  {hit.quote && (
                    <blockquote className="break-words border-l-2 border-primary/30 pl-3 text-sm leading-7">
                      {hit.quote}
                    </blockquote>
                  )}
                  <p className="break-words text-sm font-medium">{hit.title}</p>
                  <p className="metadata break-words">
                    {hit.authors && <span>{hit.authors}</span>}
                    {hit.journal && <i>{hit.journal}</i>}
                    {hit.year && <span>{hit.year}</span>}
                  </p>
                  <div className="flex flex-wrap items-center gap-1.5">
                    <RankBadge quartile={hit.quartile} />
                    <SourceBadge source={hit.source} />
                    <span className="metadata">
                      {hit.sec}
                      {hit.pid != null && ' · ¶' + hit.pid}
                      {hit.page != null && ' · 第 ' + hit.page + ' 页'}
                    </span>
                  </div>
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <PaperLinks pmid={hit.pmid} doi={hit.doi} />
                    {hit.pmid &&
                      /^[A-Za-z0-9._-]{1,80}$/.test(hit.pmid) &&
                      Number.isSafeInteger(hit.pid) &&
                      hit.pid! > 0 && (
                        <Button variant="outline" size="sm" asChild>
                          <Link
                            to={
                              '/library/' +
                              encodeURIComponent(hit.pmid) +
                              '?pid=' +
                              hit.pid
                            }
                          >
                            查看原文段落
                          </Link>
                        </Button>
                      )}
                  </div>
                </ListRow>
              ))}
            </ListRows>
          ) : (
            <EmptyState icon={Database} title="未找到相关条目" />
          ))}
      </div>
    </div>
  )
}
