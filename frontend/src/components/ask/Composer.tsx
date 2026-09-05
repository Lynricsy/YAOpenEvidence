import { useLayoutEffect, type RefObject } from 'react'
import { ArrowUp, Loader2, SlidersHorizontal } from 'lucide-react'
import * as m from 'motion/react-m'
import { cn } from 'cn'
import { ease } from '@/lib/motion'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'

export type ComposerProps = {
  variant: 'hero' | 'dock'
  value: string
  onChange: (value: string) => void
  onSubmit: () => void
  pending: boolean
  disabled: boolean
  inputRef: RefObject<HTMLTextAreaElement | null>
  filterSummary: string
  /** 为 null 表示筛选列常驻，芯片只作展示不可点击。 */
  onOpenFilters: (() => void) | null
}

export function Composer({
  variant,
  value,
  onChange,
  onSubmit,
  pending,
  disabled,
  inputRef,
  filterSummary,
  onOpenFilters,
}: ComposerProps) {
  const hero = variant === 'hero'
  useLayoutEffect(() => {
    const el = inputRef.current
    if (!el) return
    el.style.height = 'auto'
    el.style.height = Math.min(el.scrollHeight, hero ? 240 : 176) + 'px'
  }, [value, inputRef, hero])
  const blocked =
    disabled || pending || !value.trim() || value.trim().length > 2000
  const chipClass =
    'inline-flex h-7 max-w-[60%] items-center gap-1.5 rounded-md border px-2 text-xs text-muted-foreground'
  return (
    <m.form
      layoutId="composer"
      layout
      transition={{ layout: { duration: 0.32, ease } }}
      className={cn(
        'rounded-xl border bg-card shadow-sm transition-[box-shadow,border-color] focus-within:border-primary/50 focus-within:shadow-[0_0_0_4px_color-mix(in_oklch,var(--primary)_12%,transparent)]',
        hero ? 'p-4' : 'p-3',
      )}
      onSubmit={(event) => {
        event.preventDefault()
        if (!blocked) onSubmit()
      }}
    >
      <Textarea
        ref={inputRef}
        aria-label="临床或科研问题"
        rows={1}
        maxLength={2000}
        className={cn(
          'resize-none border-0 bg-transparent p-1 text-[15px] leading-7 shadow-none focus-visible:ring-0',
          hero ? 'min-h-[88px]' : 'min-h-[44px]',
        )}
        placeholder={
          hero
            ? '例如：SGLT2 抑制剂对 HFpEF 患者有什么获益？'
            : '追问或提出新问题…'
        }
        value={value}
        onChange={(event) => onChange(event.target.value)}
        onKeyDown={(event) => {
          if (
            event.key === 'Enter' &&
            !event.shiftKey &&
            !event.nativeEvent.isComposing &&
            event.nativeEvent.keyCode !== 229
          ) {
            event.preventDefault()
            if (!blocked) onSubmit()
          }
        }}
      />
      <div className="mt-2 flex items-center justify-between gap-3">
        {onOpenFilters ? (
          <button
            type="button"
            data-testid="filter-chip"
            onClick={onOpenFilters}
            className={cn(
              chipClass,
              'transition-colors hover:bg-accent/60 hover:text-foreground',
            )}
          >
            <SlidersHorizontal className="size-3.5 shrink-0" />
            <span className="truncate">{filterSummary}</span>
          </button>
        ) : (
          <span className={chipClass}>
            <SlidersHorizontal className="size-3.5 shrink-0" />
            <span className="truncate">{filterSummary}</span>
          </span>
        )}
        <div className="flex shrink-0 items-center gap-3">
          {value.length > 0 && (
            <span className="font-mono text-[11px] tabular-nums text-muted-foreground">
              {value.length}/2000
            </span>
          )}
          {hero ? (
            <Button type="submit" disabled={blocked}>
              提问
              {pending ? <Loader2 className="animate-spin" /> : <ArrowUp />}
            </Button>
          ) : (
            <Button
              type="submit"
              size="icon-sm"
              className="rounded-full"
              aria-label="提交问题"
              title="提交问题"
              disabled={blocked}
            >
              {pending ? <Loader2 className="animate-spin" /> : <ArrowUp />}
            </Button>
          )}
        </div>
      </div>
    </m.form>
  )
}
