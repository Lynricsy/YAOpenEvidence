import ReactMarkdown, { type Components } from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeRaw from 'rehype-raw'
import rehypeSanitize, { defaultSchema } from 'rehype-sanitize'
import { cn } from 'cn'
const schema = {
  ...defaultSchema,
  tagNames: [...(defaultSchema.tagNames ?? []), 'mark'],
  attributes: {
    ...defaultSchema.attributes,
    a: [...(defaultSchema.attributes?.a ?? []), ['id', /^p\d+$/]],
  },
}
export function MarkdownView({
  markdown,
  components,
  className,
}: {
  markdown: string
  components?: Components
  /** 追加排版类，答案正文传 `prose-answer` 换用更宽松的阅读排版。 */
  className?: string
}) {
  return (
    <div className={cn('markdown-view', className)}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeRaw, [rehypeSanitize, schema]]}
        components={{
          a: ({ node: _node, ...props }) => (
            <a
              {...props}
              target={props.href?.startsWith('#') ? undefined : '_blank'}
              rel="noreferrer"
            />
          ),
          ...components,
        }}
      >
        {markdown}
      </ReactMarkdown>
    </div>
  )
}
