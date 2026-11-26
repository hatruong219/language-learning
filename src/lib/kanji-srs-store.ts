'use client'

import { useMemo, useSyncExternalStore } from 'react'
import type { SrsState, SrsStates } from './kanji-srs'

// Kết quả Nhớ / Quên lưu trong localStorage của trình duyệt — không cần tài
// khoản hay database. Đổi máy / đổi trình duyệt / xoá dữ liệu web thì mất.
const KEY = 'kanji-daily-srs-v1'

const listeners = new Set<() => void>()

function read(): string {
  try {
    return localStorage.getItem(KEY) ?? '{}'
  } catch {
    return '{}'
  }
}

function subscribe(cb: () => void) {
  listeners.add(cb)
  window.addEventListener('storage', cb) // tab khác ghi
  return () => {
    listeners.delete(cb)
    window.removeEventListener('storage', cb)
  }
}

function parse(raw: string): SrsStates {
  try {
    const v: unknown = JSON.parse(raw)
    return v && typeof v === 'object' ? (v as SrsStates) : {}
  } catch {
    return {}
  }
}

/** null khi đang render trên server / chưa đọc được trình duyệt */
export function useSrsStates(): SrsStates | null {
  const raw = useSyncExternalStore(subscribe, read, () => null)
  return useMemo(() => (raw === null ? null : parse(raw)), [raw])
}

export function saveSrsState(kanji: string, state: SrsState) {
  const all = parse(read())
  all[kanji] = state
  try {
    localStorage.setItem(KEY, JSON.stringify(all))
  } catch {
    // Safari riêng tư / hết dung lượng: bỏ qua, lần sau chấm lại
  }
  listeners.forEach((l) => l())
}
