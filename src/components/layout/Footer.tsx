import Link from 'next/link'

export function Footer() {
  return (
    <footer className="border-t border-border/40 py-8 mt-16">
      <div className="container mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-muted-foreground">
        <div className="flex items-center gap-2">
          <span className="text-lg">🌸</span>
          <span>日本語を学ぼう — Học Tiếng Nhật</span>
        </div>
        <div className="flex gap-4">
          <Link href="/vocabulary" className="hover:text-foreground transition-colors">Từ vựng</Link>
          <Link href="/decks" className="hover:text-foreground transition-colors">Chủ đề</Link>
          <Link href="/flashcard" className="hover:text-foreground transition-colors">Flashcard</Link>
          <Link href="/alphabet" className="hover:text-foreground transition-colors">Bảng chữ</Link>
        </div>
      </div>
    </footer>
  )
}
