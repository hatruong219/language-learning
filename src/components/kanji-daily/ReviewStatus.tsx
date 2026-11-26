'use client'

import { formatDate } from '@/lib/daily-kanji'
import { grade, stateOf } from '@/lib/kanji-srs'
import { saveSrsState, useSrsStates } from '@/lib/kanji-srs-store'
import { GradeButtons } from './GradeButtons'

/** Ở trang chi tiết: đến hạn thì cho chấm Nhớ / Quên, chưa thì báo ngày ôn tới. */
export function ReviewStatus({ k, index, today }: { k: string; index: number; today: string }) {
  const states = useSrsStates()
  if (!states) return null
  const state = stateOf(index, states[k])
  const due = state.due <= today

  return (
    <section className="rounded-2xl border bg-card p-4 space-y-3">
      <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Ôn tập</h2>
      {due ? (
        <>
          <p className="text-sm">Đến hạn ôn — còn nhớ nghĩa và cách đọc không?</p>
          <GradeButtons onGrade={(ok) => saveSrsState(k, grade(state, ok, today))} />
        </>
      ) : (
        <p className="text-sm text-muted-foreground">
          {state.lastReviewed === today ? 'Đã ôn hôm nay. ' : ''}
          Lần ôn tới: <span className="font-medium text-foreground">{formatDate(state.due)}</span>
          {state.reviews > 0 && ` · đã ôn ${state.reviews} lần`}
        </p>
      )}
    </section>
  )
}
