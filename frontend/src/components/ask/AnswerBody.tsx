import {
  Children,
  cloneElement,
  createContext,
  isValidElement,
  useContext,
  type ComponentProps,
} from 'react'
import type { Components } from 'react-markdown'
import type { components } from '@/api/schema'
import { useAnswerMarkdown } from '@/api/queries'
import { problemMessage } from '@/api/errors'
import {
  ANSWER_MD_LINK_RE,
  markersToLinks,
  parseCiteHref,
} from '@/lib/citations'
import { hasKnownSections, splitAnswerSections } from '@/lib/answerSections'
import { MarkdownView } from '@/components/common/MarkdownView'
import { Skeleton } from '@/components/ui/skeleton'
import { CitationChip } from './CitationChip'
import { SectionHeading } from './SectionHeading'

/** hast 节点的最小结构，只用到遍历表头需要的字段。 */
type MdNode = {
  type?: string
  tagName?: string
  value?: string
  children?: MdNode[]
}

function nodeText(node: MdNode): string {
  return node.type === 'text'
    ? (node.value ?? '')
    : (node.children ?? []).map(nodeText).join('')
}

/** PICOS 表的表头文字，窄屏下作为每张卡里各字段的标签（不写死 P/I/C/O/S）。 */
const PicosHeaders = createContext<string[]>([])

function PicosRow({
  node: _node,
  children,
  ...props
}: ComponentProps<'tr'> & { node?: unknown }) {
  const headers = useContext(PicosHeaders)
  let column = 0
  return (
    <tr {...props}>
      {Children.map(children, (child) =>
        // 单元格之间夹着 "\n" 文本节点，只对元素计列。
        isValidElement(child)
          ? cloneElement(child, {
              'data-label': headers[column++],
            } as object)
          : child,
      )}
    </tr>
  )
}

/** PICOS 表专用覆写：宽屏描边表格，窄屏由 CSS 依 `data-label` 拆成每篇一张卡。 */
const picosComponents: Components = {
  table: ({ node, children }) => {
    const thead = (node as MdNode | undefined)?.children?.find(
      (child) => child.tagName === 'thead',
    )
    const row = thead?.children?.find((child) => child.tagName === 'tr')
    const headers = (row?.children ?? [])
      .filter((child) => child.tagName === 'th')
      .map(nodeText)
    return (
      <PicosHeaders value={headers}>
        <div className="picos-table">
          <table>{children}</table>
        </div>
      </PicosHeaders>
    )
  },
  tr: PicosRow,
  td: ({ node: _node, ...props }) => <td {...props} />,
  th: ({ node: _node, ...props }) => <th {...props} />,
}

export function AnswerBody({
  answer,
  onOpen,
}: {
  answer: components['schemas']['Answer']
  onOpen: (n: number, pid: number | null) => void
}) {
  const legacy = useAnswerMarkdown(
    answer.id,
    answer.body_md == null && answer.status === 'ready',
  )
  const papers = answer.papers ?? [],
    citations = answer.citations ?? []
  const markdown =
    answer.body_md != null
      ? markersToLinks(answer.body_md, Math.max(0, ...papers.map((p) => p.n)))
      : (legacy.data ?? '')
  // 引用标记的链接化必须在切分之前完成：切分后各节分别转换会丢失全文 mdast 上下文。
  const sections = splitAnswerSections(markdown)
  const cite: Components = {
    a: ({ href, children }) => {
      const parsed = parseCiteHref(href ?? '')
      const old = ANSWER_MD_LINK_RE.exec(href ?? '')
      const ref =
        parsed ??
        (old
          ? { n: Number(old[1]), pid: old[2] ? Number(old[2]) : null }
          : null)
      return ref ? (
        <CitationChip
          {...ref}
          papers={papers}
          citations={citations}
          onOpen={onOpen}
        />
      ) : (
        <a href={href} target="_blank" rel="noreferrer">
          {children}
        </a>
      )
    },
  }
  return (
    <section className="space-y-10">
      {legacy.isFetching && !legacy.data && answer.body_md == null ? (
        <Skeleton className="h-60 w-full" />
      ) : legacy.error && answer.body_md == null ? (
        <p className="error-panel">{problemMessage(legacy.error)}</p>
      ) : hasKnownSections(sections) ? (
        sections.map((section, index) => {
          if (section.kind === 'other')
            return (
              <MarkdownView
                key={index}
                markdown={section.markdown}
                className="prose-answer"
                components={cite}
              />
            )
          if (section.kind === 'conclusion')
            return (
              <section
                key={index}
                data-kind="conclusion"
                className="answer-conclusion rounded-xl border border-primary/20 bg-primary/[0.06] p-5 md:p-6 dark:bg-primary/10"
              >
                <SectionHeading module="conclusion" rule={false} />
                <MarkdownView
                  markdown={section.markdown}
                  className="prose-answer mt-3"
                  components={cite}
                />
              </section>
            )
          const bodyRows =
            section.kind === 'picos'
              ? section.markdown
                  .split('\n')
                  .filter((line) => line.trim().startsWith('|')).length - 2
              : 0
          return (
            <section
              key={index}
              data-kind={section.kind}
              className="answer-section"
            >
              <SectionHeading
                module={section.kind}
                count={bodyRows > 0 ? `${bodyRows} 篇` : undefined}
              />
              <MarkdownView
                markdown={section.markdown}
                className="prose-answer mt-4"
                components={
                  section.kind === 'picos'
                    ? { ...cite, ...picosComponents }
                    : cite
                }
              />
            </section>
          )
        })
      ) : (
        <MarkdownView
          markdown={markdown}
          className="prose-answer"
          components={cite}
        />
      )}
    </section>
  )
}
