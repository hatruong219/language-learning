/**
 * Sinh bài tập ngữ pháp từ CÂU VÍ DỤ của giáo trình.
 *
 * Vì sao cần: bảng `mnn_exercises` là bài tập viết tay, chỉ có bài 1–5 (138
 * câu). Bài 6–50 mở tab Luyện tập ra là trống. Còn `mnn_sentences` có 1247 câu
 * phủ đủ 50 bài — sinh đề từ đó thì không phải soạn tay câu nào.
 *
 * Luật ở đây port từ bản Dart trong app iPhone, đã dò tay và có test quét toàn
 * bộ kho. Sửa luật ở một bên thì phải sửa bên kia.
 */

export type Sentence = {
  ja_kanji: string
  ja_kana: string
  vi: string
}

export type GeneratedExercise = {
  id: string
  type: 'fill_blank' | 'multiple_choice'
  question: string
  options: string[] | null
  answer: string
  explanation_vi: string | null
}

/**
 * Chỗ trống chỉ khoét vào những trợ từ MỘT ký tự này.
 *
 * Trợ từ nhiều ký tự (から, まで, より) khoét ra thì nhìn độ dài chỗ trống là
 * đoán được, hỏng cả câu hỏi.
 */
const PARTICLES = ['は', 'が', 'を', 'に', 'で', 'と', 'も', 'へ', 'の', 'や']

/**
 * Cặp hay lẫn nhau — dùng làm phương án nhiễu trước tiên.
 *
 * Mọi giá trị PHẢI nằm trong PARTICLES. Nhiễu ngoài tập được khoét thì nó không
 * bao giờ là đáp án, và học vài phiên là loại được nó mà không cần đọc câu.
 */
const CONFUSABLE: Record<string, string[]> = {
  は: ['が', 'も', 'を'],
  が: ['は', 'を', 'に'],
  を: ['が', 'は', 'に'],
  に: ['で', 'へ', 'を'],
  で: ['に', 'を', 'と'],
  と: ['に', 'や', 'で'],
  も: ['は', 'が', 'を'],
  へ: ['に', 'で', 'を'],
  の: ['が', 'は', 'に'],
  や: ['と', 'も', 'の'],
}

const KANJI = /[一-鿿]/u

/**
 * Ký tự tố cáo câu còn dính rác của nguồn.
 *
 * Riki trộn số thứ tự bài tập, nhãn người nói và chú thích vào cùng ô với câu:
 * `例2：このパソコンの…`, `男の人：重いでしょう？`. Đọc thì vẫn hiểu, nhưng đưa
 * vào đề trắc nghiệm thì thành đề hỏng — nhất là khi chỗ trống rơi đúng vào
 * phần trong ngoặc.
 */
const DIRTY = /[例：:[\]（）()＝→※…]/u

/** Câu dùng được làm ĐỀ. Lỏng hơn thì đề nhìn như lỗi hiển thị. */
export function usable(s: Sentence): boolean {
  return (
    !DIRTY.test(s.ja_kanji) &&
    !DIRTY.test(s.vi) &&
    s.ja_kanji.length <= 34 &&
    s.vi.length >= 6
  )
}

function shuffle<T>(arr: readonly T[]): T[] {
  const out = [...arr]
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[out[i], out[j]] = [out[j], out[i]]
  }
  return out
}

/**
 * Khoét MỘT trợ từ đứng ngay sau một chữ kanji.
 *
 * Ràng buộc "ngay sau kanji" là cách nhận trợ từ mà KHÔNG cần tách từ. Kana
 * đứng sau kanji gần như luôn là trợ từ, còn đuôi động từ (読みます, 聞きます)
 * dùng み・き・り… chứ không dùng は・が・を. Bỏ sót vài câu thì không sao —
 * 1247 câu là thừa; khoét nhầm giữa một từ mới là hỏng, vì lúc đó đề không còn
 * đáp án đúng nào.
 */
function makeParticle(s: Sentence, index: number): GeneratedExercise | null {
  const text = s.ja_kanji
  const spots: number[] = []

  for (let i = 1; i < text.length; i++) {
    const ch = text[i]
    if (!PARTICLES.includes(ch)) continue
    if (!KANJI.test(text[i - 1])) continue
    const next = i + 1 < text.length ? text[i + 1] : ''
    // で của です／でした／ではありません là HỆ TỪ, không phải trợ từ. Khoét vào
    // đó thì đề vô nghĩa: 便利◯す。 không có đáp án nào đúng.
    if (ch === 'で' && 'すしは'.includes(next)) continue
    // Cùng lý do: や của 冷やす／増やす là đuôi động từ.
    if (ch === 'や' && 'すし'.includes(next)) continue
    spots.push(i)
  }
  if (spots.length === 0) return null

  const at = spots[Math.floor(Math.random() * spots.length)]
  const answer = text[at]

  const wrong = new Set<string>()
  for (const p of [
    ...(CONFUSABLE[answer] ?? []),
    ...PARTICLES.filter((x) => x !== answer),
  ]) {
    if (wrong.size >= 3) break
    if (p !== answer) wrong.add(p)
  }
  if (wrong.size < 3) return null

  return {
    id: `gen-p-${index}`,
    type: 'multiple_choice',
    question: `${text.slice(0, at)}◯${text.slice(at + 1)}`,
    options: shuffle([answer, ...wrong]),
    answer,
    explanation_vi: s.vi,
  }
}

/**
 * Câu tiếng Nhật → chọn bản dịch.
 *
 * Nhiễu phải khác hẳn đáp án về nội dung nhưng gần về độ dài: câu dịch dài gấp
 * đôi ba câu kia thì chọn được mà không cần đọc tiếng Nhật.
 */
function makeMeaning(
  s: Sentence,
  pool: readonly Sentence[],
  index: number,
): GeneratedExercise | null {
  const answer = s.vi
  if (!answer) return null

  const near: string[] = []
  const far: string[] = []
  for (const o of pool) {
    if (o.vi === answer || !o.vi) continue
    // Loại câu dịch trùng phần đầu: 「Anh Hải là bác sĩ.」 và 「Anh Hải là bác
    // sĩ phải không.」 đặt cạnh nhau thì không còn một đáp án đúng duy nhất.
    if (tooClose(o.vi, answer)) continue
    ;(Math.abs(o.vi.length - answer.length) <= 12 ? near : far).push(o.vi)
  }

  const options = new Set<string>()
  for (const bucket of [near, far]) {
    for (const v of shuffle(bucket)) {
      if (options.size >= 3) break
      options.add(v)
    }
    if (options.size >= 3) break
  }
  if (options.size < 3) return null

  return {
    id: `gen-m-${index}`,
    type: 'multiple_choice',
    question: s.ja_kanji,
    options: shuffle([answer, ...options]),
    answer,
    explanation_vi: s.ja_kana !== s.ja_kanji ? s.ja_kana : null,
  }
}

function tooClose(a: string, b: string): boolean {
  const x = a.toLowerCase()
  const y = b.toLowerCase()
  if (x.includes(y) || y.includes(x)) return true
  const n = Math.min(x.length, y.length)
  let same = 0
  while (same < n && x[same] === y[same]) same++
  return same >= 10
}

/**
 * Sinh tối đa `limit` bài tập từ danh sách câu ví dụ của một bài.
 *
 * Mỗi câu chỉ ra đề MỘT lần — gặp lại cùng một câu ở câu 3 và câu 8 làm phiên
 * trông như hết đề.
 */
export function generateExercises(
  sentences: readonly Sentence[],
  limit: number,
): GeneratedExercise[] {
  const pool = sentences.filter(usable)
  if (pool.length === 0) return []

  const out: GeneratedExercise[] = []
  const seen = new Set<string>()
  let i = 0

  for (const s of shuffle(pool)) {
    if (out.length >= limit) break
    if (seen.has(s.ja_kanji)) continue
    seen.add(s.ja_kanji)
    const ex =
      Math.random() < 0.5
        ? (makeParticle(s, i) ?? makeMeaning(s, pool, i))
        : (makeMeaning(s, pool, i) ?? makeParticle(s, i))
    if (ex) {
      out.push(ex)
      i++
    }
  }
  return out
}
