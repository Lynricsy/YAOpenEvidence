import { useId } from 'react'
import type { YearState } from '@/lib/filters'
import { validYears } from '@/lib/filters'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
export function YearPicker({
  value,
  onChange,
}: {
  value: YearState
  onChange: (value: Partial<YearState>) => void
}) {
  const id = useId()
  const selected =
    value.yearMode === 'recent' ? String(value.years) : value.yearMode
  return (
    <div className="space-y-3">
      <ToggleGroup
        type="single"
        value={selected}
        onValueChange={(v) => {
          if (!v) return
          onChange(
            v === 'any' || v === 'range'
              ? { yearMode: v }
              : { yearMode: 'recent', years: Number(v) },
          )
        }}
        spacing={1}
        className="flex w-full flex-wrap justify-start gap-1.5"
      >
        {[
          ['any', '不限'],
          ['3', '近 3 年'],
          ['5', '近 5 年'],
          ['10', '近 10 年'],
          ['range', '自定义'],
        ].map(([v, label]) => (
          <ToggleGroupItem className="chip" key={v} value={v}>
            {label}
          </ToggleGroupItem>
        ))}
      </ToggleGroup>
      {value.yearMode === 'range' && (
        <>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <Label htmlFor={id + '-from'}>从</Label>
              <Input
                id={id + '-from'}
                aria-label="起始年份"
                type="number"
                min={1900}
                max={new Date().getFullYear()}
                value={value.yearFrom ?? ''}
                aria-invalid={!validYears(value)}
                onChange={(e) =>
                  onChange({
                    yearFrom: e.target.value ? Number(e.target.value) : null,
                  })
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor={id + '-to'}>到</Label>
              <Input
                id={id + '-to'}
                aria-label="结束年份"
                placeholder="至今"
                type="number"
                min={1900}
                max={new Date().getFullYear()}
                value={value.yearTo ?? ''}
                aria-invalid={!validYears(value)}
                onChange={(e) =>
                  onChange({
                    yearTo: e.target.value ? Number(e.target.value) : null,
                  })
                }
              />
            </div>
          </div>
          {!validYears(value) && (
            <p className="text-xs text-danger">
              请填写有效起始年，结束年不得早于起始年。
            </p>
          )}
        </>
      )}
    </div>
  )
}
