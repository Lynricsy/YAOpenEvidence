import type { ComponentProps } from 'react'
import { cn } from 'cn'
import { TabsList, TabsTrigger } from '@/components/ui/tabs'

/**
 * 下划线式选项卡外观。shadcn 的 TabsList/TabsTrigger 基类里含带变体前缀的
 * 高度与边框，必须用同前缀的类才能覆盖，故这里显式列出 `group-data-…:h-auto`
 * 与 `dark:data-[state=active]:…`。
 */
export function TabsListUnderline({
  className,
  ...props
}: ComponentProps<typeof TabsList>) {
  return (
    <TabsList
      className={cn(
        'h-auto w-full justify-start gap-5 rounded-none border-b bg-transparent p-0 group-data-[orientation=horizontal]/tabs:h-auto',
        className,
      )}
      {...props}
    />
  )
}

export function TabsTriggerUnderline({
  className,
  ...props
}: ComponentProps<typeof TabsTrigger>) {
  return (
    <TabsTrigger
      className={cn(
        'h-auto flex-none rounded-none border-0 border-b-2 border-transparent px-0 pb-2.5 text-sm text-muted-foreground',
        'data-[state=active]:border-primary data-[state=active]:bg-transparent data-[state=active]:text-foreground data-[state=active]:shadow-none',
        'dark:data-[state=active]:border-primary dark:data-[state=active]:bg-transparent dark:data-[state=active]:text-foreground',
        className,
      )}
      {...props}
    />
  )
}
