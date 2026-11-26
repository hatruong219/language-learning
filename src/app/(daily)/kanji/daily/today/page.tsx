import { redirect } from 'next/navigation'
import { kanjiOfDay, todayVN } from '@/lib/daily-kanji'

// Link cố định cho icon "Thêm vào Màn hình chính": mỗi lần mở tự chuyển tới
// chữ của hôm nay (giờ VN). Chưa tới ngày bắt đầu / đã hết danh sách thì về
// màn lịch sử.
export const dynamic = 'force-dynamic'

export default function DailyKanjiTodayPage() {
  const today = todayVN()
  redirect(kanjiOfDay(today) ? `/kanji/daily/${today}` : '/kanji/daily')
}
