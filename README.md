## 日本語を学ぼう — Language Learning App

Ứng dụng web học tiếng Nhật với từ vựng, flashcard, bảng chữ cái, luyện viết và chấm điểm tự động bằng AI.

### Tech stack
- **Frontend**: Next.js 16 (App Router), TypeScript strict, Tailwind CSS v4, shadcn/ui, framer-motion
- **Backend / Data**: Supabase (PostgreSQL)
- **AI**: Groq API — `llama-3.3-70b-versatile` (fallback: `llama-3.1-8b-instant`)
- **TTS**: Web Speech API (browser native)

---

### Tính năng chính

- **Từ vựng** — Danh sách, filter theo deck / JLPT / search, chi tiết từ với furigana, TTS, câu ví dụ.
- **Flashcard** — Học toàn bộ hoặc theo deck, chọn số lượng thẻ, lọc JLPT, flip animation, auto-play TTS, phím tắt.
- **Chủ đề (Decks)** — Grid deck với emoji, mô tả, số từ, nút học ngay.
- **Bảng chữ cái** — Hiragana + Katakana theo hàng, click nghe phát âm.
- **Luyện viết** — Nhận đề ngẫu nhiên, nộp bài viết tiếng Nhật, AI chấm điểm grammar/vocab/content và đưa ra nhận xét chi tiết.

---

### Routes đã implement

| Route | Mô tả |
|-------|-------|
| `/` | Home: hero, stats, decks nổi bật, từ ngẫu nhiên |
| `/vocabulary` | Danh sách từ vựng, filter, pagination |
| `/vocabulary/[id]` | Chi tiết từ: furigana, TTS, câu ví dụ |
| `/decks` | Danh sách tất cả deck |
| `/decks/[slug]` | Từ trong deck + nút học flashcard |
| `/flashcard` | Flashcard random toàn bộ |
| `/flashcard/[slug]` | Flashcard theo deck |
| `/alphabet` | Bảng Hiragana + Katakana với popup TTS |
| `/writing-test` | Luyện viết: đề ngẫu nhiên, nộp bài, AI chấm điểm |

---

### Chạy local

Yêu cầu: Node.js LTS, `pnpm`.

```bash
pnpm install
cp .env.example .env.local  # điền các env vars bên dưới
pnpm dev
```

Ứng dụng chạy tại `http://localhost:3000`.

---

### Biến môi trường

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SITE_ID=   # UUID của site trong bảng sites

# Groq — chấm bài viết tự động
# Lấy key tại: https://console.groq.com/keys
GROQ_API_KEY=
```

---

### Cấu trúc chính

```
src/
├── app/                      ← App Router pages
├── components/               ← UI components (PascalCase.tsx)
├── lib/
│   ├── supabase/             ← client.ts / server.ts
│   ├── groq.ts               ← AI grading (Groq API)
│   ├── tts.ts                ← Web Speech API wrapper
│   └── flashcard-utils.ts    ← Shuffle + state machine
├── types/database.ts         ← Supabase table types
supabase/migrations/          ← SQL migrations theo thứ tự
```

Database tables: `decks`, `vocabulary`, `vocabulary_examples`, `alphabet_characters`, `writing_prompts`, `writing_submissions`, `user_progress`, `study_sessions`

---

### Roadmap
- Seed đủ bộ từ JLPT N5–N4 (~800–1500 từ)
- Quiz mode `/quiz`
- User progress tracking (cần auth)
- Spaced repetition
