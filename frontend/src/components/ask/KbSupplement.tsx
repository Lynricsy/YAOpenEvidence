import { ChevronDown } from 'lucide-react'
import type { components } from '@/api/schema'
import { Pill } from '@/components/common/Pill'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { SectionHeading } from './SectionHeading'

/** 知识库补充：答案页最后一个模块，默认折叠，分节头整行作为触发器。 */
export function KbSupplement({
  hits,
}: {
  hits: components['schemas']['KbHit'][]
}) {
  return (
    <Collapsible>
      <CollapsibleTrigger asChild>
        <button type="button" className="group w-full text-left">
          <SectionHeading
            module="kb"
            titleAs="span"
            count={`${hits.length} 条`}
            trailing={
              <ChevronDown className="size-4 shrink-0 text-muted-foreground transition-transform group-data-[state=open]:rotate-180" />
            }
          />
        </button>
      </CollapsibleTrigger>
      <CollapsibleContent>
        {hits.map((hit, i) => (
          <article className="space-y-2 border-b py-4 last:border-b-0" key={i}>
            <div className="metadata">
              <Pill>{hit.kind === 'fact' ? '事实' : '段落'}</Pill>
              <span className="tabular-nums">
                相似度 {hit.score.toFixed(2)}
              </span>
            </div>
            <p className="text-sm leading-7">{hit.text}</p>
            {hit.text_zh && (
              <p className="text-sm text-muted-foreground">{hit.text_zh}</p>
            )}
            <p className="metadata">
              {hit.title} · {hit.journal} ({hit.year})
            </p>
          </article>
        ))}
      </CollapsibleContent>
    </Collapsible>
  )
}
