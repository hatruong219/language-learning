// Lịch nhắc lại cho kanji mỗi ngày (kiểu Leitner, khoảng cách cố định).
//
// - Chữ mới mở buổi sáng → đến hạn ôn ngay chiều hôm đó (lần ôn đầu).
// - Bấm "Nhớ"  → lên một bậc, hẹn lần tới sau 1 → 3 → 7 → 14 → 30 → 60 → 120 ngày.
//   Ở bậc cuối thì cứ 120 ngày ôn một lần — không bao giờ "hết".
// - Bấm "Quên" → về bậc đầu, ôn lại vào ngày mai.
// - Chưa bấm gì thì chữ vẫn nằm trong danh sách cần ôn cho tới khi được chấm.
//
// Trạng thái chỉ lưu trên trình duyệt (kanji-srs-store.ts) cho chữ đã từng
// được chấm; chữ chưa chấm thì suy ra từ ngày mở.

import { KANJI, introDate, learnedCount, addDays, type DailyKanji } from './daily-kanji'

export const INTERVALS = [1, 3, 7, 14, 30, 60, 120] as const

export type SrsState = {
  step: number // số lần "Nhớ" liên tiếp
  due: string // ngày cần ôn tiếp theo 'YYYY-MM-DD'
  lastReviewed: string | null
  reviews: number
  lapses: number
}

/** Trạng thái đã lưu, theo chữ */
export type SrsStates = Record<string, SrsState>

export type SrsItem = { kanji: DailyKanji; index: number; state: SrsState }

export function stateOf(index: number, saved?: SrsState): SrsState {
  return saved ?? { step: 0, due: introDate(index), lastReviewed: null, reviews: 0, lapses: 0 }
}

export function grade(state: SrsState, remembered: boolean, today: string): SrsState {
  if (!remembered) {
    return {
      step: 0,
      due: addDays(today, 1),
      lastReviewed: today,
      reviews: state.reviews + 1,
      lapses: state.lapses + 1,
    }
  }
  const interval = INTERVALS[Math.min(state.step, INTERVALS.length - 1)]
  return {
    step: state.step + 1,
    due: addDays(today, interval),
    lastReviewed: today,
    reviews: state.reviews + 1,
    lapses: state.lapses,
  }
}

/** Tất cả chữ đã mở tính tới `today`, kèm trạng thái ôn */
export function learnedItems(today: string, saved: SrsStates): SrsItem[] {
  return KANJI.slice(0, learnedCount(today)).map((kanji, index) => ({
    kanji,
    index,
    state: stateOf(index, saved[kanji.k]),
  }))
}

/** Chữ đến hạn ôn: quá hạn lâu nhất lên trước */
export function dueItems(today: string, saved: SrsStates): SrsItem[] {
  return learnedItems(today, saved)
    .filter((it) => it.state.due <= today)
    .sort((a, b) =>
      a.state.due === b.state.due ? a.index - b.index : a.state.due < b.state.due ? -1 : 1,
    )
}

/**
 * Chữ đến hạn hôm nay THEO LỊCH CHUẨN — giả sử lần nào cũng bấm "Nhớ" đúng
 * hạn. Dùng cho push buổi chiều: server không đọc được trạng thái trên trình
 * duyệt, nên chữ bị "Quên" chỉ hiện thêm khi mở trang ôn.
 */
export function scheduledReviews(today: string): DailyKanji[] {
  return KANJI.slice(0, learnedCount(today)).filter((_, index) => {
    let s = stateOf(index)
    while (s.due < today) s = grade(s, true, s.due)
    return s.due === today
  })
}
