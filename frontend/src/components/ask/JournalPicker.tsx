import { useState } from 'react'
import { X } from 'lucide-react'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { api, dataOf } from '@/api/client'
const presets = [
  ['Nature', 'nature'],
  ['Lancet', 'lancet'],
  ['NEJM', 'new england'],
  ['JAMA', 'jama'],
  ['BMJ', 'bmj'],
  ['Cell', 'cell'],
]
export function JournalPicker({
  value,
  onChange,
}: {
  value: string[]
  onChange: (value: string[]) => void
}) {
  const [draft, setDraft] = useState('')
  // 自定义刊名是自由文本，输入时顺手查一次分区，让主人立刻知道拼对了没有
  const [labels, setLabels] = useState<Record<string, string>>({})
  const custom = value.filter((v) => !presets.some((p) => p[1] === v))
  return (
    <div className="space-y-3">
      <ToggleGroup
        type="multiple"
        value={value.filter((v) => !custom.includes(v))}
        onValueChange={(v) => onChange([...v, ...custom])}
        spacing={1}
        className="flex w-full flex-wrap justify-start gap-1.5"
      >
        {presets.map(([label, v]) => (
          <ToggleGroupItem className="chip" key={v} value={v}>
            {label}
          </ToggleGroupItem>
        ))}
      </ToggleGroup>
      <Input
        aria-label="其他期刊"
        placeholder="其他期刊，回车添加"
        maxLength={100}
        value={draft}
        onChange={(e) => setDraft(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' && !e.nativeEvent.isComposing) {
            e.preventDefault()
            const v = draft.trim().toLowerCase()
            if (v) {
              onChange([...new Set([...value, v])])
              setDraft('')
              void dataOf(
                api.GET('/v1/journals/rank', {
                  params: { query: { title: v } },
                }),
              )
                .then((r) => setLabels((l) => ({ ...l, [v]: r.label })))
                .catch(() => {})
            }
          }
        }}
      />
      {custom.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {custom.map((v) => (
            <span
              className="inline-flex h-7 max-w-full items-center gap-1 rounded-md border bg-muted/60 pr-0.5 pl-2 text-xs"
              key={v}
            >
              <span className="break-all">{v}</span>
              {labels[v] && (
                <span className="text-muted-foreground">· {labels[v]}</span>
              )}
              <Button
                type="button"
                variant="ghost"
                size="icon-xs"
                aria-label={'移除期刊 ' + v}
                onClick={() => onChange(value.filter((x) => x !== v))}
              >
                <X />
              </Button>
            </span>
          ))}
        </div>
      )}
    </div>
  )
}
