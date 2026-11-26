import Link from 'next/link'
import type { Metadata, Viewport } from 'next'

// Trang riêng cho kanji mỗi ngày: không có menu của web học, không được link
// từ đâu trong site — chỉ ai có link mới vào. Logo để quay về web học.
//
// Khai báo là web app (manifest + appleWebApp): thêm vào Màn hình chính sẽ mở
// toàn màn hình, có vùng lưu trữ riêng; thông báo Web Push bấm vào mở thẳng
// trong app nên tiến độ ôn (localStorage) luôn nằm một chỗ.
export const metadata: Metadata = {
  robots: { index: false, follow: false },
  manifest: '/kanji-daily/manifest.webmanifest',
  appleWebApp: { capable: true, title: 'Kanji', statusBarStyle: 'default' },
  icons: { apple: '/kanji-daily/apple-touch-icon.png' },
}

export const viewport: Viewport = { themeColor: '#10b981' }

export default function DailyLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen">
      <header className="border-b border-border/40 pt-[env(safe-area-inset-top)]">
        <div className="mx-auto flex h-12 max-w-xl items-center px-4">
          <Link href="/" className="flex items-center gap-2 font-bold">
            <span className="text-xl" aria-hidden="true">🌸</span>
            <span>日本語を学ぼう</span>
          </Link>
        </div>
      </header>
      <main className="mx-auto max-w-xl px-4 pt-5 pb-16">{children}</main>
    </div>
  )
}
