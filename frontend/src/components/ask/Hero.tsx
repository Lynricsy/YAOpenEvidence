import { useEffect } from 'react'
import { useLocation } from 'react-router'
import { ArrowUpRight } from 'lucide-react'
import * as m from 'motion/react-m'
import { BrandLogo } from '@/components/common/BrandLogo'
import { fadeUp } from '@/lib/motion'
import { Composer, type ComposerProps } from './Composer'

const examples = [
  'SGLT2抑制剂对HFpEF患者有什么获益？',
  '替尔泊肽与司美格鲁肽在肥胖患者减重和心血管结局上的比较',
  '他汀类药物一级预防在老年人中的获益与风险',
]

export function Hero({
  onExample,
  ...composer
}: Omit<ComposerProps, 'variant'> & { onExample: (text: string) => void }) {
  const { state } = useLocation()
  const focusToken = (state as { focus?: number } | null)?.focus
  const { inputRef } = composer
  useEffect(() => {
    inputRef.current?.focus()
  }, [focusToken, inputRef])
  return (
    <div className="mx-auto flex min-h-full w-full max-w-2xl flex-col justify-center px-6 py-12">
      <m.div
        variants={fadeUp}
        initial="hidden"
        animate="show"
        custom={0}
        className="flex items-center gap-3"
      >
        <BrandLogo size={40} label="YAOpenEvidence" />
        <p className="text-xs font-medium tracking-wide text-primary">
          循证医学文献问答
        </p>
      </m.div>
      <m.h1
        variants={fadeUp}
        initial="hidden"
        animate="show"
        custom={1}
        className="mt-4 font-serif text-[32px] font-semibold leading-tight tracking-tight md:text-[40px]"
      >
        请提出您的临床或科研问题
      </m.h1>
      <m.p
        variants={fadeUp}
        initial="hidden"
        animate="show"
        custom={2}
        className="mt-3 max-w-xl text-[15px] leading-7 text-muted-foreground"
      >
        从 PubMed / Europe PMC 检索并逐篇核实，生成可回溯到原文段落的循证综述。
      </m.p>
      <div className="mt-8">
        <Composer variant="hero" {...composer} />
      </div>
      <div className="mt-8">
        <p className="section-label mb-3">试试这些问题</p>
        <div className="grid gap-2 sm:grid-cols-3">
          {examples.map((text, i) => (
            <m.button
              key={text}
              variants={fadeUp}
              initial="hidden"
              animate="show"
              custom={3 + i}
              type="button"
              onClick={() => onExample(text)}
              className="group relative rounded-lg border bg-card px-4 py-3 text-left text-[13px] leading-6 text-muted-foreground transition-all hover:-translate-y-px hover:border-primary/40 hover:text-foreground hover:shadow-sm"
            >
              {text}
              <ArrowUpRight className="absolute right-3 top-3 size-3.5 opacity-0 transition-opacity group-hover:opacity-100" />
            </m.button>
          ))}
        </div>
      </div>
      <p className="mt-10 text-center text-[11px] text-muted-foreground">
        仅供科研与教学参考，不构成医疗建议
      </p>
    </div>
  )
}
