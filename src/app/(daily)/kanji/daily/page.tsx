import type { Metadata } from 'next'
import { todayVN } from '@/lib/daily-kanji'
import { DailyHome } from '@/components/kanji-daily/DailyHome'

// "Hôm nay" theo giờ VN → không prerender lúc build.
export const dynamic = 'force-dynamic'

export const metadata: Metadata = { title: 'Kanji mỗi ngày' }

export default function DailyKanjiHomePage() {
  return (
    <>
      <h1 className="mb-5 text-xl font-bold">Kanji mỗi ngày</h1>
      <DailyHome today={todayVN()} />
    </>
  )
}
