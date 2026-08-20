'use client'

import { useEffect, useRef, useState } from 'react'
import { CheckCircle, XCircle, ArrowRight, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'
import { checkAnswer } from '@/lib/quiz'
import { useEnterToContinue } from '@/hooks/use-enter-to-continue'
import type { AnswerState, Question } from '@/lib/quiz'

const KIND_HEADING: Record<Question['kind'], string> = {
  vi2ja: 'Gõ từ tiếng Nhật',
  ja2vi: 'Từ này nghĩa là gì?',
  reading: 'Từ này đọc thế nào?',
  writing: 'Từ này viết bằng kanji thế nào?',
}

interface Props {
  questions: Question[]
  index: number
  states: AnswerState[]
  onAnswered: (state: Exclude<AnswerState, 'pending'>, given: string) => void
  onNext: () => void
  onQuit: () => void
}

export function QuizRunner({
  questions,
  index,
  states,
  onAnswered,
  onNext,
  onQuit,
}: Props) {
  const [given, setGiven] = useState('')
  const [revealed, setRevealed] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)

  const q = questions[index]

  // Ô gõ nhận con trỏ ngay khi vào câu — không thì mỗi câu phải bấm một lần
  // vào ô trước khi gõ được.
  //
  // KHÔNG đặt lại `given`/`revealed` ở đây. Cha truyền `key` theo chỉ số câu
  // nên React dựng lại component mỗi câu, state tự sạch — gọi setState trong
  // effect thì thừa một lượt vẽ và eslint bắt đúng.
  useEffect(() => {
    if (q && !q.options) {
      const t = setTimeout(() => inputRef.current?.focus(), 50)
      return () => clearTimeout(t)
    }
  }, [q])

  useEnterToContinue(revealed, onNext)

  if (!q) return null

  const done = states.filter((s) => s !== 'pending').length
  const isLast = states.filter((s) => s === 'pending').length <= 1

  function submit(answer: string) {
    if (revealed || !answer.trim()) return
    const ok = checkAnswer(q, answer)
    setGiven(answer)
    setRevealed(true)
    onAnswered(ok ? 'correct' : 'wrong', answer)
  }

  function skip() {
    if (revealed) return
    setRevealed(true)
    onAnswered('skipped', '')
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-3">
        <div className="flex-1 space-y-1.5">
          <div className="flex justify-between text-xs text-muted-foreground">
            <span>
              {done} / {questions.length}
            </span>
          </div>
          <Progress
            value={(done / questions.length) * 100}
            className="h-1.5"
          />
        </div>
        {/* Thoát giữa chừng phải được, và điểm chốt tại đó. */}
        <button
          onClick={onQuit}
          aria-label="Dừng phiên"
          className="rounded-md p-1.5 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      <div className="rounded-2xl border bg-card p-6 space-y-5">
        <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          {KIND_HEADING[q.kind]}
        </span>

        <p
          className={cn(
            'font-medium leading-relaxed',
            q.kind === 'ja2vi' || q.kind === 'reading' || q.kind === 'writing'
              ? 'text-3xl font-japanese'
              : 'text-lg',
          )}
        >
          {q.prompt}
        </p>

        {q.hint && !revealed && (
          <p className="text-sm text-muted-foreground">{q.hint}</p>
        )}

        {q.options ? (
          <div className="grid gap-2">
            {q.options.map((opt) => {
              const isAnswer = opt === q.answer
              const isChosen = opt === given
              return (
                <button
                  key={opt}
                  onClick={() => submit(opt)}
                  disabled={revealed}
                  className={cn(
                    'text-left rounded-xl border px-4 py-3 text-sm font-medium transition-colors',
                    !revealed && 'hover:bg-accent hover:border-primary',
                    // Sau khi chấm: tô xanh đáp án đúng, tô đỏ ĐÚNG ô đã chọn
                    // sai. Không tô đỏ ba ô còn lại — người học cần thấy MÌNH
                    // chọn gì, không phải thấy ba ô đỏ vô danh.
                    revealed &&
                      isAnswer &&
                      'border-green-500 bg-green-50 dark:bg-green-900/20',
                    revealed &&
                      !isAnswer &&
                      isChosen &&
                      'border-red-500 bg-red-50 dark:bg-red-900/20',
                  )}
                >
                  <span className={cn(q.kind !== 'ja2vi' && 'font-japanese')}>
                    {opt}
                  </span>
                </button>
              )
            })}
          </div>
        ) : (
          !revealed && (
            <div className="space-y-3">
              <input
                ref={inputRef}
                type="text"
                value={given}
                onChange={(e) => setGiven(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') submit(given)
                }}
                placeholder="Nhập bằng kana…"
                className="w-full rounded-xl border bg-background px-4 py-3 text-center text-base font-japanese focus:outline-none focus:ring-2 focus:ring-ring"
                autoComplete="off"
                autoCapitalize="none"
                autoCorrect="off"
              />
              <Button
                onClick={() => submit(given)}
                disabled={!given.trim()}
                className="w-full"
              >
                Kiểm tra
              </Button>
            </div>
          )
        )}

        {revealed && <Verdict question={q} given={given} />}
      </div>

      {revealed ? (
        <Button onClick={onNext} className="w-full gap-2">
          {isLast ? 'Xem kết quả' : 'Câu tiếp theo'}
          <ArrowRight className="h-4 w-4" />
        </Button>
      ) : (
        <Button onClick={skip} variant="outline" className="w-full">
          Bỏ qua câu này
        </Button>
      )}
    </div>
  )
}

/** Phần chấm điểm hiện sau khi trả lời — luôn nói ra đáp án đúng. */
function Verdict({ question, given }: { question: Question; given: string }) {
  const ok = given.trim() !== '' && checkAnswer(question, given)
  const skipped = given.trim() === ''

  return (
    <div
      className={cn(
        'flex items-start gap-3 rounded-xl p-4',
        ok
          ? 'bg-green-50 border border-green-200 dark:bg-green-900/20 dark:border-green-800'
          : 'bg-red-50 border border-red-200 dark:bg-red-900/20 dark:border-red-800',
      )}
    >
      {ok ? (
        <CheckCircle className="h-5 w-5 text-green-600 shrink-0 mt-0.5" />
      ) : (
        <XCircle className="h-5 w-5 text-red-500 shrink-0 mt-0.5" />
      )}
      <div className="space-y-1">
        <p
          className={cn(
            'font-semibold',
            ok
              ? 'text-green-700 dark:text-green-400'
              : 'text-red-600 dark:text-red-400',
          )}
        >
          {ok ? 'Đúng rồi!' : skipped ? 'Đã bỏ qua' : 'Chưa đúng'}
        </p>
        <p className="text-sm">
          <span className="text-muted-foreground">Đáp án: </span>
          <span className="font-japanese font-medium">{question.answer}</span>
        </p>
        {/* Luôn hiện đủ ba mặt của từ sau khi chấm — đây là lúc người học
            thật sự nhìn vào nó. */}
        <p className="text-xs text-muted-foreground">
          <span className="font-japanese">{question.word.word}</span>
          {question.word.word !== question.word.reading && (
            <>
              {' · '}
              <span className="font-japanese">{question.word.reading}</span>
            </>
          )}
          {' · '}
          {question.word.meaning}
        </p>
      </div>
    </div>
  )
}
