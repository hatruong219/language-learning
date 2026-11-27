// Groq Whisper speech-to-text (Japanese). Used by /kotoba-app/api/stt.
const GROQ_STT_URL = 'https://api.groq.com/openai/v1/audio/transcriptions'
// Đổi model ở một chỗ này nếu Groq deprecate (fallback: whisper-large-v3).
const STT_MODEL = 'whisper-large-v3-turbo'
const STT_TIMEOUT_MS = 15_000

export class SttError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message)
    this.name = 'SttError'
  }
}

/** App Kotoba chỉ gửi WAV (16 kHz mono) — route đã kiểm định dạng trước khi gọi. */
export async function transcribeJapanese(wav: Uint8Array<ArrayBuffer>): Promise<string> {
  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) throw new SttError(500, 'Chưa cấu hình nhận diện giọng nói.')

  // Không gửi `prompt`: không bao giờ đưa đáp án cho Whisper.
  const form = new FormData()
  form.append('file', new Blob([wav], { type: 'audio/wav' }), 'audio.wav')
  form.append('model', STT_MODEL)
  form.append('language', 'ja')
  form.append('response_format', 'json')
  form.append('temperature', '0')

  let res: Response
  try {
    res = await fetch(GROQ_STT_URL, {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}` },
      body: form,
      signal: AbortSignal.timeout(STT_TIMEOUT_MS),
    })
  } catch (err) {
    console.error('[STT] Groq request failed:', err instanceof Error ? err.name : 'unknown')
    throw new SttError(502, 'Không nhận diện được, thử lại.')
  }

  if (!res.ok) {
    // Chỉ log mã trạng thái, không log body/key.
    console.error(`[STT] Groq HTTP ${res.status}`)
    if (res.status === 429) throw new SttError(429, 'Quá nhiều lượt, thử lại sau ít phút.')
    throw new SttError(502, 'Không nhận diện được, thử lại.')
  }

  const data = (await res.json().catch(() => null)) as { text?: unknown } | null
  if (!data || typeof data.text !== 'string') {
    throw new SttError(502, 'Không nhận diện được, thử lại.')
  }
  return data.text.trim()
}
