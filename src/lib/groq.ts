import type { GradingResult } from '@/types/database'

const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions'

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

function parseGroqResponse(data: unknown): GradingResult {
  const raw = data as Record<string, unknown>
  const text: string =
    (raw?.choices as Array<{ message: { content: string } }>)?.[0]?.message?.content ?? ''

  if (!text) {
    console.error('[Groq] Raw response:', JSON.stringify(raw, null, 2))
    throw new Error('Groq không trả về text.')
  }

  const cleaned = text.replace(/^```json\s*/i, '').replace(/\s*```$/, '').trim()

  let parsed: GradingResult
  try {
    parsed = JSON.parse(cleaned)
  } catch {
    console.error('[Groq] Raw text không parse được:', text)
    throw new Error(`Không parse được kết quả từ Groq: ${text}`)
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

async function callGroq(apiKey: string, model: string, prompt: string): Promise<Response> {
  return fetch(GROQ_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.2,
      max_tokens: 2048,
    }),
  })
}

export async function gradeWritingWithGroq(
  prompt_vi: string,
  response: string,
  min_words: number,
): Promise<GradingResult> {
  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) throw new Error('GROQ_API_KEY chưa được cấu hình')

  const primaryModel = process.env.GROQ_MODEL ?? 'llama-3.3-70b-versatile'
  const fallbackModel = process.env.GROQ_MODEL_FALLBACK ?? 'llama-3.1-8b-instant'

  const prompt = buildGradingPrompt(prompt_vi, response, min_words)

  let res = await callGroq(apiKey, primaryModel, prompt)

  // Rate limit trên primary → thử fallback model
  if (res.status === 429) {
    console.warn('[Groq] Rate limit trên primary model, chuyển sang fallback...')
    res = await callGroq(apiKey, fallbackModel, prompt)
  }

  if (!res.ok) {
    const errText = await res.text()
    console.error(`[Groq] HTTP ${res.status}:`, errText)
    if (res.status === 429) throw new Error('Groq API đang quá tải, vui lòng thử lại sau ít phút.')
    if (res.status === 401) throw new Error('GROQ_API_KEY không hợp lệ.')
    throw new Error(`Groq API lỗi: ${res.status}`)
  }

  const data = await res.json()
  return parseGroqResponse(data)
}
