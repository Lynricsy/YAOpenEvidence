import { cn } from 'cn'

// 跟随应用的 .dark 类而非系统媒体查询，确保手动主题优先；预载双图避免换色闪烁。
export function BrandLogo({
  size = 32,
  label = '',
  className,
}: {
  /** 边长（像素），浅深两份资源共用 */
  size?: number
  /** 无障碍名称；留空表示纯装饰，由相邻的品牌文字承担朗读 */
  label?: string
  className?: string
}) {
  return (
    <>
      <img
        src="/brand/logo-light.svg"
        alt={label}
        width={size}
        height={size}
        className={cn('block shrink-0 dark:hidden', className)}
      />
      <img
        src="/brand/logo-dark.svg"
        alt={label}
        width={size}
        height={size}
        className={cn('hidden shrink-0 dark:block', className)}
      />
    </>
  )
}
