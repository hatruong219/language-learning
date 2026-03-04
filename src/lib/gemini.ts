import type { GradingResult } from '@/types/database'

const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent'

function buildGradingPrompt(prompt_vi: string, response: string, min_words: number): string {
  return `Bạn là giáo viên tiếng Nhật chuyên nghiệp. Nhiệm vụ của bạn là chấm bài viết tiếng Nhật của học sinh.

ĐỀ BÀI: ${prompt_vi}
YÊU CẦU: Bài viết phải bằng tiếng Nhật, tối thiểu ${min_words} từ.

BÀI VIẾT CỦA HỌC SINH:
"""
${response}
"""

HƯỚNG DẪN CHẤM ĐIỂM:
1. Kiểm tra xem bài có viết bằng tiếng Nhật không. Nếu KHÔNG phải tiếng Nhật (tiếng Việt, tiếng Anh, số, ký tự ngẫu nhiên...) → is_valid_lang = false, tất cả điểm = 0, giải thích trong feedback_vi.
2. Nếu đúng tiếng Nhật, chấm theo 3 tiêu chí:
   - score_grammar (0-40): Ngữ pháp, cấu trúc câu đúng
   - score_vocab (0-30): Từ vựng phong phú, phù hợp
   - score_content (0-30): Nội dung liên quan đến đề bài
3. score = score_grammar + score_vocab + score_content (tổng 0-100)
4. errors: Liệt kê tối đa 5 lỗi quan trọng nhất (nếu có)
5. feedback_vi: Nhận xét tổng quan bằng tiếng Việt (2-4 câu), thân thiện và khuyến khích

Hãy trả về JSON hợp lệ theo đúng format sau (không thêm markdown, không thêm text ngoài JSON):
{
  "is_valid_lang": true,
  "score_grammar": 30,
  "score_vocab": 22,
  "score_content": 25,
  "score": 77,
  "feedback_vi": "Bài viết khá tốt, ngữ pháp cơ bản đúng. Cần bổ sung thêm tính từ mô tả.",
  "errors": [
    {
      "original": "わたしはがくせいです",
      "corrected": "わたしはがくせいです。",
      "explanation_vi": "Cuối câu cần có dấu chấm 。"
    }
  ]
}`
}

function parseGeminiResponse(data: unknown): GradingResult {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const raw = data as any
  const text: string = raw?.candidates?.[0]?.content?.parts?.[0]?.text ?? ''

  if (!text) {
    console.error('[Gemini] Raw response:', JSON.stringify(raw, null, 2))
    throw new Error(`Gemini không trả về text. promptFeedback: ${JSON.stringify(raw?.promptFeedback)}`)
  }

  const cleaned = text.replace(/^```json\s*/i, '').replace(/\s*```$/, '').trim()

  let parsed: GradingResult
  try {
    parsed = JSON.parse(cleaned)
  } catch {
    console.error('[Gemini] Raw text không parse được:', text)
    throw new Error(`Không parse được kết quả từ Gemini: ${text}`)
  }

  return {
    is_valid_lang: Boolean(parsed.is_valid_lang),
    score_grammar: Math.max(0, Math.min(40, Number(parsed.score_grammar ?? 0))),
    score_vocab: Math.max(0, Math.min(30, Number(parsed.score_vocab ?? 0))),
    score_content: Math.max(0, Math.min(30, Number(parsed.score_content ?? 0))),
    score: Math.max(0, Math.min(100, Number(parsed.score ?? 0))),
    feedback_vi: String(parsed.feedback_vi ?? ''),
    errors: Array.isArray(parsed.errors) ? parsed.errors : [],
  }
}

export async function gradeWritingWithGemini(
  prompt_vi: string,
  response: string,
  min_words: number,
): Promise<GradingResult> {
  const apiKey = process.env.GEMINI_API_KEY
  if (!apiKey) throw new Error('GEMINI_API_KEY chưa được cấu hình')

  const body = {
    contents: [
      {
        parts: [{ text: buildGradingPrompt(prompt_vi, response, min_words) }],
      },
    ],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 2048,
    },
  }

  const res = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })

  // Retry 1 lần sau 3s nếu rate limit
  if (res.status === 429) {
    await new Promise((r) => setTimeout(r, 3000))
    const retryRes = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    })
    if (!retryRes.ok) {
      console.error(`[Gemini] Retry failed HTTP ${retryRes.status}`)
      throw new Error('Gemini API đang quá tải, vui lòng thử lại sau ít phút.')
    }
    return parseGeminiResponse(await retryRes.json())
  }

  if (!res.ok) {
    const errText = await res.text()
    console.error(`[Gemini] HTTP ${res.status}:`, errText)
    let errMsg = `Gemini API lỗi: ${res.status}`
    if (res.status === 429) errMsg = 'Gemini API đang quá tải, vui lòng thử lại sau vài giây.'
    if (res.status === 403) errMsg = 'GEMINI_API_KEY không hợp lệ hoặc chưa được kích hoạt.'
    throw new Error(errMsg)
  }

  const data = await res.json()
  return parseGeminiResponse(data)
}
