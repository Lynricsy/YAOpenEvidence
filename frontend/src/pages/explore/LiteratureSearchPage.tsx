import { useState } from 'react'
import { BookOpen, ChevronDown, Search } from 'lucide-react'
import type { components } from '@/api/schema'
import {
  useLiteratureFulltext,
  useLiteratureSearch,
  type LiteratureSearchParams,
} from '@/api/queries'
import { ApiError } from '@/api/errors'
import { EmptyState } from '@/components/EmptyState'
import { JournalPicker } from '@/components/JournalPicker'
import { RankBadge } from '@/components/RankBadge'
import { YearPicker } from '@/components/YearPicker'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import {
  DEFAULT_FILTERS,
  validYears,
  yearParams,
  type YearState,
} from '@/lib/filters'
import { Loading, PaperLinks, QueryError } from './shared'

type LiteratureRecord = components['schemas']['LiteratureRecord']
const publicationTypes = [
  ['Review', '综述'],
  ['Systematic Review', '系统综述'],
  ['Meta-Analysis', '荟萃分析'],
  ['Randomized Controlled Trial', '随机对照试验'],
  ['Clinical Trial', '临床试验'],
  ['Observational Study', '观察性研究'],
]

function FulltextDialog({
  paper,
  onClose,
}: {
  paper: LiteratureRecord
  onClose: () => void
}) {
  const ident = paper.pmcid || paper.pmid || paper.doi || null
  const [section, setSection] = useState('')
  const directory = useLiteratureFulltext(ident, '')
  const fulltext = useLiteratureFulltext(section ? ident : null, section)
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
    >
      <DialogContent className="max-h-[90dvh] overflow-y-auto sm:max-w-3xl">
        <DialogHeader className="pr-6">
          <DialogTitle className="break-words leading-7">
            {paper.title || '文献全文'}
          </DialogTitle>
          <DialogDescription>
            全文目录{directory.data?.pmcid ? ' · ' + directory.data.pmcid : ''}
          </DialogDescription>
        </DialogHeader>
        {directory.isPending ? (
          <Loading />
        ) : directory.isError ? (
          directory.error instanceof ApiError &&
          directory.error.code === 'fulltext_unavailable' ? (
            <EmptyState title="无可用全文" />
          ) : (
            <QueryError error={directory.error} retry={directory.refetch} />
          )
        ) : (
          <div className="min-w-0 space-y-6">
            {directory.data.citation && (
              <p className="metadata break-words">{directory.data.citation}</p>
            )}
            {directory.data.abstract && (
              <section className="space-y-2">
                <h2 className="text-sm font-semibold">摘要</h2>
                <p className="whitespace-pre-wrap break-words text-sm leading-7">
                  {directory.data.abstract}
                </p>
              </section>
            )}
            <section className="space-y-2">
              <h2 className="text-sm font-semibold">章节</h2>
              {directory.data.sections.length ? (
                <div className="divide-y">
                  {directory.data.sections.map((entry, index) => (
                    <button
                      type="button"
                      key={index}
                      className="flex w-full items-start justify-between gap-4 py-3 text-left text-sm hover:text-primary"
                      aria-pressed={section === entry.title}
                      onClick={() => setSection(entry.title)}
                    >
                      <span className="min-w-0 break-words">{entry.title}</span>
                      <span className="shrink-0 text-xs text-muted-foreground">
                        {entry.chars.toLocaleString()} 字
                      </span>
                    </button>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-muted-foreground">暂无章节</p>
              )}
            </section>
            {section && (
              <section className="space-y-3 border-t pt-5">
                <h2 className="break-words font-semibold">{section}</h2>
                {fulltext.isPending ? (
                  <Loading />
                ) : fulltext.isError ? (
                  fulltext.error instanceof ApiError &&
                  fulltext.error.code === 'fulltext_unavailable' ? (
                    <EmptyState title="无可用全文" />
                  ) : (
                    <QueryError
                      error={fulltext.error}
                      retry={fulltext.refetch}
                    />
                  )
                ) : (
                  <>
                    <p className="whitespace-pre-wrap break-words text-sm leading-7">
                      {fulltext.data?.text || '该章节没有正文'}
                    </p>
                    {fulltext.data?.truncated && (
                      <p className="text-sm text-amber-600">
                        已按 20000 字符截断
                      </p>
                    )}
                  </>
                )}
              </section>
            )}
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}

export default function LiteratureSearchPage() {
  const [q, setQ] = useState('')
  const [source, setSource] = useState<'auto' | 'pubmed' | 's2'>('auto')
  const [limit, setLimit] = useState('10')
  const [years, setYears] = useState<YearState>(DEFAULT_FILTERS)
  const [types, setTypes] = useState<string[]>([])
  const [quartiles, setQuartiles] = useState<string[]>([])
  const [journals, setJournals] = useState<string[]>([])
  const [oa, setOa] = useState(false)
  const [submitted, setSubmitted] = useState<LiteratureSearchParams | null>(
    null,
  )
  const results = useLiteratureSearch(submitted)
  const [opened, setOpened] = useState<LiteratureRecord | null>(null)
  return (
    <div className="page min-w-0">
      <div className="page-heading">
        <h1 className="page-title">查文献</h1>
      </div>
      <form
        className="space-y-6 border-b pb-6"
        onSubmit={(event) => {
          event.preventDefault()
          if (!q.trim() || !validYears(years)) return
          const next: LiteratureSearchParams = {
            q: q.trim(),
            source,
            limit: Number(limit),
            ...yearParams(years),
            publication_types: types,
            quartiles: quartiles.map(Number).sort(),
            journals,
            open_access_only: source === 's2' && oa,
          }
          if (JSON.stringify(next) === JSON.stringify(submitted))
            void results.refetch()
          else setSubmitted(next)
        }}
      >
        <div className="flex flex-wrap items-end gap-3">
          <label className="min-w-0 flex-1 basis-64 space-y-2">
            <span className="field-label">检索词</span>
            <Input
              required
              value={q}
              onChange={(event) => setQ(event.target.value)}
              placeholder="搜索文献"
            />
          </label>
          <div className="space-y-2">
            <span className="field-label" id="literature-source">
              来源
            </span>
            <Select
              value={source}
              onValueChange={(value) => {
                if (value === 'auto' || value === 'pubmed' || value === 's2')
                  setSource(value)
              }}
            >
              <SelectTrigger
                className="w-44"
                aria-labelledby="literature-source"
              >
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="auto">自动</SelectItem>
                <SelectItem value="pubmed">PubMed</SelectItem>
                <SelectItem value="s2">Semantic Scholar</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <span className="field-label" id="literature-limit">
              条数
            </span>
            <Select value={limit} onValueChange={setLimit}>
              <SelectTrigger
                className="w-24"
                aria-labelledby="literature-limit"
              >
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {['10', '20', '30'].map((value) => (
                  <SelectItem value={value} key={value}>
                    {value}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <Button
            type="submit"
            disabled={!q.trim() || !validYears(years) || results.isFetching}
          >
            <Search />
            检索
          </Button>
        </div>
        <div className="grid min-w-0 gap-6 lg:grid-cols-2">
          <fieldset className="min-w-0 space-y-3">
            <legend className="field-label mb-3">年份</legend>
            <YearPicker
              value={years}
              onChange={(value) =>
                setYears((current) => ({ ...current, ...value }))
              }
            />
          </fieldset>
          <fieldset className="min-w-0 space-y-3">
            <legend className="field-label mb-3">期刊分区</legend>
            <ToggleGroup
              type="multiple"
              value={quartiles}
              onValueChange={setQuartiles}
              spacing={1}
              className="flex flex-wrap justify-start gap-2"
            >
              {['1', '2', '3', '4'].map((value) => (
                <ToggleGroupItem
                  className="rounded-md border"
                  key={value}
                  value={value}
                  aria-label={value + '区'}
                >
                  Q{value}
                </ToggleGroupItem>
              ))}
            </ToggleGroup>
          </fieldset>
          <fieldset className="min-w-0 space-y-3">
            <legend className="field-label mb-3">文献类型</legend>
            <ToggleGroup
              type="multiple"
              value={types}
              onValueChange={setTypes}
              spacing={1}
              className="flex flex-wrap justify-start gap-2"
            >
              {publicationTypes.map(([value, label]) => (
                <ToggleGroupItem
                  size="sm"
                  className="rounded-md border text-xs"
                  key={value}
                  value={value}
                >
                  {label}
                </ToggleGroupItem>
              ))}
            </ToggleGroup>
          </fieldset>
          <fieldset className="min-w-0 space-y-3">
            <legend className="field-label mb-3">期刊家族（含子刊）</legend>
            <JournalPicker value={journals} onChange={setJournals} />
          </fieldset>
        </div>
        <div className="flex items-center gap-3">
          <Switch
            id="literature-oa"
            checked={oa}
            disabled={source !== 's2'}
            onCheckedChange={setOa}
          />
          <label
            htmlFor="literature-oa"
            className={
              source !== 's2' ? 'text-sm text-muted-foreground' : 'text-sm'
            }
          >
            仅开放获取（仅 S2）
          </label>
        </div>
      </form>
      {submitted &&
        (results.isFetching ? (
          <Loading>正在检索文献…</Loading>
        ) : results.isError ? (
          <QueryError error={results.error} retry={results.refetch} />
        ) : (
          results.data && (
            <section className="min-w-0 pt-5">
              {results.data.fallback_reason && (
                <p
                  role="status"
                  className="mb-4 break-words rounded-md border border-sky-500/25 bg-sky-500/5 p-3 text-sm leading-6"
                >
                  Semantic Scholar 不可用，已改用 PubMed：
                  {results.data.fallback_reason}
                </p>
              )}
              <p className="metadata">
                来源{' '}
                {results.data.source === 's2' ? 'Semantic Scholar' : 'PubMed'} ·
                上游命中 {results.data.total.toLocaleString()}
              </p>
              {results.data.items.length ? (
                results.data.items.map((paper, index) => (
                  <article
                    className="list-row min-w-0 space-y-3"
                    key={paper.source + ':' + paper.id + ':' + index}
                  >
                    <h2 className="break-words font-semibold leading-7">
                      {paper.title || paper.id}
                    </h2>
                    <p className="metadata break-words">
                      {paper.authors?.slice(0, 3).join(', ')}
                      {(paper.authors?.length ?? 0) > 3 && ' et al.'}
                    </p>
                    <p className="metadata">
                      <i>{paper.journal}</i>
                      {paper.year && ' (' + paper.year + ')'}
                    </p>
                    <div className="flex flex-wrap items-center gap-2">
                      <RankBadge quartile={paper.rank?.quartile} />
                      {paper.rank?.top && (
                        <Badge variant="outline" className="status-green">
                          Top
                        </Badge>
                      )}
                      {paper.types?.map((type) => (
                        <Badge
                          className="max-w-full whitespace-normal"
                          variant="outline"
                          key={type}
                        >
                          {publicationTypes.find(
                            ([value]) => value === type,
                          )?.[1] ?? type}
                        </Badge>
                      ))}
                      {paper.cited_by != null && (
                        <span className="metadata">被引 {paper.cited_by}</span>
                      )}
                    </div>
                    {(paper.tldr || paper.abstract) && (
                      <Collapsible>
                        <CollapsibleTrigger asChild>
                          <Button variant="ghost" size="sm" className="px-0">
                            <ChevronDown />
                            摘要
                          </Button>
                        </CollapsibleTrigger>
                        <CollapsibleContent className="space-y-3 pt-2">
                          {paper.tldr && (
                            <p className="whitespace-pre-wrap break-words text-sm leading-7">
                              {paper.tldr}
                            </p>
                          )}
                          {paper.abstract && (
                            <p className="whitespace-pre-wrap break-words text-sm leading-7 text-muted-foreground">
                              {paper.abstract}
                            </p>
                          )}
                        </CollapsibleContent>
                      </Collapsible>
                    )}
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <PaperLinks
                        pmid={paper.pmid}
                        doi={paper.doi}
                        pdf={paper.open_access_pdf}
                      />
                      {(paper.pmcid || paper.pmid || paper.doi) && (
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setOpened(paper)}
                        >
                          <BookOpen />
                          查看全文目录
                        </Button>
                      )}
                    </div>
                  </article>
                ))
              ) : (
                <EmptyState title="未找到符合条件的文献" />
              )}
            </section>
          )
        ))}
      {opened && (
        <FulltextDialog
          key={opened.pmcid || opened.pmid || opened.doi}
          paper={opened}
          onClose={() => setOpened(null)}
        />
      )}
    </div>
  )
}
