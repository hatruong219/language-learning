

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

        <div className="flex items-center gap-6">
          <p>© {currentYear} Bản quyền thuộc về tác giả.</p>
        </div>
      </div>
    </footer>
  )
}
