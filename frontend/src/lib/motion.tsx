import { LazyMotion, MotionConfig } from 'motion/react'
import type { ReactNode } from 'react'

/** 统一缓动曲线（ease-out-quint 近似），全站动画共用。 */
export const ease = [0.22, 1, 0.36, 1] as const

/** 上浮淡入；`custom` 传列表下标即得错落延迟（最多累积 8 项）。 */
export const fadeUp = {
  hidden: { opacity: 0, y: 8 },
  show: (i: number = 0) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.28, ease, delay: Math.min(i, 8) * 0.04 },
  }),
}

/** 纯淡入，用于不希望有位移的容器。 */
export const fade = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition: { duration: 0.2, ease } },
}

/**
 * 全站动画上下文：特性包异步加载（首屏只带 motion 的精简运行时），
 * `reducedMotion="user"` 让系统「减少动效」偏好直接关掉位移动画。
 * 配合 `strict` 强制所有动画元素使用 `motion/react-m`，避免误引入完整包。
 */
export function MotionProvider({ children }: { children: ReactNode }) {
  return (
    <LazyMotion
      features={() => import('./motion-features').then((mod) => mod.default)}
      strict
    >
      <MotionConfig reducedMotion="user">{children}</MotionConfig>
    </LazyMotion>
  )
}
