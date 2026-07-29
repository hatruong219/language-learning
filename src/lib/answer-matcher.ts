/**
 * So đáp án theo hướng "bỏ qua tiểu tiết".
 *
 * Bản port TRUNG THÀNH từ `kana-quiz-popup/src/answer-matcher.js` — logic đó đã
 * chạy thật trên app desktop và app iPhone (bản Dart cũng port từ chính nó).
 * Giữ nguyên hành vi, KHÔNG tự chế luật thứ ba: ba bản cùng một luật mà lệch
 * nhau thì cùng một câu trả lời được chấm khác nhau ở ba nơi.
 *
 * Quy ước dữ liệu:
 *   - bỏ mọi ký hiệu trang trí (～ 。 、 ？ / khoảng trắng…), chỉ giữ kana + kanji
 *   - KHÔNG quy đổi katakana ↔ hiragana: từ gốc katakana phải gõ katakana
 *     (てーぷ ≠ テープ)
 *   - `A / B`   → chấp nhận A hoặc B
 *   - `（B）`    → cách gọi khác, chấp nhận dạng không ngoặc hoặc riêng B
 *   - `[B]`     → phần tùy chọn, chấp nhận cả dạng có và không có B
 *   - `[…～…]`  → chú thích ngữ cảnh, ～ đánh dấu vị trí từ chính:
 *                 とります [しゃしんを～] → とります hoặc しゃしんをとります
 */

const NON_KANA_KANJI = /[^ぁ-ゖァ-ヺー一-鿿㐀-䶿]/g

/** Giữ lại kana và kanji, vứt hết phần còn lại. */
export function normalize(str: string | null | undefined): string {
  return String(str ?? '').replace(NON_KANA_KANJI, '')
}

/**
 * Dự phòng cho đáp án lẫn chữ latin hoặc số (ví dụ ＣＤ).
 * Full-width → ASCII rồi thường hoá.
 */
export function normalizeLatin(str: string | null | undefined): string {
  return String(str ?? '')
    .replace(/[Ａ-Ｚａ-ｚ０-９]/g, (c) =>
      String.fromCharCode(c.charCodeAt(0) - 0xfee0),
    )
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '')
}

const SQUARE = /[[［]([^\]］]*)[\]］]/ // [tùy chọn]
const ROUND = /[(（]([^)）]*)[)）]/ // （biến thể）

/**
 * Sinh mọi dạng chấp nhận được từ một chuỗi đáp án gốc.
 *
 * `[カセット]テープ` → `カセットテープ`, `テープ`
 * `だれ（どなた）`   → `だれ`, `どなた`
 * `～ふん / ～ぷん`  → `ふん`, `ぷん`
 */
export function expandVariants(raw: string | null | undefined): string[] {
  // Chuỗi chứa chữ số hoặc chữ latin (２、３にち, IPSさいぼう…) không kana-hoá
  // trung thực được — bỏ qua, để nhánh cách đọc kana sạch quyết định.
  if (/[0-9０-９a-zA-ZＡ-Ｚａ-ｚ]/.test(String(raw ?? ''))) return []

  const expand = (v: string): string[] => {
    const sq = v.match(SQUARE)
    if (sq) {
      const inner = sq[1]
      if (/[～〜]/.test(inner)) {
        // Chú thích ngữ cảnh chứa ～/〜, sinh 3 dạng:
        //   riêng từ chính:       とります [しゃしんを～] → とります
        //   thế từ chính vào ～:  とります [しゃしんを～] → しゃしんをとります
        //   giữ vị trí, bỏ ～:    [〜を]ください         → をください
        const base = v.replace(sq[0], '').trim()
        return [
          ...expand(base),
          ...expand(inner.replace(/[～〜]/, base)),
          ...expand(v.replace(sq[0], inner.replace(/[～〜]/g, ''))),
        ]
      }
      return [
        ...expand(v.replace(sq[0], sq[1])),
        ...expand(v.replace(sq[0], '')),
      ]
    }
    const rd = v.match(ROUND)
    if (rd) return [...expand(v.replace(rd[0], '')), ...expand(rd[1])]
    return [v]
  }

  const variants = String(raw ?? '')
    .split(/[/／]/)
    .flatMap(expand)
  return [...new Set(variants.map(normalize).filter(Boolean))]
}

/**
 * Chấm một câu trả lời.
 *
 * `dbAnswers` nhận nhiều dạng của CÙNG một từ — ví dụ dạng viết có ngoặc và
 * cách đọc kana sạch. Khớp bất kỳ dạng nào là đúng.
 */
export function isCorrectAnswer(
  userInput: string,
  ...dbAnswers: (string | null | undefined)[]
): boolean {
  const input = normalize(userInput)
  if (input && dbAnswers.some((ans) => expandVariants(ans).includes(input))) {
    return true
  }
  // Dự phòng latin: đáp án kiểu ＣＤ thì gõ "CD" hay "ｃｄ" vẫn đúng.
  const latin = normalizeLatin(userInput)
  return !!latin && dbAnswers.some((ans) => normalizeLatin(ans) === latin)
}
