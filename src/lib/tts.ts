/**
 * Text-to-Speech wrapper using Web Speech API
 * Falls back silently if browser doesn't support it
 */

let currentUtterance: SpeechSynthesisUtterance | null = null

export function speak(text: string, lang = 'ja-JP', rate = 0.8) {
  if (typeof window === 'undefined') return
  if (!window.speechSynthesis) return

  // Cancel any ongoing speech
  window.speechSynthesis.cancel()

  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = rate
  utterance.pitch = 1
  utterance.volume = 1

  currentUtterance = utterance
  window.speechSynthesis.speak(utterance)
}

export function stopSpeaking() {
  if (typeof window === 'undefined') return
  window.speechSynthesis?.cancel()
  currentUtterance = null
}

export function isTTSSupported(): boolean {
  if (typeof window === 'undefined') return false
  return 'speechSynthesis' in window
}

export function isSpeaking(): boolean {
  if (typeof window === 'undefined') return false
  return window.speechSynthesis?.speaking ?? false
}
