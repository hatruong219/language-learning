'use client'

import { useState } from 'react'
import { cn } from '@/lib/utils'
import { VocabSection } from './VocabSection'
import { GrammarSection } from './GrammarSection'
import { ExerciseSession, type ExerciseResult } from './ExerciseSession'
import type { MnnLessonFull } from '@/types/database'
import { CheckCircle, XCircle, RotateCcw } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'

type Tab = 'content' | 'practice' | 'result'

const TABS: { key: Tab; label: string }[] = [
  { key: 'content',  label: 'Nội dung' },
  { key: 'practice', label: 'Thực hành' },
  { key: 'result',   label: 'Kết quả' },
]

export function LessonDetail({ lesson }: { lesson: MnnLessonFull }) {
  const [tab, setTab] = useState<Tab>('content')
  const [results, setResults] = useState<ExerciseResult[] | null>(null)

  function handleExerciseDone(r: ExerciseResult[]) {
    setResults(r)
    setTab('result')
  }

  const correctCount = results?.filter((r) => r.correct).length ?? 0
  const total = results?.length ?? 0
  const score = total > 0 ? Math.round((correctCount / total) * 100) : 0

  return (
    <div className="space-y-6">
      {/* Tabs */}
      <div className="flex gap-1 border-b">
        {TABS.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={cn(
              'px-4 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors',
              tab === key
                ? 'border-primary text-primary'
                : 'border-transparent text-muted-foreground hover:text-foreground',
            )}
          >
            {label}
            {key === 'result' && results && (
              <span className={cn(
                'ml-1.5 text-xs font-bold',
                score >= 70 ? 'text-green-600' : score >= 50 ? 'text-yellow-600' : 'text-red-500',
              )}>
                {score}%
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Tab content */}
      {tab === 'content' && (
        <div className="space-y-8">
          <VocabSection vocabulary={lesson.mnn_vocabulary} />
          <GrammarSection grammar={lesson.mnn_grammar} />
        </div>
      )}

      {tab === 'practice' && (
        <ExerciseSession
          exercises={lesson.mnn_exercises}
          onComplete={handleExerciseDone}
        />
      )}

      {tab === 'result' && (
        <ResultPanel
          results={results}
          onRetry={() => { setResults(null); setTab('practice') }}
        />
      )}
    </div>
  )
}

function ResultPanel({
  results,
  onRetry,
}: {
  results: ExerciseResult[] | null
  onRetry: () => void
}) {
  if (!results) {
    return (
      <div className="text-center py-12 text-muted-foreground space-y-3">
        <p>Chưa có kết quả. Hãy làm bài tập trước.</p>
        <Button variant="outline" onClick={onRetry}>Đến phần Thực hành</Button>
      </div>
    )
  }

  const correct = results.filter((r) => r.correct).length
  const total = results.length
  const score = Math.round((correct / total) * 100)
  const wrong = results.filter((r) => !r.correct)

  return (
    <div className="space-y-6">
      {/* Score summary */}
      <div className="rounded-2xl border bg-card p-6 text-center space-y-4">
        <div className="text-5xl">{score >= 80 ? '🎉' : score >= 50 ? '💪' : '📚'}</div>
        <div>
          <p className={cn(
            'text-4xl font-bold',
            score >= 70 ? 'text-green-600' : score >= 50 ? 'text-yellow-600' : 'text-red-500',
          )}>
            {score}%
          </p>
          <p className="text-muted-foreground mt-1">{correct} / {total} câu đúng</p>
        </div>
        <Progress
          value={score}
          className={cn(
            'h-2',
            score >= 70 ? '[&>div]:bg-green-500'
              : score >= 50 ? '[&>div]:bg-yellow-500'
              : '[&>div]:bg-red-500',
          )}
        />
      </div>

      {/* Wrong answers */}
      {wrong.length > 0 && (
        <div className="space-y-3">
          <h3 className="font-semibold text-sm text-muted-foreground uppercase tracking-wide">
            Câu cần xem lại ({wrong.length})
          </h3>
          <div className="space-y-3">
            {wrong.map((r) => (
              <div key={r.exercise.id} className="rounded-xl border p-4 space-y-2">
                <div className="flex items-start gap-2">
                  <XCircle className="h-4 w-4 text-red-500 shrink-0 mt-0.5" />
                  <p className="text-sm font-japanese">{r.exercise.question}</p>
                </div>
                <div className="ml-6 space-y-1 text-sm">
                  <p className="text-red-600 dark:text-red-400">
                    Bạn trả lời: <span className="font-japanese">{r.userAnswer || '(bỏ trống)'}</span>
                  </p>
                  <div className="flex items-center gap-1.5">
                    <CheckCircle className="h-3.5 w-3.5 text-green-600" />
                    <p className="text-green-700 dark:text-green-400 font-medium">
                      Đáp án đúng: <span className="font-japanese">{r.exercise.answer}</span>
                    </p>
                  </div>
                  {r.exercise.explanation_vi && (
                    <p className="text-muted-foreground">{r.exercise.explanation_vi}</p>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <Button onClick={onRetry} variant="outline" className="w-full gap-2">
        <RotateCcw className="h-4 w-4" /> Luyện lại từ đầu
      </Button>
    </div>
  )
}
