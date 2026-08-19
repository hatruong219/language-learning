'use client'

import { useMemo, useState } from 'react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { QuizSession } from '@/components/quiz/QuizSession'
import type { QuizWord } from '@/lib/quiz'

export type LessonWords = {
  number: number
  title: string
  words: QuizWord[]
}

interface Props {
  lessons: LessonWords[]
  /** Số bài chọn sẵn, ví dụ khi vào từ trang một bài cụ thể. */
  preset: number[]
}

/**
 * Chọn bài rồi kiểm tra từ.
 *
 * Đặt ở ngoài chứ không nằm trong từng bài: kiểm riêng một bài thì không bao
 * giờ ôn chéo được, mà đề thi không hỏi theo bài. Chọn nhiều bài cùng lúc mới
 * buộc phân biệt những từ dễ lẫn nằm ở hai bài khác nhau.
 */
export function LessonPractice({ lessons, preset }: Props) {
  const [picked, setPicked] = useState<Set<number>>(
    () => new Set(preset.filter((n) => lessons.some((l) => l.number === n))),
  )
  const [started, setStarted] = useState(false)

  const words = useMemo(
    () => lessons.filter((l) => picked.has(l.number)).flatMap((l) => l.words),
    [lessons, picked],
  )

  if (started) {
    return (
      <div className="space-y-4">
        <button
          onClick={() => setStarted(false)}
          className="text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          ← Chọn bài khác
        </button>
        <QuizSession words={words} kinds={['vi2ja', 'ja2vi']} />
      </div>
    )
  }

  function toggle(n: number) {
    setPicked((prev) => {
      const next = new Set(prev)
      if (!next.delete(n)) next.add(n)
      return next
    })
  }

  const all = lessons.length
  const allPicked = picked.size === all

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <span className="text-sm text-muted-foreground">
          {picked.size === 0
            ? 'Chưa chọn bài nào'
            : `${picked.size} bài · ${words.length} từ`}
        </span>
        <div className="flex gap-2">
          <button
            onClick={() =>
              setPicked(allPicked ? new Set() : new Set(lessons.map((l) => l.number)))
            }
            className="text-sm text-primary hover:underline"
          >
            {allPicked ? 'Bỏ chọn hết' : 'Chọn tất cả'}
          </button>
        </div>
      </div>

      {/* Lưới số bài — quét mắt tìm bài nhanh hơn đọc một danh sách dọc. */}
      <div className="grid grid-cols-5 sm:grid-cols-8 gap-2">
        {lessons.map((l) => (
          <button
            key={l.number}
            onClick={() => toggle(l.number)}
            title={`Bài ${l.number} — ${l.title} (${l.words.length} từ)`}
            disabled={l.words.length === 0}
            className={cn(
              'aspect-square rounded-lg border text-sm font-medium transition-colors',
              l.words.length === 0 && 'opacity-40 cursor-not-allowed',
              picked.has(l.number)
                ? 'border-primary bg-primary/10 text-primary'
                : 'hover:bg-accent',
            )}
          >
            {l.number}
          </button>
        ))}
      </div>

      {/* Bài không có từ nào thì mờ đi và không bấm được — bấm vào rồi không ra
          đề nào còn khó hiểu hơn là không bấm được. */}
      {lessons.some((l) => l.words.length === 0) && (
        <p className="text-xs text-muted-foreground">
          Bài mờ là bài chưa có từ vựng trong database.
        </p>
      )}

      <Button
        onClick={() => setStarted(true)}
        disabled={words.length < 4}
        size="lg"
        className="w-full"
      >
        {picked.size === 0
          ? 'Chọn ít nhất một bài'
          : words.length < 4
            ? 'Cần ít nhất 4 từ mới ra đề được'
            : `Kiểm tra ${words.length} từ`}
      </Button>
    </div>
  )
}
