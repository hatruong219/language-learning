'use client'

import { useEffect } from 'react'

/**
 * Enter đi tiếp khi màn đang hiện phần chấm điểm.
 *
 * Chấm xong thì ô gõ biến mất, không còn phần tử nào nhận Enter — nên phải
 * nghe ở `document`. Thiếu nó là mỗi câu buộc rời bàn phím bấm chuột một lần,
 * làm nát nhịp gõ của cả phiên mấy chục câu.
 *
 * @param active bật lúc đang hiện đáp án, tắt lúc còn đang chờ trả lời
 * @param onContinue việc chạy khi bấm Enter — thường là sang câu sau
 */
export function useEnterToContinue(active: boolean, onContinue: () => void) {
  useEffect(() => {
    if (!active) return

    // Chính cú Enter vừa chấm câu KHÔNG được tính là "đi tiếp" — nếu không,
    // người học bấm một lần mà mất luôn phần đáp án vừa hiện. Mốc thời gian
    // này loại mọi event bắt đầu trước khi listener có mặt, khỏi phải tin vào
    // thứ tự chạy effect của React.
    const attachedAt = performance.now()

    function onKeyDown(e: KeyboardEvent) {
      // `repeat`: giữ Enter không được phép quét qua nhiều câu một lúc.
      if (e.key !== 'Enter' || e.repeat) return
      if (e.timeStamp <= attachedAt) return
      e.preventDefault()
      onContinue()
    }

    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [active, onContinue])
}
