import type { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { isDateStr, kanjiOfDay, todayVN } from '@/lib/daily-kanji'
import { KanjiDetail } from '@/components/kanji-daily/KanjiDetail'

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
  return <KanjiDetail kanji={day.kanji} index={day.index} date={date} today={today} />
}
