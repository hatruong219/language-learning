// Chặn lạm dụng route nhận diện giọng nói (/kotoba-app/api/stt).
//
// Không lớp nào ở đây chống được kẻ cố tình giả header — chúng chỉ chặn trang
// web khác nhúng gọi ké và script lặp vô tội vạ. Chốt chặn thật là hạn mức chi
// tiêu trên tài khoản Groq.

/**
 * Trình duyệt hiện đại (Chrome, Safari 16.4+) luôn gửi Sec-Fetch-Site. Thiếu nó
 * thì đòi Origin khớp Host; thiếu cả hai là không phải trình duyệt → chặn.
 */
export function isSameOrigin(req: Request): boolean {
  const site = req.headers.get('sec-fetch-site')
  if (site) return site === 'same-origin'

  const origin = req.headers.get('origin')
  const host = req.headers.get('x-forwarded-host') ?? req.headers.get('host')
  if (!origin || !host) return false
  try {
    return new URL(origin).host === host
  } catch {
    return false
  }
}

const WINDOW_MS = 60_000
const MAX_PER_WINDOW = 30
const hits = new Map<string, { count: number; resetAt: number }>()

/**
 * Giới hạn lượt theo IP trong bộ nhớ của từng instance serverless — không
 * tuyệt đối (mỗi instance đếm riêng, khởi động lại là mất), nhưng đủ chặn một
 * vòng lặp gọi liên tục. 30 lượt/phút dư sức cho một người đang học.
 */
export function takeRateLimit(req: Request, now = Date.now()): boolean {
  const ip = (req.headers.get('x-forwarded-for') ?? 'unknown').split(',')[0].trim()
  const entry = hits.get(ip)
  if (!entry || entry.resetAt <= now) {
    if (hits.size > 5_000) hits.clear() // không để Map phình mãi
    hits.set(ip, { count: 1, resetAt: now + WINDOW_MS })
    return true
  }
  entry.count += 1
  return entry.count <= MAX_PER_WINDOW
}
