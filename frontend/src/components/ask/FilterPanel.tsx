import {
  ChevronDown,
  Info,
  RotateCcw,
  SlidersHorizontal,
  X,
} from 'lucide-react'
import type { CSSProperties } from 'react'
import {
  DEFAULT_FILTERS,
  describeFilters,
  type FilterState,
} from '@/lib/filters'
import { BREAKPOINTS, useMediaQuery } from '@/lib/useMediaQuery'
import { Button } from '@/components/ui/button'
import { Switch } from '@/components/ui/switch'
import { Slider } from '@/components/ui/slider'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { YearPicker } from './YearPicker'
import { JournalPicker } from './JournalPicker'
import { usePaywallStatus, useRankTables } from '@/api/queries'
import { dateTime } from '@/lib/format'

export type FilterPanelProps = {
  value: FilterState
  onChange: (value: FilterState) => void
}

/** 分区筛选的依据：没有表时 Q1–Q4 不会生效，必须说出来。 */
function RankTablesNote() {
  const { data } = useRankTables()
  if (!data) return null
  if (!data.tables.length)
    return (
      <p role="alert" className="text-xs text-warning">
        未加载分区表，Q1–Q4 筛选不会生效
      </p>
    )
  return (
    <p className="text-xs text-muted-foreground">
      分区依据：
      {data.tables
        .map(
          (t) =>
            (t.source === 'scimago' ? 'SCImago' : t.file) +
            (t.year ? ' ' + t.year : '') +
            '（' +
            t.journals.toLocaleString() +
            ' 刊）',
        )
        .join('，')}
    </p>
  )
}

/** 机构订阅登录态：决定付费全文能不能取到，只读展示。 */
function PaywallNote() {
  const { data } = usePaywallStatus()
  if (!data) return null
  let site = data.final_url ?? ''
  try {
    if (site) site = new URL(site).hostname
  } catch {
    /* context.json 里可能是手写的非法 URL，原样显示 */
  }
  const text = !data.playwright_available
    ? '不可用（服务端未安装浏览器）'
    : !data.configured
      ? '未配置，付费全文将回退到摘要'
      : '已配置 · ' + dateTime(data.saved_at) + (site ? ' · ' + site : '')
  return (
    <div className="flex items-start justify-between gap-2 text-xs">
      <span>机构访问</span>
      <span className="text-right text-muted-foreground">{text}</span>
    </div>
  )
}

export function FilterForm({ value: f, onChange }: FilterPanelProps) {
  const update = (patch: Partial<FilterState>) => onChange({ ...f, ...patch })
  const isCodex = f.engine === 'codex'
  return (
    <div className="px-5">
      <section className="space-y-3 border-b py-5">
        <h3 className="section-label">引擎</h3>
        <ToggleGroup
          type="single"
          value={f.engine}
          onValueChange={(v) =>
            v && update({ engine: v as FilterState['engine'] })
          }
          spacing={1}
          className="flex w-full gap-1.5"
        >
          <ToggleGroupItem
            className="chip flex-1"
            value="ask"
            aria-label="流水线引擎"
          >
            流水线
          </ToggleGroupItem>
          <ToggleGroupItem
            className="chip flex-1"
            value="codex"
            aria-label="Codex agent 引擎"
          >
            Codex agent
          </ToggleGroupItem>
        </ToggleGroup>
        <p className="text-xs text-muted-foreground">
          {isCodex
            ? '模型自己决定调哪些检索工具，答案整篇给出，没有逐篇原文快照；字符预算与知识库命中数不生效。'
            : '固定流水线：检索 → 取全文 → 逐篇阅读 → 综合，产出可逐条溯源的原文快照。'}
        </p>
      </section>
      <section className="space-y-3 border-b py-5">
        <h3 className="section-label">期刊分区</h3>
        <ToggleGroup
          type="multiple"
          value={f.quartiles.map(String)}
          onValueChange={(v) =>
            update({ quartiles: v.map(Number).sort((a, b) => a - b) })
          }
          spacing={1}
          className="flex w-full flex-wrap justify-start gap-1.5"
        >
          {[1, 2, 3, 4].map((q) => (
            <ToggleGroupItem
              key={q}
              className="chip"
              value={String(q)}
              aria-label={q + '区 Q' + q}
            >
              <span
                className="size-1.5 rounded-full"
                style={{ background: 'var(--q' + q + ')' } as CSSProperties}
              />
              Q{q} · {q}区
            </ToggleGroupItem>
          ))}
        </ToggleGroup>
        <label
          className={
            'flex items-center justify-between gap-2 text-xs ' +
            (!f.quartiles.length || isCodex ? 'text-muted-foreground' : '')
          }
        >
          含未收录期刊
          <Switch
            aria-label="含未收录期刊"
            checked={f.keepUnranked}
            disabled={!f.quartiles.length || isCodex}
            onCheckedChange={(v) => update({ keepUnranked: v })}
          />
        </label>
        <RankTablesNote />
      </section>
      <section className="space-y-3 border-b py-5">
        <h3 className="section-label">年份</h3>
        <YearPicker value={f} onChange={update} />
      </section>
      <section className="space-y-3 border-b py-5">
        <h3 className="section-label flex items-center justify-between">
          期刊家族（含子刊）
          <Tooltip>
            <TooltipTrigger asChild>
              <button type="button" aria-label="期刊家族匹配规则">
                <Info className="size-3.5" />
              </button>
            </TooltipTrigger>
            <TooltipContent className="max-w-64">
              按期刊名子串匹配，如 Nature 同时命中 Nature Medicine 等子刊
            </TooltipContent>
          </Tooltip>
        </h3>
        <JournalPicker
          value={f.journals}
          onChange={(journals) => update({ journals })}
        />
      </section>
      <Collapsible className="py-5">
        <CollapsibleTrigger className="flex w-full items-center justify-between py-1 text-sm text-muted-foreground transition-colors hover:text-foreground [&[data-state=open]>svg]:rotate-180">
          高级
          <ChevronDown className="size-4 transition-transform" />
        </CollapsibleTrigger>
        <CollapsibleContent className="space-y-6 pt-5">
          <div className="space-y-3">
            <div className="flex items-center justify-between text-xs">
              阅读篇数
              <span className="font-mono tabular-nums text-primary">
                {f.papers} 篇
              </span>
            </div>
            <Slider
              aria-label="阅读篇数"
              min={1}
              max={30}
              step={1}
              value={[f.papers]}
              onValueChange={([papers]) => update({ papers })}
            />
          </div>
          <label className="flex items-center justify-between gap-2 text-xs">
            写入并使用知识库
            <Switch
              aria-label="写入并使用知识库"
              checked={f.useKb}
              onCheckedChange={(useKb) => update({ useKb })}
            />
          </label>
          <div className="space-y-3">
            <div className="flex justify-between text-xs">
              附加知识库命中
              <span className="font-mono tabular-nums">{f.kbHits}</span>
            </div>
            <Slider
              aria-label="附加知识库命中"
              min={0}
              max={20}
              step={1}
              value={[f.kbHits]}
              disabled={!f.useKb || isCodex}
              onValueChange={([kbHits]) => update({ kbHits })}
            />
          </div>
          <div className="space-y-2">
            <span className="text-xs">单篇字符预算</span>
            <Select
              value={String(f.maxChars)}
              disabled={isCodex}
              onValueChange={(v) => update({ maxChars: Number(v) })}
            >
              <SelectTrigger aria-label="单篇字符预算" className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {[12000, 20000, 28000, 40000, 60000].map((n) => (
                  <SelectItem value={String(n)} key={n}>
                    {n.toLocaleString()} 字符
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <PaywallNote />
        </CollapsibleContent>
      </Collapsible>
    </div>
  )
}

function ResetButton({ onChange }: Pick<FilterPanelProps, 'onChange'>) {
  return (
    <Button
      variant="ghost"
      size="xs"
      aria-label="重置筛选"
      onClick={() => onChange({ ...DEFAULT_FILTERS })}
    >
      <RotateCcw />
      重置
    </Button>
  )
}

function Summary({ value }: Pick<FilterPanelProps, 'value'>) {
  return (
    <p
      className="border-t px-5 py-3 text-xs leading-6 text-muted-foreground"
      data-testid="filter-summary"
    >
      {describeFilters(value)}
    </p>
  )
}

/** ≥xl 常驻的第二列筛选面板。 */
export function FilterColumn(props: FilterPanelProps) {
  return (
    <aside className="flex w-[288px] shrink-0 flex-col border-r bg-sidebar/50">
      <div className="flex h-14 items-center justify-between border-b px-5">
        <h2 className="flex items-center gap-2 text-sm font-semibold">
          <SlidersHorizontal className="size-4 text-primary" />
          文献筛选
        </h2>
        <ResetButton onChange={props.onChange} />
      </div>
      <div className="min-h-0 flex-1 overflow-y-auto">
        <FilterForm {...props} />
      </div>
      <Summary value={props.value} />
    </aside>
  )
}

/** 筛选列隐藏时的抽屉：≥md 从左侧滑出，移动端从底部升起。 */
export function FilterSheet({
  open,
  onOpenChange,
  ...props
}: FilterPanelProps & {
  open: boolean
  onOpenChange: (open: boolean) => void
}) {
  const isMd = useMediaQuery(BREAKPOINTS.md)
  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side={isMd ? 'left' : 'bottom'}
        showCloseButton={false}
        className={
          isMd
            ? 'flex w-[320px] flex-col gap-0 p-0 sm:max-w-none'
            : 'flex h-[85dvh] flex-col gap-0 rounded-t-2xl p-0'
        }
      >
        <SheetHeader className="flex h-14 shrink-0 flex-row items-center justify-between gap-2 border-b px-5 py-0">
          <SheetTitle className="flex items-center gap-2 text-sm">
            <SlidersHorizontal className="size-4 text-primary" />
            文献筛选
          </SheetTitle>
          <SheetDescription className="sr-only">
            调整下一次提问的文献筛选条件
          </SheetDescription>
          <span className="flex items-center gap-1">
            <ResetButton onChange={props.onChange} />
            <SheetClose asChild>
              <Button variant="ghost" size="icon-sm" aria-label="关闭筛选">
                <X />
              </Button>
            </SheetClose>
          </span>
        </SheetHeader>
        <div className="min-h-0 flex-1 overflow-y-auto">
          <FilterForm {...props} />
        </div>
        <Summary value={props.value} />
      </SheetContent>
    </Sheet>
  )
}
