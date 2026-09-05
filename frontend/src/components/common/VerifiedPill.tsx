import { Check, X } from 'lucide-react'
import { Pill } from './Pill'

export function VerifiedPill({ value }: { value?: boolean | null }) {
  if (value == null) return null
  return value ? (
    <Pill tone="success">
      <Check />
      已核实
    </Pill>
  ) : (
    <Pill tone="warning">
      <X />
      未核实
    </Pill>
  )
}
