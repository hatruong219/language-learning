// POST /kotoba-app/api/stt — raw WAV body → { text } | { error }
//
// Route công khai nhưng tiêu quota GROQ_API_KEY, nên chặn nhiều lớp trước khi
// gọi Groq: chỉ nhận yêu cầu từ chính trang này, chỉ nhận WAV thật (kiểm phần
// đầu file), giới hạn độ dài khớp mức tối đa 8 giây của app, và giới hạn số
// lượt theo IP. Lớp cuối cùng vẫn là hạn mức chi tiêu đặt trên tài khoản Groq.
import { NextResponse } from 'next/server'
import { SttError, transcribeJapanese } from '@/lib/groqTranscribe'
import { isSameOrigin, takeRateLimit } from '@/lib/sttGuards'

export const runtime = 'nodejs'

// App xin WAV 16 kHz mono 16-bit, tối đa 8 giây ≈ 256 KB. Nhưng trình duyệt nào
// không chịu đổi tần số mẫu thì ghi luôn 48 kHz (≈ 768 KB/8 giây) — chừa đủ
// cho trường hợp đó để mic không chết oan với lỗi "quá dài".
const MAX_BYTES = 800_000
const MIN_BYTES = 1_000
const WAV_TYPES = ['audio/wav', 'audio/x-wav', 'audio/wave']

function fail(status: number, error: string) {
  return NextResponse.json({ error }, { status })
}

/** Phần đầu file WAV: "RIFF" ... "WAVE". Nhãn Content-Type thì ai cũng ghi được. */
function looksLikeWav(b: Uint8Array): boolean {
  const ascii = (from: number) => String.fromCharCode(...b.subarray(from, from + 4))
  return b.length > 12 && ascii(0) === 'RIFF' && ascii(8) === 'WAVE'
}

export async function POST(req: Request) {
  if (!isSameOrigin(req)) return fail(403, 'Không được phép.')
  if (!takeRateLimit(req)) return fail(429, 'Quá nhiều lượt nhận diện, thử lại sau ít phút.')

  const declared = Number(req.headers.get('content-length') ?? 0)
  if (declared > MAX_BYTES) return fail(413, 'Đoạn ghi âm quá dài.')

  const mime = (req.headers.get('content-type') ?? '').split(';')[0].trim().toLowerCase()
  if (!WAV_TYPES.includes(mime)) return fail(415, 'Định dạng âm thanh không được hỗ trợ.')

  try {
    const bytes = new Uint8Array(await req.arrayBuffer())
    if (bytes.byteLength > MAX_BYTES) return fail(413, 'Đoạn ghi âm quá dài.')
    if (bytes.byteLength < MIN_BYTES) return fail(400, 'Không có âm thanh.')
    if (!looksLikeWav(bytes)) return fail(415, 'Định dạng âm thanh không được hỗ trợ.')

    return NextResponse.json({ text: await transcribeJapanese(bytes) })
  } catch (err) {
    if (err instanceof SttError) return fail(err.status, err.message)
    console.error('[STT] Unexpected error:', err instanceof Error ? err.name : 'unknown')
    return fail(502, 'Không nhận diện được, thử lại.')
  }
}
