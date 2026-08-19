import { isCorrectAnswer } from './answer-matcher'

/**
 * Bộ dựng đề dùng chung cho MỌI nguồn từ vựng.
 *
 * Nó KHÔNG biết dữ liệu tới từ bảng nào — chỉ nhận một danh sách phẳng. Nhờ vậy
 * Từ vựng (`vocabulary`), Minano (`mnn_vocabulary`) và Kanji
 * (`jlpt_kanji_words`) dùng chung một màn, một luật chấm, một cách đếm.
 *
 * Tiền tố `id` nói rõ nguồn — cùng quy ước app iPhone đang dùng.
 */

export type QuizWord = {
  /** `v-<uuid>` | `mnn-<uuid>` | `kw3` — tiền tố cho biết nguồn. */
  id: string
  /** Dạng viết. Có thể là kanji, có thể toàn kana. */
  word: string
  /** Cách đọc, toàn kana. */
  reading: string
  meaning: string
}

export type QuizKind =
  /** Cho nghĩa tiếng Việt, GÕ lại bằng kana. Khó nhất, sát thi nhất. */
  | 'vi2ja'
  /** Cho từ tiếng Nhật, chọn 1 trong 4 nghĩa. */
  | 'ja2vi'
  /** 漢字読み — cho từ viết kanji, chọn cách đọc. */
  | 'reading'
  /** 表記 — cho từ viết kana, chọn dạng viết kanji. */
  | 'writing'

export type Question = {
  kind: QuizKind
  word: QuizWord
  /** Chuỗi hiện trên đề. */
  prompt: string
  answer: string
  /** Bốn phương án đã xáo. `null` nghĩa là dạng GÕ tự do. */
  options: string[] | null
  /** Dòng gợi ý dưới đề. Rỗng thì không hiện. */
  hint: string
}

export const OPTION_COUNT = 4

const KANJI = /[一-鿿]/u

/** Từ có ít nhất một chữ Hán — điều kiện cho hai dạng 漢字読み và 表記. */
export function hasKanji(w: QuizWord): boolean {
  return KANJI.test(w.word)
}

function kanjiIn(s: string): string[] {
  return [...new Set(s.match(/[一-鿿]/gu) ?? [])]
}

/**
 * Bộ sinh số giả ngẫu nhiên có hạt giống.
 *
 * Cần hạt giống để dựng lại đúng bộ đề khi tìm lỗi — `Math.random()` thì mỗi
 * lần một khác, gặp đề hỏng cũng không tái hiện được.
 */
function makeRng(seed: number): () => number {
  let s = seed >>> 0 || 1
  return () => {
    s ^= s << 13
    s ^= s >>> 17
    s ^= s << 5
    return ((s >>> 0) % 100000) / 100000
  }
}

function shuffle<T>(arr: readonly T[], rng: () => number): T[] {
  const out = [...arr]
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1))
    ;[out[i], out[j]] = [out[j], out[i]]
  }
  return out
}

/**
 * Ba phương án sai, ưu tiên loại KHÓ.
 *
 * Nhiễu tốt nhất là từ CÙNG CHỨA một chữ Hán với đáp án: hỏi 学生 thì nhiễu
 * 学校 buộc phân biệt がくせい với がっこう — đúng chỗ đề thi nhắm. Nhiễu ngẫu
 * nhiên thì loại được bằng độ dài, quá dễ.
 *
 * Hết nhiễu cùng chữ thì lấy theo độ dài xấp xỉ, cuối cùng lấy bừa — thà câu
 * dễ còn hơn không dựng nổi câu.
 */
function distractors(
  target: QuizWord,
  pool: readonly QuizWord[],
  formOf: (w: QuizWord) => string,
  answer: string,
  rng: () => number,
): string[] {
  const chars = new Set(kanjiIn(target.word))
  const sharing: string[] = []
  const similar: string[] = []
  const rest: string[] = []

  for (const w of pool) {
    if (w.id === target.id) continue
    const f = formOf(w).trim()
    if (!f || f === answer) continue
    if (chars.size > 0 && kanjiIn(w.word).some((c) => chars.has(c))) {
      sharing.push(f)
    } else if (Math.abs(f.length - answer.length) <= 1) {
      similar.push(f)
    } else {
      rest.push(f)
    }
  }

  const out = new Set<string>()
  for (const bucket of [sharing, similar, rest]) {
    for (const f of shuffle(bucket, rng)) {
      if (out.size >= OPTION_COUNT - 1) break
      out.add(f)
    }
    if (out.size >= OPTION_COUNT - 1) break
  }
  return [...out]
}

function makeQuestion(
  w: QuizWord,
  kind: QuizKind,
  pool: readonly QuizWord[],
  rng: () => number,
): Question | null {
  if (!w.reading.trim() || !w.meaning.trim()) return null

  if (kind === 'vi2ja') {
    // Dạng GÕ: không có phương án, chấm bằng luật khớp lỏng.
    return {
      kind,
      word: w,
      prompt: w.meaning,
      answer: w.reading,
      options: null,
      hint: '',
    }
  }

  const spec: Record<
    Exclude<QuizKind, 'vi2ja'>,
    { prompt: string; answer: string; formOf: (x: QuizWord) => string }
  > = {
    ja2vi: {
      prompt: w.word,
      answer: w.meaning,
      formOf: (x) => x.meaning,
    },
    reading: {
      prompt: w.word,
      answer: w.reading,
      formOf: (x) => x.reading,
    },
    writing: {
      prompt: w.reading,
      answer: w.word,
      formOf: (x) => x.word,
    },
  }

  const { prompt, answer, formOf } = spec[kind]
  if (!prompt.trim() || !answer.trim() || prompt === answer) return null

  const wrong = distractors(w, pool, formOf, answer, rng)
  if (wrong.length < OPTION_COUNT - 1) return null

  return {
    kind,
    word: w,
    prompt,
    answer,
    options: shuffle([answer, ...wrong], rng),
    // Dạng 漢字読み và 表記 hỏi chữ trơ, nên nghĩa thay vai ngữ cảnh mà đề thi
    // thật có sẵn nhờ đặt từ trong câu.
    hint: kind === 'ja2vi' ? '' : w.meaning,
  }
}

/**
 * Dựng bộ đề cho MỘT dạng câu hỏi, ra đề HẾT phạm vi đã chọn.
 *
 * Không có tuỳ chọn "số câu": phạm vi CHÍNH LÀ cỡ phiên. Chọn 400 từ rồi lại
 * bắt chọn tối đa 40 câu là thừa một bước mà vẫn không kiểm soát được gì —
 * muốn ít thì chọn ít bài.
 *
 * Mỗi từ chỉ hỏi MỘT lần. Từ nào không dựng nổi dạng đó thì bỏ qua, không báo
 * lỗi: `writing` cần từ có chữ Hán, `ja2vi` cần đủ 3 nghĩa khác trong kho.
 */
export function buildQuiz(
  words: readonly QuizWord[],
  kind: QuizKind,
  seed = Date.now(),
): Question[] {
  if (words.length === 0) return []
  const rng = makeRng(seed)
  const out: Question[] = []

  for (const w of shuffle(words, rng)) {
    // Hai dạng chữ Hán chỉ dựng được khi từ CÓ chữ Hán.
    if ((kind === 'reading' || kind === 'writing') && !hasKanji(w)) continue
    const q = makeQuestion(w, kind, words, rng)
    if (q) out.push(q)
  }
  return out
}

/** Đếm số từ ra đề được với dạng này, không dựng thật. */
export function countAvailable(
  words: readonly QuizWord[],
  kind: QuizKind,
): number {
  const needsKanji = kind === 'reading' || kind === 'writing'
  return words.filter(
    (w) => w.reading.trim() && w.meaning.trim() && (!needsKanji || hasKanji(w)),
  ).length
}

/** Chấm một câu. Dạng gõ đi qua luật khớp lỏng, dạng chọn thì so thẳng. */
export function checkAnswer(q: Question, input: string): boolean {
  if (q.options) return input === q.answer
  // Chấp nhận cả cách đọc lẫn dạng viết: gõ 学生 hay がくせい đều là từ đó.
  return isCorrectAnswer(input, q.word.reading, q.word.word)
}

export type AnswerState = 'pending' | 'correct' | 'wrong' | 'skipped'

/**
 * Bốn con số, cộng lại LUÔN bằng tổng.
 *
 * App từng thiếu "chưa làm" và người dùng thấy tổng không khớp — đó là lý do
 * tách hàm này ra một chỗ thay vì đếm rải rác trong giao diện.
 */
export function tally(states: readonly AnswerState[]) {
  const count = (s: AnswerState) => states.filter((x) => x === s).length
  return {
    total: states.length,
    correct: count('correct'),
    wrong: count('wrong'),
    skipped: count('skipped'),
    pending: count('pending'),
  }
}
