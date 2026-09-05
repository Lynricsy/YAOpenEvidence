import { Composer, type ComposerProps } from './Composer'

export function ComposerDock(props: Omit<ComposerProps, 'variant'>) {
  return (
    <div className="shrink-0 border-t bg-background/85 px-4 pt-3 pb-3 backdrop-blur md:px-8">
      <div className="mx-auto max-w-[760px]">
        <Composer variant="dock" {...props} />
        <p className="mt-2 text-center text-[11px] text-muted-foreground">
          仅供科研与教学参考，不构成医疗建议
        </p>
      </div>
    </div>
  )
}
