'use client'

import Link from 'next/link'
import { ChevronRight } from 'lucide-react'
import { KANJI, START_DATE, formatDate, introDate, kanjiOfDay } from '@/lib/daily-kanji'
import { dueItems, learnedItems } from '@/lib/kanji-srs'
import { useSrsStates } from '@/lib/kanji-srs-store'
import { QuickLookup } from './QuickLookup'
import { NotifySetup } from './NotifySetup'

/** Màn lịch sử: ôn tập hôm nay + chữ hôm nay + các chữ đã học theo ngày. */
export function DailyHome({ today }: { today: string }) {
  const states = useSrsStates()
  const items = learnedItems(today, states ?? {}).reverse() // mới nhất lên đầu
  const due = states ? dueItems(today, states) : []
  const todays = kanjiOfDay(today)

  if (items.length === 0) {
    return (
      <div className="space-y-6">
        <p className="py-10 text-center text-muted-foreground">
          Chữ đầu tiên sẽ mở vào ngày {formatDate(START_DATE)}.
        </p>
        <QuickLookup today={today} />
        <NotifySetup />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <section className="rounded-2xl border bg-card p-4">
        {states === null ? (
          <p className="text-sm text-muted-foreground">Đang tải tiến độ ôn…</p>
        ) : due.length > 0 ? (
          <div className="flex items-center justify-between gap-3">
            <div>
              <p className="font-semibold">🔁 {due.length} chữ cần ôn</p>
              <p className="text-sm text-muted-foreground font-japanese">
                {due.slice(0, 12).map((d) => d.kanji.k).join(' ')}
                {due.length > 12 && ' …'}
              </p>
            </div>
            <Link
              href="/kanji/daily/review"
              className="shrink-0 rounded-xl bg-primary px-4 py-2 text-sm font-medium text-primary-foreground"
            >
              Ôn ngay
            </Link>
          </div>
        ) : (
          <p className="text-sm">🎉 Hôm nay đã ôn xong.</p>
        )}
      </section>

      {todays ? (
        <Link
          href={`/kanji/daily/${today}`}
          className="flex items-center gap-4 rounded-2xl border bg-card p-4 transition-colors hover:bg-accent"
        >
          <span className="text-5xl font-japanese leading-none">{todays.kanji.k}</span>
          <span className="min-w-0 flex-1">
            <span className="block text-xs text-muted-foreground">
              Chữ hôm nay · ngày {todays.index + 1}/{KANJI.length}
            </span>
            <span className="block font-semibold text-primary">{todays.kanji.hv}</span>
            <span className="block text-sm">{todays.kanji.mean}</span>
          </span>
          <ChevronRight className="h-5 w-5 text-muted-foreground" />
        </Link>
      ) : (
        <p className="rounded-2xl border bg-card p-4 text-sm">
          Đã mở hết {KANJI.length} chữ. Từ giờ chỉ còn ôn theo lịch nhắc lại.
        </p>
      )}

      <QuickLookup today={today} />

      <section className="space-y-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Đã học {items.length}/{KANJI.length} chữ
        </h2>
        <ul className="divide-y rounded-2xl border bg-card">
          {items.map(({ kanji: k, index, state }) => {
            const date = introDate(index)
            const isDue = states !== null && state.due <= today
            return (
              <li key={k.k}>
                <Link
                  href={`/kanji/daily/${date}`}
                  className="flex items-center gap-3 px-4 py-3 transition-colors hover:bg-accent"
                >
                  <span className="w-10 text-3xl font-japanese leading-none">{k.k}</span>
                  <span className="min-w-0 flex-1">
                    <span className="block text-sm font-semibold">{k.hv}</span>
                    <span className="block truncate text-sm text-muted-foreground">{k.mean}</span>
                  </span>
                  <span className="shrink-0 text-right text-xs text-muted-foreground">
                    <span className="block">
                      Ngày {index + 1} · {formatDate(date)}
                    </span>
                    {states !== null && (
                      <span className={isDue ? 'font-medium text-amber-600 dark:text-amber-400' : ''}>
                        {isDue ? 'Cần ôn' : `Ôn ${formatDate(state.due)}`}
                      </span>
                    )}
                  </span>
                </Link>
              </li>
            )
          })}
        </ul>
      </section>

      <NotifySetup />
    </div>
  )
}
