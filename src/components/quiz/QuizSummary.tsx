'use client'

import { RotateCcw, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { tally } from '@/lib/quiz'
import type { AnswerState, Question } from '@/lib/quiz'

interface Props {
  questions: Question[]
  states: AnswerState[]
  answers: string[]
  onAgain: () => void
  onDone: () => void
}

/**
 * Tổng kết phiên.
 *
 * Hiện ĐỦ BỐN con số. Thoát giữa chừng thì phần chưa làm phải hiện ra chứ không
 * biến mất — app từng chỉ đếm đúng/sai và người dùng thấy tổng không khớp.
 */
export function QuizSummary({
  questions,
  states,
  answers,
  onAgain,
  onDone,
}: Props) {
  const t = tally(states)
  const graded = t.correct + t.wrong
  const pct = graded === 0 ? 0 : Math.round((t.correct / graded) * 100)

  const missed = questions
    .map((q, i) => ({ q, state: states[i], given: answers[i] }))
    .filter((x) => x.state === 'wrong' || x.state === 'skipped')

  return (
    <div className="space-y-6">
      <div className="text-center space-y-1">
        <p className="text-5xl font-bold tabular-nums">{t.correct}</p>
        <p className="text-sm text-muted-foreground">
          đúng trên {graded} câu đã làm
          {graded > 0 && ` · ${pct}%`}
        </p>
      </div>

      <div className="grid grid-cols-4 gap-2 text-center">
        <Stat label="Đúng" value={t.correct} tone="text-green-600" />
        <Stat label="Sai" value={t.wrong} tone="text-red-500" />
        <Stat label="Bỏ qua" value={t.skipped} tone="text-amber-600" />
        <Stat label="Chưa làm" value={t.pending} tone="text-muted-foreground" />
      </div>

      {missed.length > 0 && (
        <section className="space-y-2">
          <h3 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Xem lại {missed.length} câu
          </h3>
          <div className="space-y-2">
            {missed.map(({ q, state, given }) => (
              <div
                key={q.word.id + q.kind}
                className="rounded-xl border bg-card p-3 space-y-1"
              >
                <p className="font-japanese font-medium">{q.word.word}</p>
                <p className="text-xs text-muted-foreground">
                  <span className="font-japanese">{q.word.reading}</span>
                  {' · '}
                  {q.word.meaning}
                </p>
                <p className="text-xs">
                  <span className="text-green-600">Đáp án: </span>
                  <span className="font-japanese">{q.answer}</span>
                  {state === 'skipped' ? (
                    <span className="text-muted-foreground"> · đã bỏ qua</span>
                  ) : (
                    given && (
                      <span className="text-red-500">
                        {' · đã chọn: '}
                        <span className="font-japanese">{given}</span>
                      </span>
                    )
                  )}
                </p>
              </div>
            ))}
          </div>
        </section>
      )}

      <div className="flex gap-2">
        <Button onClick={onAgain} className="flex-1 gap-2">
          <RotateCcw className="h-4 w-4" /> Làm phiên mới
        </Button>
        <Button onClick={onDone} variant="outline" className="flex-1 gap-2">
          <Check className="h-4 w-4" /> Xong
        </Button>
      </div>
    </div>
  )
}

function Stat({
  label,
  value,
  tone,
}: {
  label: string
  value: number
  tone: string
}) {
  return (
    <div className="rounded-xl border bg-card py-3">
      <p className={cn('text-xl font-bold tabular-nums', tone)}>{value}</p>
      <p className="text-[11px] text-muted-foreground">{label}</p>
    </div>
  )
}
