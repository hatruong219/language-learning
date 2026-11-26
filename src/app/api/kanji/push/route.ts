import webpush, { type PushSubscription } from 'web-push'
import { KANJI, kanjiOfDay, todayVN, type DailyKanji } from '@/lib/daily-kanji'
import { scheduledReviews } from '@/lib/kanji-srs'

// Vercel Cron gọi 2 lần/ngày (xem vercel.json), gửi Web Push tới app "Kanji"
// trên Màn hình chính iPhone. Bấm thông báo mở thẳng trong app.
// - 0h UTC = 7h VN: chữ mới của ngày. Hết danh sách thì bỏ qua (chỉ còn ôn).
// - 10h UTC = 17h VN (`?slot=review`): các chữ đến hạn ôn theo lịch chuẩn.
// Kết quả Nhớ / Quên lưu trên thiết bị nên server không biết — chữ bị "Quên"
// chỉ hiện thêm khi mở trang ôn.
//
// ENV: CRON_SECRET, SITE_URL, NEXT_PUBLIC_VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY,
//      PUSH_SUBSCRIPTION — mã đăng ký lấy từ nút "Bật thông báo" trong app
//      (một object JSON, hoặc mảng nếu nhiều thiết bị).
export const dynamic = 'force-dynamic'

type Push = { title: string; body: string; url: string; tag: string }

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

  const siteUrl = process.env.SITE_URL?.replace(/\/$/, '')
  const publicKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY
  const privateKey = process.env.VAPID_PRIVATE_KEY
  const subs = parseSubscriptions(process.env.PUSH_SUBSCRIPTION)
  if (!siteUrl || !publicKey || !privateKey || subs.length === 0) {
    return Response.json(
      { ok: false, error: 'Thiếu SITE_URL, VAPID key hoặc PUSH_SUBSCRIPTION (hợp lệ)' },
      { status: 500 },
    )
  }
  // "subject" để dịch vụ push (Apple) liên hệ khi có sự cố — dùng URL site
  // thay vì email.
  webpush.setVapidDetails(siteUrl, publicKey, privateKey)

  const today = todayVN()
  const todays = kanjiOfDay(today)
  const push =
    url.searchParams.get('slot') === 'review'
      ? reviewPush(today)
      : todays && newKanjiPush(todays.kanji, todays.index, today)

  if (!push) return Response.json({ ok: true, date: today, skipped: 'không có gì để gửi' })

  const results = await Promise.all(
    subs.map(async (sub) => {
      try {
        await webpush.sendNotification(sub, JSON.stringify(push), { TTL: 12 * 3600, urgency: 'high' })
        return { ok: true as const }
      } catch (e) {
        // 404/410: đăng ký hết hạn (xoá icon, cài lại app) → cần bấm "Bật thông báo" lại
        const status = typeof e === 'object' && e && 'statusCode' in e ? Number(e.statusCode) : 0
        return { ok: false as const, status, expired: status === 404 || status === 410 }
      }
    }),
  )
  const ok = results.some((r) => r.ok)
  return Response.json({ ok, date: today, title: push.title, results }, { status: ok ? 200 : 502 })
}

function parseSubscriptions(raw: string | undefined): PushSubscription[] {
  if (!raw) return []
  try {
    const v: unknown = JSON.parse(raw)
    const list: unknown[] = Array.isArray(v) ? v : [v]
    return list.filter(
      (s): s is PushSubscription =>
        typeof s === 'object' && s !== null && 'endpoint' in s && 'keys' in s,
    )
  } catch {
    return []
  }
}

/** Nội dung đầy đủ của một chữ — dùng chung cho push sáng và push ôn */
function kanjiLines(k: DailyKanji): string[] {
  const lines = [
    `${k.hv} · ${k.mean}`,
    `On: ${k.on}${k.kun ? ` · Kun: ${k.kun}` : ''}`,
    ...k.words.map(([w, r, m, note]) => `◆ ${w} (${r}): ${m}${note ? ` ⚠️ ${note}` : ''}`),
  ]
  if (k.similar?.length) {
    lines.push(`Dễ nhầm với: ${k.similar.map(([c, m]) => `${c} (${m})`).join(', ')}`)
  }
  return lines
}

function newKanjiPush(k: DailyKanji, index: number, today: string): Push {
  return {
    title: `📅 Kanji ngày ${index + 1}/${KANJI.length}: ${k.k}`,
    body: kanjiLines(k).join('\n'),
    url: `/kanji/daily/${today}`,
    tag: `new-${today}`,
  }
}

// Web Push giới hạn ~4KB sau mã hoá; chừa khoảng an toàn cho tiêu đề + JSON.
const MAX_BODY_BYTES = 2800

function reviewPush(today: string): Push | null {
  const due = scheduledReviews(today)
  if (due.length === 0) return null
  // Mỗi chữ hiện đầy đủ như push buổi sáng, cách nhau một dòng trống. Quá dài
  // thì dừng lại và nhắc mở app xem tiếp.
  const enc = new TextEncoder()
  const blocks: string[] = []
  for (const [i, k] of due.entries()) {
    const block = [`【${k.k}】`, ...kanjiLines(k)].join('\n')
    if (enc.encode([...blocks, block].join('\n\n')).length > MAX_BODY_BYTES) {
      blocks.push(`… và ${due.length - i} chữ nữa — mở app để xem`)
      break
    }
    blocks.push(block)
  }
  return {
    title: `🔁 Ôn tập: ${due.map((k) => k.k).join(' ')}`,
    body: blocks.join('\n\n'),
    url: '/kanji/daily/review',
    tag: `review-${today}`,
  }
}
