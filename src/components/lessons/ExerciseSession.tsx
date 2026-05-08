'use client'

import { useState, useRef, useCallback, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'
import type { MnnExercise } from '@/types/database'
import { CheckCircle, XCircle, ArrowRight, RotateCcw } from 'lucide-react'

export interface ExerciseResult {
  exercise: MnnExercise
  userAnswer: string
  correct: boolean
}

interface Props {
  exercises: MnnExercise[]
  onComplete: (results: ExerciseResult[]) => void
}

type Phase = 'idle' | 'running' | 'feedback'

export function ExerciseSession({ exercises, onComplete }: Props) {
  const [phase, setPhase] = useState<Phase>('idle')
  const [index, setIndex] = useState(0)
  const [userAnswer, setUserAnswer] = useState('')
  const [feedback, setFeedback] = useState<'correct' | 'wrong' | null>(null)
  const [results, setResults] = useState<ExerciseResult[]>([])
  const inputRef = useRef<HTMLInputElement>(null)

  const current = exercises[index]

  useEffect(() => {
    if (phase === 'running' && current?.type === 'fill_blank') {
      setTimeout(() => inputRef.current?.focus(), 50)
    }
  }, [phase, index, current?.type])

  function startSession() {
    setPhase('running')
    setIndex(0)
    setUserAnswer('')
    setFeedback(null)
    setResults([])
  }

  const checkAnswer = useCallback((answer: string) => {
    if (!current) return
    const correct = answer.trim().toLowerCase() === current.answer.trim().toLowerCase()
    const result: ExerciseResult = { exercise: current, userAnswer: answer, correct }
    const newResults = [...results, result]
    setResults(newResults)
    setFeedback(correct ? 'correct' : 'wrong')
    setPhase('feedback')

    if (index + 1 >= exercises.length) {
      setTimeout(() => onComplete(newResults), 1200)
    }
  }, [current, results, index, exercises.length, onComplete])

  function next() {
    const nextIndex = index + 1
    if (nextIndex >= exercises.length) {
      onComplete(results)
      return
    }
    setIndex(nextIndex)
    setUserAnswer('')
    setFeedback(null)
    setPhase('running')
  }

  if (phase === 'idle') {
    return (
      <div className="flex flex-col items-center gap-6 py-8 text-center">
        <div className="text-5xl">✏️</div>
        <div className="space-y-1">
          <p className="font-semibold text-lg">{exercises.length} bài tập</p>
          <p className="text-sm text-muted-foreground">Gồm điền vào chỗ trống và chọn đáp án</p>
        </div>
        <Button onClick={startSession} size="lg" className="px-8">
          Bắt đầu luyện tập
        </Button>
      </div>
    )
  }

  if (!current) return null

  const progress = (index / exercises.length) * 100

  return (
    <div className="space-y-5">
      {/* Progress */}
      <div className="space-y-1.5">
        <div className="flex justify-between text-xs text-muted-foreground">
          <span>Câu {index + 1} / {exercises.length}</span>
          <span>{Math.round(progress)}%</span>
        </div>
        <Progress value={progress} className="h-1.5" />
      </div>

      {/* Exercise card */}
      <div className="rounded-2xl border bg-card p-6 space-y-5">
        {/* Type badge */}
        <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          {current.type === 'fill_blank' ? 'Điền vào chỗ trống' : 'Chọn đáp án đúng'}
        </span>

        {/* Question */}
        <p className="text-lg font-japanese font-medium leading-relaxed">{current.question}</p>

        {/* Input area */}
        {current.type === 'fill_blank' && phase === 'running' && (
          <div className="space-y-3">
            <input
              ref={inputRef}
              type="text"
              value={userAnswer}
              onChange={(e) => setUserAnswer(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter' && userAnswer.trim()) checkAnswer(userAnswer) }}
              placeholder="Nhập câu trả lời..."
              className="w-full rounded-xl border bg-background px-4 py-3 text-center text-base focus:outline-none focus:ring-2 focus:ring-ring font-japanese"
              autoComplete="off"
              autoCapitalize="none"
            />
            <Button
              onClick={() => checkAnswer(userAnswer)}
              disabled={!userAnswer.trim()}
              className="w-full"
            >
              Kiểm tra
            </Button>
          </div>
        )}

        {current.type === 'multiple_choice' && phase === 'running' && (
          <div className="grid grid-cols-1 gap-2">
            {(current.options as string[]).map((opt) => (
              <button
                key={opt}
                onClick={() => checkAnswer(opt)}
                className="text-left rounded-xl border px-4 py-3 text-sm font-medium hover:bg-accent hover:border-primary transition-colors"
              >
                {opt}
              </button>
            ))}
          </div>
        )}

        {/* Feedback */}
        {phase === 'feedback' && (
          <div className="space-y-4">
            <div className={cn(
              'flex items-start gap-3 rounded-xl p-4',
              feedback === 'correct'
                ? 'bg-green-50 border border-green-200 dark:bg-green-900/20 dark:border-green-800'
                : 'bg-red-50 border border-red-200 dark:bg-red-900/20 dark:border-red-800',
            )}>
              {feedback === 'correct'
                ? <CheckCircle className="h-5 w-5 text-green-600 shrink-0 mt-0.5" />
                : <XCircle className="h-5 w-5 text-red-500 shrink-0 mt-0.5" />}
              <div className="space-y-1">
                {feedback === 'correct'
                  ? <p className="font-semibold text-green-700 dark:text-green-400">Đúng rồi!</p>
                  : (
                    <div>
                      <p className="font-semibold text-red-600 dark:text-red-400">
                        Chưa đúng — đáp án: <span className="font-japanese">{current.answer}</span>
                      </p>
                    </div>
                  )}
                {current.explanation_vi && (
                  <p className="text-sm text-muted-foreground">{current.explanation_vi}</p>
                )}
              </div>
            </div>

            {index + 1 < exercises.length && (
              <Button onClick={next} className="w-full gap-2">
                <ArrowRight className="h-4 w-4" /> Câu tiếp theo
              </Button>
            )}
          </div>
        )}
      </div>

      {/* Restart */}
      <div className="text-center">
        <button
          onClick={startSession}
          className="text-xs text-muted-foreground hover:text-foreground flex items-center gap-1 mx-auto transition-colors"
        >
          <RotateCcw className="h-3 w-3" /> Bắt đầu lại
        </button>
      </div>
    </div>
  )
}
