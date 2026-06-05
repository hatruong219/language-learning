

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="border-t border-border/40 py-8 mt-16 mt-auto">
      <div className="container mx-auto px-4 flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-muted-foreground">
        <div className="flex items-center gap-2 font-medium">
          <span className="text-lg" aria-hidden="true">🌸</span>
          <span className="text-foreground">日本語を学ぼう</span>
          <span className="hidden sm:inline-block text-muted-foreground/50 mx-2">|</span>
          <span className="hidden sm:inline-block">Học Tiếng Nhật mỗi ngày</span>
        </div>

        <div className="flex items-center gap-1">
          <span>© {currentYear} Created by</span>
          <a
            href="https://www.truongha.com/"
            target="_blank"
            rel="noopener noreferrer"
            className="font-medium text-foreground hover:underline underline-offset-4 transition-colors"
          >
            Truong H.A
          </a>
        </div>
      </div>
    </footer>
  )
}
