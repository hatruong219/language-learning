import { KANJI, kanjiOfDay, todayVN, type DailyKanji } from '@/lib/daily-kanji'
import { scheduledReviews } from '@/lib/kanji-srs'

// Vercel Cron gọi 2 lần/ngày (xem vercel.json), push lên iPhone qua app ntfy:
// - 0h UTC = 7h VN: chữ mới của ngày. Hết danh sách thì bỏ qua (chỉ còn ôn).
// - 10h UTC = 17h VN (`?slot=review`): các chữ đến hạn ôn theo lịch chuẩn.
// Kết quả Nhớ / Quên lưu trên trình duyệt nên server không biết — chữ bị
// "Quên" chỉ hiện thêm khi mở trang ôn.
// ENV: NTFY_TOPIC, SITE_URL (vd https://study.truongha.com), CRON_SECRET,
//      NTFY_SERVER (tuỳ chọn, mặc định https://ntfy.sh)
export const dynamic = 'force-dynamic'

type Push = { title: string; message: string; click: string }

export async function GET(req: Request) {
  const secret = process.env.CRON_SECRET
  const url = new URL(req.url)
  // Vercel Cron tự gửi `Authorization: Bearer $CRON_SECRET`; `?secret=` để gọi
  // tay hoặc từ scheduler khác.
  const authorized =
    !!secret &&
    (req.headers.get('authorization') === `Bearer ${secret}` ||
      url.searchParams.get('secret') === secret)
  if (!authorized) return new Response('Unauthorized', { status: 401 })

  // ntfy không có key: ai biết tên topic là đọc/gửi được, nên topic phải là
  // chuỗi ngẫu nhiên khó đoán và chỉ để trong env.
  const topic = process.env.NTFY_TOPIC
  const siteUrl = process.env.SITE_URL?.replace(/\/$/, '')
  if (!topic || !siteUrl) {
    return Response.json({ ok: false, error: 'Thiếu NTFY_TOPIC hoặc SITE_URL' }, { status: 500 })
  }
  const server = (process.env.NTFY_SERVER ?? 'https://ntfy.sh').replace(/\/$/, '')

  const today = todayVN()
  const todays = kanjiOfDay(today)
  const push =
    url.searchParams.get('slot') === 'review'
      ? reviewPush(today, siteUrl)
      : todays && newKanjiPush(todays.kanji, todays.index, today, siteUrl)

  if (!push) return Response.json({ ok: true, date: today, skipped: 'không có gì để gửi' })

  // Gửi dạng JSON thay vì header Title/Click: header HTTP chỉ an toàn với
  // ASCII, còn tiêu đề có chữ Hán và tiếng Việt.
  const res = await fetch(server, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ topic, ...push, priority: 4 }),
  })

  return Response.json({ ok: res.ok, date: today, title: push.title }, { status: res.ok ? 200 : 502 })
}

function newKanjiPush(k: DailyKanji, index: number, today: string, siteUrl: string): Push {
  const lines = [
    `${k.hv} · ${k.mean}`,
    `On: ${k.on}${k.kun ? ` · Kun: ${k.kun}` : ''}`,
    ...k.words.map(([w, r, m, note]) => `◆ ${w} (${r}): ${m}${note ? ` ⚠️ ${note}` : ''}`),
  ]
  if (k.similar?.length) {
    lines.push(`Dễ nhầm với: ${k.similar.map(([c, m]) => `${c} (${m})`).join(', ')}`)
  }
  return {
    title: `📅 Kanji ngày ${index + 1}/${KANJI.length}: ${k.k}`,
    message: lines.join('\n'),
    click: `${siteUrl}/kanji/daily/${today}`,
  }
}

function reviewPush(today: string, siteUrl: string): Push | null {
  const due = scheduledReviews(today)
  if (due.length === 0) return null
  // Chỉ hiện mặt chữ — hiện cả nghĩa thì nhìn thông báo là thấy đáp án, mất
  // bước tự nhớ lại.
  const lines = [
    due.map((k) => k.k).join('　'),
    'Tự nhớ nghĩa + cách đọc trước, rồi mở để kiểm tra và bấm Nhớ / Quên',
  ]
  return {
    title: `🔁 Ôn tập: ${due.length} chữ`,
    message: lines.join('\n'),
    click: `${siteUrl}/kanji/daily/review`,
  }
}
