'use client'

import Link from 'next/link'
import { useState } from 'react'
import { dueItems, grade, type SrsItem } from '@/lib/kanji-srs'
import { saveSrsState, useSrsStates } from '@/lib/kanji-srs-store'
import { KanjiFacts } from './KanjiFacts'
import { GradeButtons } from './GradeButtons'

/**
 * Ôn kiểu thẻ lật: chỉ hiện mặt chữ để tự nhớ nghĩa + cách đọc, rồi mới lật ra
 * đáp án và tự chấm Nhớ / Quên.
 */
export function ReviewDeck({ today }: { today: string }) {
  const states = useSrsStates()
  // Chốt danh sách lúc mở trang — chấm xong một chữ thì nó ra khỏi "đến hạn",
  // không được làm xáo lại hàng đợi đang ôn.
  const [queue, setQueue] = useState<SrsItem[] | null>(null)
  const [pos, setPos] = useState(0)
  const [revealed, setRevealed] = useState(false)
  const [forgot, setForgot] = useState(0)

  if (queue === null && states !== null) setQueue(dueItems(today, states))
  if (queue === null) return <p className="py-16 text-center text-muted-foreground">Đang tải…</p>

  if (queue.length === 0 || pos >= queue.length) {
    return (
      <div className="space-y-4 py-12 text-center">
        <p className="text-4xl">🎉</p>
        <p className="font-semibold">
          {queue.length === 0 ? 'Hôm nay không có chữ nào cần ôn.' : `Xong ${queue.length} chữ!`}
        </p>
        {queue.length > 0 && (
          <p className="text-sm text-muted-foreground">
            Nhớ {queue.length - forgot} · Quên {forgot} — chữ quên sẽ quay lại vào ngày mai.
          </p>
        )}
        <Link href="/kanji/daily" className="inline-block rounded-xl border px-4 py-2 text-sm font-medium hover:bg-accent">
          Về lịch sử
        </Link>
      </div>
    )
  }

  const item = queue[pos]
  const onGrade = (ok: boolean) => {
    const latest = states?.[item.kanji.k] ?? item.state
    saveSrsState(item.kanji.k, grade(latest, ok, today))
    if (!ok) setForgot((f) => f + 1)
    setRevealed(false)
    setPos((p) => p + 1)
  }

  return (
    <div className="space-y-4">
      <div className="h-1.5 overflow-hidden rounded-full bg-muted">
        <div className="h-full bg-primary transition-all" style={{ width: `${(pos / queue.length) * 100}%` }} />
      </div>
      <p className="text-center text-xs text-muted-foreground">
        {pos + 1}/{queue.length}
      </p>

      <div className="rounded-2xl border bg-card p-6">
        <div className="text-center text-8xl font-japanese leading-none py-4">{item.kanji.k}</div>
        {revealed && (
          <div className="mt-4 border-t pt-4">
            <KanjiFacts kanji={item.kanji} showChar={false} />
          </div>
        )}
      </div>

      {revealed ? (
        <GradeButtons onGrade={onGrade} />
      ) : (
        <button
          type="button"
          onClick={() => setRevealed(true)}
          className="w-full rounded-xl bg-primary px-4 py-3 font-medium text-primary-foreground"
        >
          Xem đáp án
        </button>
      )}
    </div>
  )
}
