import { getDaily, todayVN } from '@/lib/daily-kanji'

// Vercel Cron gọi 2 lần/ngày: 0h UTC = 7h VN (chữ mới), 10h UTC = 17h VN
// (`?slot=review`, nhắc ôn). Push kanji hôm nay lên iPhone qua app ntfy. Bấm
// vào thông báo mở đúng link của ngày đó, nên tắt đi vẫn mở lại được từ lịch
// sử trong app ntfy.
// ENV: NTFY_TOPIC, SITE_URL (vd https://study.truongha.com), CRON_SECRET,
//      NTFY_SERVER (tuỳ chọn, mặc định https://ntfy.sh)
export const dynamic = 'force-dynamic'

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
  const siteUrl = process.env.SITE_URL
  if (!topic || !siteUrl) {
    return Response.json({ ok: false, error: 'Thiếu NTFY_TOPIC hoặc SITE_URL' }, { status: 500 })
  }
  const server = (process.env.NTFY_SERVER ?? 'https://ntfy.sh').replace(/\/$/, '')

  const date = todayVN()
  const k = getDaily(date)
  // 7h sáng: giới thiệu chữ mới. 5h chiều (`?slot=review`): nhắc ôn lại đúng
  // chữ đó và tập viết — cùng chữ, cùng link của ngày.
  const review = url.searchParams.get('slot') === 'review'

  // Gửi dạng JSON thay vì header Title/Click: header HTTP chỉ an toàn với
  // ASCII, còn tiêu đề có chữ Hán và tiếng Việt.
  const res = await fetch(server, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      topic,
      title: review ? `✍️ Ôn lại kanji hôm nay: ${k.k}` : `🇯🇵 Kanji hôm nay: ${k.k}`,
      message: `${k.hv} · ${k.on}${k.kun ? ` / ${k.kun}` : ''}\n→ ${k.mean}`,
      click: `${siteUrl.replace(/\/$/, '')}/kanji/daily?d=${date}`,
      priority: 4,
    }),
  })

  return Response.json(
    { ok: res.ok, date, kanji: k.k },
    { status: res.ok ? 200 : 502 },
  )
}
