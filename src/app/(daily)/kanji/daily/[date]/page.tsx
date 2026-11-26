import Link from 'next/link'
import type { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { ArrowLeft } from 'lucide-react'
import { KANJI, formatDate, isDateStr, kanjiOfDay, kvgCode, todayVN } from '@/lib/daily-kanji'
import { KanjiFacts } from '@/components/kanji-daily/KanjiFacts'
import { KanjiStrokePlayer } from '@/components/kanji-daily/KanjiStrokePlayer'
import { ReviewStatus } from '@/components/kanji-daily/ReviewStatus'

export const dynamic = 'force-dynamic'

type Props = { params: Promise<{ date: string }> }

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { date } = await params
  const day = isDateStr(date) ? kanjiOfDay(date) : null
  return { title: day ? `${day.kanji.k} · Kanji mỗi ngày` : 'Kanji mỗi ngày' }
}

export default async function DailyKanjiDetailPage({ params }: Props) {
  const { date } = await params
  const today = todayVN()
  // Chỉ mở chữ của những ngày đã tới — không xem trước chữ tương lai.
  const day = isDateStr(date) && date <= today ? kanjiOfDay(date) : null
  if (!day) notFound()
  const { kanji, index } = day

  return (
    <div className="space-y-6">
      {/* Luôn về màn lịch sử — mở từ push thì trình duyệt không có trang trước để back */}
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
