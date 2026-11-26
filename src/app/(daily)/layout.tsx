import Link from 'next/link'
import type { Metadata } from 'next'

// Trang riêng cho push kanji mỗi ngày: không có menu của web học, không được
// link từ đâu trong site — chỉ ai có link mới vào. Logo để quay về web học.
export const metadata: Metadata = {
  robots: { index: false, follow: false },
  appleWebApp: { capable: true, title: 'Kanji mỗi ngày' },
}

export default function DailyLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen">
      <header className="border-b border-border/40">
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
