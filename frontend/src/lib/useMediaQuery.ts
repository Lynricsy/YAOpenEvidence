import { useCallback, useSyncExternalStore } from 'react'

/** 与 Tailwind 默认断点一致的媒体查询串，供布局分支复用。 */
export const BREAKPOINTS = {
  md: '(min-width: 768px)',
  lg: '(min-width: 1024px)',
  xl: '(min-width: 1280px)',
  '2xl': '(min-width: 1536px)',
} as const

/**
 * 订阅媒体查询结果。基于 `useSyncExternalStore`，避免首帧读取后再 setState 造成的闪烁。
 */
export function useMediaQuery(query: string): boolean {
  const subscribe = useCallback(
    (onStoreChange: () => void) => {
      const media = matchMedia(query)
      media.addEventListener('change', onStoreChange)
      return () => media.removeEventListener('change', onStoreChange)
    },
    [query],
  )
  const getSnapshot = useCallback(() => matchMedia(query).matches, [query])
  return useSyncExternalStore(subscribe, getSnapshot, () => false)
}
