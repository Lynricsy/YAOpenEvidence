import type { ComponentProps } from 'react'
import { cn } from 'cn'

export type Tone =
  'neutral' | 'info' | 'success' | 'warning' | 'danger' | 'primary'

/**
 * 统一的语义色小标签。`tone` 通过 `data-tone` 映射到 `--tone`；
 * 需要自定义色（分区、引用编号）时由调用方内联 `style={{ '--tone': … }}` 覆盖。
 */
export function Pill({
  tone = 'neutral',
  className,
  ...props
}: ComponentProps<'span'> & { tone?: Tone }) {
  return <span data-tone={tone} className={cn('pill', className)} {...props} />
}
