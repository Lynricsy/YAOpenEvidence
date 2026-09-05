import { useId } from 'react'
import type { YearState } from '@/lib/filters'
import { validYears } from '@/lib/filters'
import { ToggleGroup, ToggleGroupItem } from './ui/toggle-group'
import { Input } from './ui/input'
import { Label } from './ui/label'
export function YearPicker({ value, onChange }: { value: YearState; onChange: (value: Partial<YearState>) => void }) {
  const id = useId()
  const selected = value.yearMode === 'recent' ? String(value.years) : value.yearMode
  return <div className="space-y-3"><ToggleGroup type="single" value={selected} onValueChange={v => { if (!v) return; onChange(v === 'any' || v === 'range' ? { yearMode: v } : { yearMode: 'recent', years: Number(v) }) }} spacing={1} className="flex w-full flex-wrap justify-start gap-1" size="sm">{[['any','不限'],['3','近3年'],['5','近5年'],['10','近10年'],['range','自定义']].map(([v,label]) => <ToggleGroupItem className="rounded-md border text-xs data-[state=on]:border-primary/30 data-[state=on]:bg-primary/10 data-[state=on]:text-primary" key={v} value={v}>{label}</ToggleGroupItem>)}</ToggleGroup>{value.yearMode === 'range' && <><div className="grid grid-cols-2 gap-3"><div className="space-y-2"><Label htmlFor={id + '-from'}>从</Label><Input id={id + '-from'} aria-label="起始年份" type="number" min={1900} max={new Date().getFullYear()} value={value.yearFrom ?? ''} aria-invalid={!validYears(value)} onChange={e => onChange({ yearFrom: e.target.value ? Number(e.target.value) : null })} /></div><div className="space-y-2"><Label htmlFor={id + '-to'}>到</Label><Input id={id + '-to'} aria-label="结束年份" placeholder="至今" type="number" min={1900} max={new Date().getFullYear()} value={value.yearTo ?? ''} aria-invalid={!validYears(value)} onChange={e => onChange({ yearTo: e.target.value ? Number(e.target.value) : null })} /></div></div>{!validYears(value) && <p className="text-xs text-destructive">请填写有效起始年，结束年不得早于起始年。</p>}</>}</div>
}
