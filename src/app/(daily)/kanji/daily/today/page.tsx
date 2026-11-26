import Link from 'next/link'
import type { Metadata } from 'next'
import { KANJI, START_DATE, formatDate, kanjiOfDay, todayVN } from '@/lib/daily-kanji'
import { KanjiDetail } from '@/components/kanji-daily/KanjiDetail'

// Link cố định cho icon app: HIỂN THỊ chữ hôm nay tại chỗ (không redirect),
// để URL luôn là /today — iOS lưu URL đang mở khi "Thêm vào MH chính", nếu
// redirect sang /kanji/daily/<ngày> thì icon sẽ dính cứng vào ngày đó.
export const dynamic = 'force-dynamic'

export async function generateMetadata(): Promise<Metadata> {
  const day = kanjiOfDay(todayVN())
  return { title: day ? `${day.kanji.k} · Kanji hôm nay` : 'Kanji hôm nay' }
}

export default function DailyKanjiTodayPage() {
  const today = todayVN()
  const day = kanjiOfDay(today)
  if (day) return <KanjiDetail kanji={day.kanji} index={day.index} date={today} today={today} />

  const notStarted = today < START_DATE
  return (
    <div className="space-y-6 py-12 text-center">
      <p className="text-6xl font-japanese">{notStarted ? '待' : '済'}</p>
      <div className="space-y-1">
        <p className="text-lg font-semibold">
          {notStarted ? 'Hôm nay chưa có bài' : `Đã học hết ${KANJI.length} chữ`}
        </p>
        <p className="text-sm text-muted-foreground">
          {notStarted
            ? `Chữ đầu tiên sẽ mở vào ngày ${formatDate(START_DATE)}. Trong lúc chờ, xem phần Tra nhanh ở danh sách.`
            : 'Không còn chữ mới — mỗi ngày chỉ còn ôn lại theo lịch nhắc lại.'}
        </p>
      </div>
      <div className="flex justify-center gap-2">
        {!notStarted && (
          <Link
            href="/kanji/daily/review"
            className="rounded-xl bg-primary px-4 py-2 text-sm font-medium text-primary-foreground"
          >
            Ôn tập
          </Link>
        )}
        <Link href="/kanji/daily" className="rounded-xl border px-4 py-2 text-sm font-medium hover:bg-accent">
          Danh sách
        </Link>
      </div>
    </div>
  )
}
