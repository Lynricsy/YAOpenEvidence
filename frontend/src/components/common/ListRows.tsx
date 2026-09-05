import type { ComponentProps } from 'react'
import * as m from 'motion/react-m'
import type { HTMLMotionProps } from 'motion/react'
import { cn } from 'cn'
import { fadeUp } from '@/lib/motion'

export function ListRows({ className, ...props }: ComponentProps<'ul'>) {
  return <ul className={cn('divide-y', className)} {...props} />
}

/** 列表行；`index` 决定错落进入的延迟。 */
export function ListRow({
  index,
  className,
  ...props
}: HTMLMotionProps<'li'> & { index: number }) {
  return (
    <m.li
      variants={fadeUp}
      initial="hidden"
      animate="show"
      custom={index}
      className={cn(
        'group -mx-3 rounded-lg px-3 py-4 transition-colors hover:bg-muted/50',
        className,
      )}
      {...props}
    />
  )
}
