import type { Vocabulary } from '@/types/database'

export type FlashCardResult = 'correct' | 'review' | 'wrong'

export interface StudyState {
  cards: Vocabulary[]
  currentIndex: number
  isFlipped: boolean
  results: {
    correct: Vocabulary[]
    review: Vocabulary[]
    wrong: Vocabulary[]
  }
  phase: 'studying' | 'complete'
}

export type StudyAction =
  | { type: 'FLIP' }
  | { type: 'MARK'; result: FlashCardResult }
  | { type: 'RESTART' }

export function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

export function studyReducer(state: StudyState, action: StudyAction): StudyState {
  switch (action.type) {
    case 'FLIP':
      return { ...state, isFlipped: true }

    case 'MARK': {
      const current = state.cards[state.currentIndex]
      const newResults = {
        ...state.results,
        [action.result]: [...state.results[action.result], current],
      }
      const nextIndex = state.currentIndex + 1
      const isDone = nextIndex >= state.cards.length

      return {
        ...state,
        results: newResults,
        currentIndex: isDone ? state.currentIndex : nextIndex,
        isFlipped: false,
        phase: isDone ? 'complete' : 'studying',
      }
    }

    case 'RESTART':
      return createInitialState(shuffleArray(state.cards))

    default:
      return state
  }
}

export function createInitialState(cards: Vocabulary[]): StudyState {
  return {
    cards: shuffleArray(cards),
    currentIndex: 0,
    isFlipped: false,
    results: { correct: [], review: [], wrong: [] },
    phase: 'studying',
  }
}

export function getProgress(state: StudyState): number {
  if (state.cards.length === 0) return 0
  const done =
    state.results.correct.length +
    state.results.review.length +
    state.results.wrong.length
  return Math.round((done / state.cards.length) * 100)
}
