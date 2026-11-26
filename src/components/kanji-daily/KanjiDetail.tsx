import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { KANJI, formatDate, kvgCode, type DailyKanji } from '@/lib/daily-kanji'
import { KanjiFacts } from './KanjiFacts'
import { KanjiStrokePlayer } from './KanjiStrokePlayer'
import { ReviewStatus } from './ReviewStatus'

/** Màn chi tiết một chữ — dùng cho /kanji/daily/[date] và /kanji/daily/today. */
export function KanjiDetail({
  kanji,
  index,
  date,
  today,
}: {
  kanji: DailyKanji
  index: number
  date: string
  today: string
}) {
  return (
    <div className="space-y-6">
      {/* Luôn về màn lịch sử — mở từ push/icon thì không có trang trước để back */}
      <div className="flex items-center justify-between">
        <Link
          href="/kanji/daily"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground"
        >
          <ArrowLeft className="h-4 w-4" /> Lịch sử
        </Link>
        <span className="text-sm text-muted-foreground">
          {date === today ? 'Hôm nay' : formatDate(date)} · ngày {index + 1}/{KANJI.length}
        </span>
      </div>

      <KanjiFacts kanji={kanji} />
      <KanjiStrokePlayer kanji={kanji.k} code={kvgCode(kanji.k)} />
      <ReviewStatus k={kanji.k} index={index} today={today} />

      <p className="text-xs text-muted-foreground">
        Dữ liệu nét chữ:{' '}
        <a href="https://kanjivg.tagaini.net" className="underline hover:text-foreground" target="_blank" rel="noreferrer">
          KanjiVG
        </a>{' '}
        © Ulrich Apel, CC BY-SA 3.0
      </p>
    </div>
  )
}
