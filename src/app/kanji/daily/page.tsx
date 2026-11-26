import Link from 'next/link'
import type { Metadata } from 'next'
import { ArrowLeft, ArrowUpRight } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import {
  getDaily,
  isDateStr,
  kvgCode,
  previousDays,
  todayVN,
} from '@/lib/daily-kanji'
import { KanjiStrokePlayer } from '@/components/kanji/KanjiStrokePlayer'

// Chữ của ngày phụ thuộc giờ hiện tại → không được prerender lúc build.
export const dynamic = 'force-dynamic'

export const metadata: Metadata = {
  title: 'Kanji mỗi ngày',
  description: 'Mỗi ngày một chữ Hán: cách đọc, nghĩa, thứ tự nét và tập viết',
  appleWebApp: { capable: true, title: 'Kanji mỗi ngày' },
}

export default async function DailyKanjiPage({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>
}) {
  const { d } = await searchParams
  const today = todayVN()
  const date = isDateStr(d) ? d : today
  const k = getDaily(date)

  // Danh sách chữ là fix cứng; database chỉ dùng để biết chữ này có trang
  // chi tiết /kanji/[char] hay không — tránh vẽ link dẫn tới trang 404.
  const supabase = await createClient()
  const { data: known } = await supabase
    .from('jlpt_kanji')
    .select('character')
    .eq('site_id', process.env.NEXT_PUBLIC_SITE_ID ?? '')
    .eq('character', k.k)
    .maybeSingle()

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl space-y-6">
      <Link
        href="/kanji"
        className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Kanji
      </Link>

      <p className="text-sm text-muted-foreground">
        {date === today ? 'Kanji hôm nay' : 'Kanji ngày'} · {formatDate(date)}
      </p>

      <div className="rounded-2xl border bg-card p-6 flex gap-6 items-start">
        <div className="text-7xl font-japanese leading-none shrink-0">{k.k}</div>
        <dl className="space-y-2 text-sm min-w-0">
          <Row label="Hán-Việt">
            <span className="font-semibold text-primary uppercase">{k.hv}</span>
          </Row>
          <Row label="Nghĩa">{k.mean}</Row>
          <Row label="Âm ON">
            <span className="font-japanese">{k.on}</span>
          </Row>
          <Row label="Âm KUN">
            <span className="font-japanese">{k.kun || '—'}</span>
          </Row>
        </dl>
      </div>

      <KanjiStrokePlayer kanji={k.k} code={kvgCode(k.k)} />

      <section className="space-y-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Từ ví dụ
        </h2>
        <ul className="space-y-2">
          {k.ex.map(([word, kana, meaning]) => (
            <li key={word} className="rounded-xl border bg-card px-4 py-3">
              <div className="flex items-baseline gap-3 flex-wrap">
                <span className="text-lg font-japanese">{word}</span>
                <span className="text-sm text-muted-foreground font-japanese">
                  {kana}
                </span>
              </div>
              <p className="text-sm text-muted-foreground">{meaning}</p>
            </li>
          ))}
        </ul>
        {known && (
          <Link
            href={`/kanji/${encodeURIComponent(k.k)}`}
            className="inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            Xem thêm từ có chữ {k.k} <ArrowUpRight className="h-4 w-4" />
          </Link>
        )}
      </section>

      <section className="space-y-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Các ngày trước
        </h2>
        <div className="flex flex-wrap gap-2">
          {date !== today && (
            <Link
              href="/kanji/daily"
              className="rounded-xl border bg-card px-3 py-2 text-sm font-medium hover:bg-accent transition-colors"
            >
              Hôm nay
            </Link>
          )}
          {previousDays(today, 7).map((day) => (
            <Link
              key={day}
              href={`/kanji/daily?d=${day}`}
              className={`rounded-xl border px-3 py-2 text-sm hover:bg-accent transition-colors ${
                day === date ? 'bg-accent font-semibold' : 'bg-card'
              }`}
            >
              <span className="font-japanese text-base">{getDaily(day).k}</span>{' '}
              <span className="text-muted-foreground">{formatDate(day)}</span>
            </Link>
          ))}
        </div>
      </section>

      <p className="text-xs text-muted-foreground">
        Dữ liệu nét chữ:{' '}
        <a
          href="https://kanjivg.tagaini.net"
          className="underline hover:text-foreground"
          target="_blank"
          rel="noreferrer"
        >
          KanjiVG
        </a>{' '}
        © Ulrich Apel, CC BY-SA 3.0
      </p>
    </div>
  )
}

/** '2026-11-27' → '27/11' */
function formatDate(date: string) {
  const [, m, day] = date.split('-')
  return `${day}/${m}`
}

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex gap-3">
      <dt className="w-20 shrink-0 text-muted-foreground">{label}</dt>
      <dd className="min-w-0">{children}</dd>
    </div>
  )
}
