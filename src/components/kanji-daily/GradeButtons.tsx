'use client'

import { Check, RotateCcw } from 'lucide-react'

export function GradeButtons({ onGrade }: { onGrade: (remembered: boolean) => void }) {
  return (
    <div className="grid grid-cols-2 gap-2">
      <button
        type="button"
        onClick={() => onGrade(false)}
        className="inline-flex items-center justify-center gap-1.5 rounded-xl border px-4 py-3 font-medium text-rose-600 transition-colors hover:bg-rose-500/10 dark:text-rose-400"
      >
        <RotateCcw className="h-4 w-4" /> Quên
      </button>
      <button
        type="button"
        onClick={() => onGrade(true)}
        className="inline-flex items-center justify-center gap-1.5 rounded-xl border px-4 py-3 font-medium text-emerald-600 transition-colors hover:bg-emerald-500/10 dark:text-emerald-400"
      >
        <Check className="h-4 w-4" /> Nhớ
      </button>
    </div>
  )
}
