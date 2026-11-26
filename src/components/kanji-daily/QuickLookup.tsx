'use client'

import { useState } from 'react'
import Link from 'next/link'
import { findKanji, formatDate, introDate, learnedCount } from '@/lib/daily-kanji'
import { KANJI_GROUPS, type KanjiGroup } from '@/lib/kanji-groups'
import { WordList } from './WordList'

/** Menu tra nhanh: bấm một nhóm (số, thứ, tháng…) để xem các chữ + bảng cách đọc. */
export function QuickLookup({ today }: { today: string }) {
  const [openId, setOpenId] = useState<string | null>(null)
  const open = KANJI_GROUPS.find((g) => g.id === openId) ?? null

  return (
    <section className="space-y-2">
      <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Tra nhanh</h2>
      <div className="flex flex-wrap gap-2">
        {KANJI_GROUPS.map((g) => {
          const active = g.id === openId
          return (
            <button
              key={g.id}
              type="button"
              aria-expanded={active}
              aria-controls="quick-lookup-panel"
              onClick={() => setOpenId(active ? null : g.id)}
              className={
                'rounded-full border px-3 py-1.5 text-sm transition-colors ' +
                (active ? 'border-primary bg-primary text-primary-foreground' : 'bg-card hover:bg-accent')
              }
            >
              <span className="mr-1">{g.emoji}</span>
              {g.label}
            </button>
          )
        })}
      </div>
      {open && <GroupPanel group={open} learned={learnedCount(today)} />}
    </section>
  )
}

function GroupPanel({ group, learned }: { group: KanjiGroup; learned: number }) {
  const chars = [...group.kanji].flatMap((c) => {
    const found = findKanji(c)
    return found ? [found] : []
  })

  return (
    <div id="quick-lookup-panel" className="space-y-4 rounded-2xl border bg-card p-4">
      {chars.length > 0 && (
        <ul className="grid grid-cols-4 gap-2 sm:grid-cols-6">
          {chars.map(({ kanji: k, index }) => {
            const date = introDate(index)
            const body = (
              <>
                <span className="block text-3xl font-japanese leading-tight">{k.k}</span>
                <span className="block truncate text-[11px] font-semibold">{k.hv}</span>
              </>
            )
            return (
              <li key={k.k}>
                {index < learned ? (
                  <Link
                    href={`/kanji/daily/${date}`}
                    title={k.mean}
                    className="block rounded-xl border px-1 py-2 text-center transition-colors hover:bg-accent"
                  >
                    {body}
                  </Link>
                ) : (
                  <div
                    title={`${k.mean} — mở ngày ${formatDate(date)}`}
                    className="rounded-xl border border-dashed px-1 py-2 text-center text-muted-foreground opacity-60"
                  >
                    {body}
                    <span className="block text-[10px]">mở {formatDate(date)}</span>
                  </div>
                )}
              </li>
            )
          })}
        </ul>
      )}

      {group.tables?.map((t) => (
        <div key={t.title} className="space-y-2">
          <h3 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            {t.title} · bấm để nghe
          </h3>
          <WordList words={t.words} />
        </div>
      ))}
    </div>
  )
}
