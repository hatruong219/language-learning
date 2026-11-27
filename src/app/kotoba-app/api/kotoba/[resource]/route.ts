// GET /kotoba-app/api/kotoba/{grammar|kanji|kanji-words} — chuyển tiếp sang trang quản trị.
//
// Không dùng rewrite của next.config: rewrite ra domain ngoài gửi kèm cả cookie
// phiên đăng nhập của study.truongha.com. Ở đây tự fetch nên chỉ đi đúng URL,
// không header nào của người dùng. Cùng origin với app nên khỏi cần CORS.
import { NextResponse } from 'next/server'

const UPSTREAM = 'https://admin.truongha.com/api/kotoba'
const RESOURCES = new Set(['grammar', 'kanji', 'kanji-words'])
const TIMEOUT_MS = 30_000

export async function GET(
  _req: Request,
  { params }: { params: Promise<{ resource: string }> },
) {
  const { resource } = await params
  if (!RESOURCES.has(resource)) {
    return NextResponse.json({ error: 'Không có dữ liệu này.' }, { status: 404 })
  }

  try {
    const res = await fetch(`${UPSTREAM}/${resource}`, {
      cache: 'no-store',
      signal: AbortSignal.timeout(TIMEOUT_MS),
    })
    const body = await res.text()
    return new NextResponse(body, {
      status: res.status,
      headers: {
        'content-type': res.headers.get('content-type') ?? 'application/json',
        'cache-control': 'no-store',
      },
    })
  } catch {
    return NextResponse.json(
      { error: 'Máy chủ dữ liệu không phản hồi. Thử lại sau.' },
      { status: 502 },
    )
  }
}
