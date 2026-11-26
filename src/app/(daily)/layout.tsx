import Link from 'next/link'
import type { Metadata } from 'next'

// Trang riêng cho push kanji mỗi ngày: không có menu của web học, không được
// link từ đâu trong site — chỉ ai có link mới vào. Logo để quay về web học.
// Cố ý KHÔNG khai báo appleWebApp.capable: icon "Thêm vào Màn hình chính" sẽ
// mở trong Safari, dùng chung localStorage (tiến độ ôn) với link bấm từ push.
// Bật chế độ web app thì iOS tách dữ liệu riêng → tiến độ bị chia làm hai.
export const metadata: Metadata = {
  robots: { index: false, follow: false },
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
