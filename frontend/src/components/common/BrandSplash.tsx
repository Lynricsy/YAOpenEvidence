import { Loader2 } from 'lucide-react'
import { BrandLogo } from './BrandLogo'

// 启动与会话恢复共用固定尺寸品牌占位，状态文字仅供读屏。
export function BrandSplash({ label }: { label: string }) {
  return (
    <div role="status" className="grid min-h-dvh place-items-center">
      <div className="flex flex-col items-center gap-4">
        <BrandLogo size={56} />
        <Loader2 className="size-4 animate-spin text-muted-foreground" />
        <span className="sr-only">{label}</span>
      </div>
    </div>
  )
}
