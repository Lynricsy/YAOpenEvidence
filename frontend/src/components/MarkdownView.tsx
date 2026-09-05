import ReactMarkdown, { type Components } from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeRaw from 'rehype-raw'
import rehypeSanitize, { defaultSchema } from 'rehype-sanitize'
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
}: {
  markdown: string
  components?: Components
}) {
  return (
    <div className="markdown-view">
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
