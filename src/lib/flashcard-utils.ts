import type { Vocabulary } from '@/types/database'

export interface StudyState {
  cards: Vocabulary[]
  currentIndex: number
  isFlipped: boolean
  phase: 'studying' | 'complete'
}

export type StudyAction =
  | { type: 'FLIP' }
  | { type: 'NEXT' }
  | { type: 'PREV' }
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
      return { ...state, isFlipped: !state.isFlipped }

    case 'NEXT': {
      const nextIndex = state.currentIndex + 1
      if (nextIndex >= state.cards.length) {
        return { ...state, phase: 'complete' }
      }
      return { ...state, currentIndex: nextIndex, isFlipped: false }
    }

    case 'PREV': {
      if (state.currentIndex === 0) return state
      return { ...state, currentIndex: state.currentIndex - 1, isFlipped: false }
    }

    case 'RESTART':
      return createInitialState(state.cards)

    default:
      return state
  }
}

export function createInitialState(cards: Vocabulary[]): StudyState {
  return {
    cards: shuffleArray(cards),
    currentIndex: 0,
    isFlipped: false,
    phase: 'studying',
  }
}

export function getProgress(state: StudyState): number {
  if (state.cards.length === 0) return 0
  return Math.round(((state.currentIndex + 1) / state.cards.length) * 100)
}
