'use client'

import { useState } from 'react'
import { buildQuiz } from '@/lib/quiz'
import type { AnswerState, Question, QuizKind, QuizWord } from '@/lib/quiz'
import { QuizSetup } from './QuizSetup'
import { QuizRunner } from './QuizRunner'
import { QuizSummary } from './QuizSummary'

interface Props {
  /** Danh sách từ. Nguồn nào cũng được — component không cần biết. */
  words: QuizWord[]
  /**
   * HAI dạng đề hợp với phần này; dạng đầu là mặc định.
   *
   * Từ vựng dùng `['vi2ja', 'ja2vi']`, chữ Hán dùng `['reading', 'writing']`.
   * Bày cả bốn ở mọi nơi thì màn chuẩn bị rối hơn cả việc học, mà hai dạng chữ
   * Hán không hợp với từ vựng Minna — phần lớn viết bằng kana.
   */
  kinds: readonly QuizKind[]
}

type Phase = 'setup' | 'running' | 'summary'

/**
 * Phiên luyện tập, dùng chung cho Từ vựng, Minano và Kanji.
 *
 * KHÔNG lưu tiến độ. Chỉ hiện kết quả phiên này rồi thôi — bên app đang có kế
 * hoạch đăng nhập và đồng bộ riêng, web nhảy vào lưu lúc này là đẻ ra một không
 * gian id thứ tư phải hoà giải về sau.
 */
export function QuizSession({ words, kinds }: Props) {
  const [phase, setPhase] = useState<Phase>('setup')
  const [kind, setKind] = useState<QuizKind>(kinds[0])
  const [questions, setQuestions] = useState<Question[]>([])
  const [states, setStates] = useState<AnswerState[]>([])
  const [answers, setAnswers] = useState<string[]>([])
  const [index, setIndex] = useState(0)

  function start() {
    const qs = buildQuiz(words, kind)
    if (qs.length === 0) return
    setQuestions(qs)
    setStates(qs.map(() => 'pending'))
    setAnswers(qs.map(() => ''))
    setIndex(0)
    setPhase('running')
  }

  function record(state: Exclude<AnswerState, 'pending'>, given: string) {
    setStates((prev) => prev.map((s, i) => (i === index ? state : s)))
    setAnswers((prev) => prev.map((a, i) => (i === index ? given : a)))
  }

  /**
   * Sang câu chưa làm gần nhất phía sau, vòng lại đầu nếu cần.
   *
   * Đọc `states` qua hàm cập nhật để chắc chắn thấy trạng thái vừa ghi ở
   * `record` — React gom nhiều `setState` trong cùng một sự kiện, đọc thẳng
   * biến `states` ở đây sẽ thấy bản CŨ và nhảy nhầm câu.
   */
  function next() {
    setStates((current) => {
      const remaining = current
        .map((s, i) => ({ s, i }))
        .filter(({ s }) => s === 'pending')
      if (remaining.length === 0) {
        setPhase('summary')
      } else {
        const after = remaining.find(({ i }) => i > index)
        setIndex((after ?? remaining[0]).i)
      }
      return current
    })
  }

  if (phase === 'setup') {
    return (
      <QuizSetup
        words={words}
        kinds={kinds}
        kind={kind}
        onKind={setKind}
        onStart={start}
      />
    )
  }

  if (phase === 'summary') {
    return (
      <QuizSummary
        questions={questions}
        states={states}
        answers={answers}
        onAgain={start}
        onDone={() => setPhase('setup')}
      />
    )
  }

  return (
    <QuizRunner
      // Dựng lại theo từng câu để state trong đó tự sạch, khỏi phải đặt lại
      // bằng effect.
      key={index}
      questions={questions}
      index={index}
      states={states}
      onAnswered={record}
      onNext={next}
      // Thoát giữa chừng vẫn CHỐT ĐIỂM: sang thẳng tổng kết, phần chưa làm hiện
      // ở cột "chưa làm" chứ không biến mất.
      onQuit={() => setPhase('summary')}
    />
  )
}
