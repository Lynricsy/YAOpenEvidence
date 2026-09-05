import { useLayoutEffect, type RefObject } from 'react'
import { Loader2, Send } from 'lucide-react'
import { Button } from './ui/button'
import { Textarea } from './ui/textarea'
export function QuestionInput({
  value,
  onChange,
  onSubmit,
  pending,
  disabled,
  inputRef,
}: {
  value: string
  onChange: (value: string) => void
  onSubmit: () => void
  pending: boolean
  disabled: boolean
  inputRef: RefObject<HTMLTextAreaElement | null>
}) {
  useLayoutEffect(() => {
    const el = inputRef.current
    if (el) {
      el.style.height = 'auto'
      el.style.height = Math.min(el.scrollHeight, 176) + 'px'
    }
  }, [value, inputRef])
  const blocked =
    disabled || pending || !value.trim() || value.trim().length > 2000
  return (
    <div className="shrink-0 border-t bg-background/95 px-5 py-4 backdrop-blur md:px-10">
      <form
        className="mx-auto max-w-4xl rounded-lg border bg-card p-3 shadow-xs focus-within:border-primary/60"
        onSubmit={(e) => {
          e.preventDefault()
          if (!blocked) onSubmit()
        }}
      >
        <Textarea
          ref={inputRef}
          aria-label="临床或科研问题"
          rows={1}
          maxLength={2000}
          className="min-h-12 resize-none border-0 bg-transparent p-1 shadow-none focus-visible:ring-0"
          placeholder="输入临床或科研问题，例如：SGLT2抑制剂对HFpEF患者有什么获益？"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onKeyDown={(e) => {
            if (
              e.key === 'Enter' &&
              !e.shiftKey &&
              !e.nativeEvent.isComposing &&
              e.nativeEvent.keyCode !== 229
            ) {
              e.preventDefault()
              if (!blocked) onSubmit()
            }
          }}
        />
        <div className="mt-1 flex items-center justify-between">
          <span className="text-[11px] text-muted-foreground">
            仅供科研与教学参考，不构成医疗建议
          </span>
          <div className="flex items-center gap-3">
            <span className="font-mono text-[11px] text-muted-foreground">
              {value.length}/2000
            </span>
            <Button
              type="submit"
              size="icon-sm"
              aria-label="提交问题"
              title="提交问题"
              disabled={blocked}
            >
              {pending ? <Loader2 className="animate-spin" /> : <Send />}
            </Button>
          </div>
        </div>
      </form>
    </div>
  )
}
