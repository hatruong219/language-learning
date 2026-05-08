import type { GradingResult } from '@/types/database'

const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions'

const JLPT_CRITERIA: Record<string, string> = {
  N5: `Trình độ N5 (sơ cấp):
- Ngữ pháp: Chấp nhận câu đơn giản, ます/です form đúng, trợ từ cơ bản (は、が、を、に、で) đúng. Bỏ qua lỗi kanji (dùng hiragana thay kanji là chấp nhận được).
- Từ vựng: Dùng từ N5 đơn giản là đủ. Không yêu cầu từ phức tạp.
- Nội dung: Chỉ cần đề cập đúng chủ đề, không cần lập luận sâu.
- Tiêu chuẩn điểm cao (≥80): Câu đúng ngữ pháp, đề cập đủ ý.`,

  N4: `Trình độ N4 (sơ-trung cấp):
- Ngữ pháp: Kỳ vọng dùng được て-form, ~ています, ~たい, ~から/~ので, ~たことがある. Kanji N5 cơ bản phải đúng.
- Từ vựng: Nên có từ N4, tránh chỉ dùng N5 đơn thuần.
- Nội dung: Cần có ít nhất 2-3 ý rõ ràng liên quan đề bài.
- Tiêu chuẩn điểm cao (≥80): Câu phức có liên kết logic, ít lỗi cơ bản.`,

  N3: `Trình độ N3 (trung cấp):
- Ngữ pháp: Kỳ vọng câu phức, passive/causative cơ bản, ~と思います、~ために、~ながら、~ので và các mẫu N3. Kanji N4 trở xuống phải dùng đúng.
- Từ vựng: Cần có từ N3, đa dạng cách diễn đạt, không lặp từ quá nhiều.
- Nội dung: Cần lập luận có ví dụ cụ thể, không chỉ liệt kê.
- Tiêu chuẩn điểm cao (≥80): Câu đa dạng, lập luận có chiều sâu, ít lỗi nghiêm trọng.`,

  N2: `Trình độ N2 (trung-cao cấp):
- Ngữ pháp: Yêu cầu mẫu câu N2 (~にもかかわらず、~に対して、~をめぐって、~に基づいて...), văn phong rõ ràng, cấu trúc đoạn văn chặt chẽ.
- Từ vựng: Cần từ N2, sử dụng đúng văn cảnh. Tránh dùng từ quá đơn giản.
- Nội dung: Lập luận phải có cấu trúc (mở đầu → thân → kết), dẫn chứng rõ ràng.
- Tiêu chuẩn điểm cao (≥80): Văn phong mạch lạc, lập luận thuyết phục, gần như không lỗi cơ bản.`,

  N1: `Trình độ N1 (cao cấp — tiêu chuẩn rất cao):
- Ngữ pháp: Yêu cầu mẫu câu N1 phức tạp, keigo đúng chỗ, câu ghép tinh tế. Lỗi ngữ pháp cơ bản sẽ bị trừ điểm nặng.
- Từ vựng: Bắt buộc có từ N1/N2, diễn đạt tinh tế, tránh lặp và dùng từ đơn giản. Cần thành ngữ hoặc cụm từ địa ký nếu phù hợp.
- Nội dung: Phân tích sâu sắc, đa chiều, có tư duy phê phán. Chỉ đề cập bề mặt sẽ bị điểm thấp ngay cả khi ngữ pháp đúng.
- Tiêu chuẩn điểm cao (≥80): Gần như hoàn hảo — cả ngữ pháp, từ vựng lẫn chiều sâu nội dung.`,
}

function buildGradingPrompt(
  prompt_vi: string,
  response: string,
  min_words: number,
  jlpt_level?: string | null,
): string {
  const level = jlpt_level ?? 'N5'
  const criteria = JLPT_CRITERIA[level] ?? JLPT_CRITERIA['N5']

  return `Bạn là giáo viên tiếng Nhật chuyên nghiệp. Hãy chấm bài viết theo đúng cấp độ ${level}.

ĐỀ BÀI: ${prompt_vi}
YÊU CẦU: Bài viết phải bằng tiếng Nhật, tối thiểu ${min_words} từ.

BÀI VIẾT CỦA HỌC SINH:
"""
${response}
"""

TIÊU CHUẨN CHẤM ĐIỂM CHO ${level}:
${criteria}

HƯỚNG DẪN:
1. Nếu bài KHÔNG phải tiếng Nhật → is_valid_lang = false, tất cả điểm = 0.
2. Nếu đúng tiếng Nhật, chấm theo 3 tiêu chí (áp dụng tiêu chuẩn ${level} ở trên):
   - score_grammar (0-40)
   - score_vocab (0-30)
   - score_content (0-30)
3. score = tổng 3 tiêu chí (0-100)
4. errors: tối đa 5 lỗi quan trọng nhất
5. feedback_vi: nhận xét 2-4 câu tiếng Việt, thân thiện, ghi rõ điểm cần cải thiện theo cấp ${level}

Trả về JSON thuần (không markdown):
{
  "is_valid_lang": true,
  "score_grammar": 30,
  "score_vocab": 22,
  "score_content": 25,
  "score": 77,
  "feedback_vi": "...",
  "errors": [{"original": "...", "corrected": "...", "explanation_vi": "..."}]
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

  const cleaned = text.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '').trim()

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
  jlpt_level?: string | null,
): Promise<GradingResult> {
  const apiKey = process.env.GROQ_API_KEY
  if (!apiKey) throw new Error('GROQ_API_KEY chưa được cấu hình')

  const primaryModel = process.env.GROQ_MODEL ?? 'llama-3.3-70b-versatile'
  const fallbackModel = process.env.GROQ_MODEL_FALLBACK ?? 'llama-3.1-8b-instant'

  const prompt = buildGradingPrompt(prompt_vi, response, min_words, jlpt_level)

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
