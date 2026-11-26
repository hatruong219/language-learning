'use client'

import { useState, useSyncExternalStore } from 'react'
import { Bell, Copy } from 'lucide-react'

const SW_URL = '/kanji-daily-sw.js'
// Không có dấu / cuối: scope so khớp theo tiền tố, '/kanji/daily/' sẽ không
// bao trang danh sách '/kanji/daily' → service worker không bao giờ "ready".
const SW_SCOPE = '/kanji/daily'
const VAPID_PUBLIC_KEY = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY ?? ''

type Env = 'unsupported' | 'browser' | 'app'

function readEnv(): Env {
  const supported = 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window
  const standalone =
    window.matchMedia('(display-mode: standalone)').matches ||
    (navigator as Navigator & { standalone?: boolean }).standalone === true
  if (standalone) return supported ? 'app' : 'unsupported'
  // iOS chỉ cho Web Push khi mở từ icon trên Màn hình chính, không cho trong tab Safari
  if (/iPhone|iPad|iPod/.test(navigator.userAgent)) return 'browser'
  return supported ? 'app' : 'unsupported'
}

const noop = () => () => {}

/** VAPID public key (base64url) → bytes cho pushManager.subscribe */
function keyBytes(base64url: string): Uint8Array<ArrayBuffer> {
  const b64 = (base64url + '='.repeat((4 - (base64url.length % 4)) % 4)).replace(/-/g, '+').replace(/_/g, '/')
  const raw = atob(b64)
  const out = new Uint8Array(new ArrayBuffer(raw.length))
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i)
  return out
}

/** Chờ chính registration này có worker đang chạy (không dùng serviceWorker.ready,
 *  vì nó chỉ resolve khi trang hiện tại nằm trong scope). */
function waitActive(reg: ServiceWorkerRegistration): Promise<ServiceWorkerRegistration> {
  if (reg.active) return Promise.resolve(reg)
  const sw = reg.installing ?? reg.waiting
  if (!sw || sw.state === 'activated') return Promise.resolve(reg)
  return new Promise((resolve) => {
    sw.addEventListener('statechange', () => {
      if (sw.state === 'activated') resolve(reg)
    })
  })
}

function withTimeout<T>(p: Promise<T>, ms: number, message: string): Promise<T> {
  return Promise.race([
    p,
    new Promise<never>((_, reject) => setTimeout(() => reject(new Error(message)), ms)),
  ])
}

/**
 * Bật thông báo Web Push cho app. Chỉ một người dùng nên không lưu đăng ký vào
 * database: hiện mã đăng ký để dán vào biến môi trường PUSH_SUBSCRIPTION.
 */
export function NotifySetup() {
  const env = useSyncExternalStore(noop, readEnv, () => null)
  const [code, setCode] = useState('')
  const [status, setStatus] = useState('')
  const [busy, setBusy] = useState(false)

  if (env === null) return null

  const enable = async () => {
    setBusy(true)
    setStatus('')
    try {
      const perm = await Notification.requestPermission()
      if (perm !== 'granted') {
        setStatus('Chưa được cho phép thông báo. Vào Cài đặt → Thông báo → Kanji để bật.')
        return
      }
      const reg = await withTimeout(
        navigator.serviceWorker.register(SW_URL, { scope: SW_SCOPE }).then(waitActive),
        20_000,
        'Service worker không khởi động được',
      )
      const sub =
        (await reg.pushManager.getSubscription()) ??
        (await withTimeout(
          reg.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: keyBytes(VAPID_PUBLIC_KEY),
          }),
          20_000,
          'Đăng ký nhận thông báo quá lâu',
        ))
      setCode(JSON.stringify(sub))
    } catch (e) {
      setStatus(`Lỗi: ${e instanceof Error ? e.message : String(e)}`)
    } finally {
      setBusy(false)
    }
  }

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(code)
      setStatus('Đã sao chép mã đăng ký.')
    } catch {
      setStatus('Không sao chép được — bấm giữ vào ô mã để chọn và sao chép.')
    }
  }

  return (
    <section className="space-y-3 rounded-2xl border bg-card p-4">
      <h2 className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        <Bell className="h-3.5 w-3.5" /> Thông báo
      </h2>

      {env === 'browser' && (
        <p className="text-sm text-muted-foreground">
          Để nhận thông báo: bấm Chia sẻ → <b>Thêm vào MH chính</b>, rồi mở trang từ icon <b>Kanji</b> và bật
          thông báo ở đây.
        </p>
      )}
      {env === 'unsupported' && (
        <p className="text-sm text-muted-foreground">Thiết bị này chưa hỗ trợ thông báo web (cần iOS 16.4 trở lên).</p>
      )}
      {env === 'app' && (
        <>
          <button
            type="button"
            onClick={enable}
            disabled={busy || !VAPID_PUBLIC_KEY}
            className="w-full rounded-xl bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground disabled:opacity-50"
          >
            {busy ? 'Đang bật…' : code ? 'Lấy lại mã đăng ký' : 'Bật thông báo'}
          </button>
          {!VAPID_PUBLIC_KEY && (
            <p className="text-sm text-rose-600 dark:text-rose-400">Thiếu NEXT_PUBLIC_VAPID_PUBLIC_KEY trên server.</p>
          )}
          {code && (
            <div className="space-y-2">
              <p className="text-sm text-muted-foreground">
                Dán mã này vào biến <code className="font-mono">PUSH_SUBSCRIPTION</code> trên Vercel rồi redeploy:
              </p>
              <textarea
                readOnly
                value={code}
                rows={4}
                className="w-full rounded-lg border bg-background p-2 font-mono text-xs"
                onFocus={(e) => e.currentTarget.select()}
              />
              <button
                type="button"
                onClick={copy}
                className="inline-flex items-center gap-1.5 rounded-xl border px-3 py-1.5 text-sm font-medium hover:bg-accent"
              >
                <Copy className="h-4 w-4" /> Sao chép
              </button>
            </div>
          )}
        </>
      )}
      {status && <p className="text-sm">{status}</p>}
    </section>
  )
}
