## 日本語を学ぼう — Language Learning App

Ứng dụng web giúp học tiếng Nhật (và có thể mở rộng thêm ngôn ngữ khác sau này) với từ vựng, flashcard, bảng chữ cái và JLPT filter rõ ràng.

### 🔧 Tech stack
- **Frontend**: `Next.js 14+ (App Router)`, `TypeScript (strict)`, `Tailwind CSS v4`, `shadcn/ui`, `framer-motion`
- **Backend / Data**: `Supabase` (PostgreSQL, Auth trong tương lai)
- **Khác**: Web Speech API (Text‑to‑Speech), CSS animations

---

### ✨ Tính năng chính
- **Từ vựng**  
  - Danh sách tất cả từ vựng, filter theo **deck / chủ đề**, **JLPT (N5 → N1)**, và search.  
  - Thẻ từ hiển thị chữ Nhật, furigana, romaji, nghĩa tiếng Việt, badge JLPT, nút nghe TTS.

- **Flashcard**  
  - Học **toàn bộ từ vựng** hoặc theo từng deck: `/flashcard`, `/flashcard/[slug]`.  
  - Chọn số lượng thẻ (10 / 20 / 30 / 50 / tất cả / tùy chỉnh) và **lọc theo nhiều cấp độ JLPT cùng lúc**.  
  - Giao diện flashcard có hiệu ứng lật, auto‑play TTS khi lật sang mặt sau, phím tắt (Space / ← / ↓ / →), thống kê sau khi học xong.

- **Chủ đề (Decks)**  
  - Trang `/decks` hiển thị các deck với emoji, mô tả ngắn, số lượng từ.  
  - Mỗi deck có trang chi tiết và nút “Học flashcard”.

- **Bảng chữ cái**  
  - Trang `/alphabet` hiển thị **hiragana** và **katakana** theo hàng A / K / S / T / N / H / M / Y / R / W.  
  - Mỗi ô chữ có romaji, click để phát âm, icon loa nhấp nháy khi đang đọc.

---

### 🖼 Screenshots

> Gợi ý: lưu screenshot vào `public/screens/` rồi update đường dẫn bên dưới cho khớp.

- **Trang Flashcard — chọn số lượng & JLPT**
  
  `![Flashcard setup](public/screens/flashcard-setup.png)`

- **Bảng chữ cái Hiragana/Katakana**
  
  `![Alphabet chart](public/screens/alphabet.png)`

- **Danh sách từ vựng**
  
  `![Vocabulary list](public/screens/vocabulary-list.png)`

---

### 🚀 Chạy local

Yêu cầu: Node.js LTS, `pnpm`.

```bash
pnpm install
cp .env.local.example .env.local  # điền các env bên dưới
pnpm dev
```

Ứng dụng chạy tại `http://localhost:3000`.

---

### 🔐 Biến môi trường

File `.env.local`:

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SITE_ID=  # UUID của site trong bảng sites
```

---

### 🗄 Cấu trúc & Database (tóm tắt)

- `src/app/` — App Router pages (`/`, `/vocabulary`, `/decks`, `/flashcard`, `/alphabet`, …)  
- `src/components/` — UI components (PascalCase.tsx)  
- `src/lib/supabase/` — client/server helpers cho Supabase  
- `src/lib/tts.ts` — wrapper Web Speech API  
- `src/types/database.ts` — type cho các bảng Supabase  
- `supabase/migrations/` — file SQL migration

Các bảng chính:
- `decks` — chủ đề học tập  
- `vocabulary` — từ vựng (gồm `jlpt_level`, `deck_id`, …)  
- `vocabulary_examples` — câu ví dụ  
- `alphabet_characters` — bảng chữ cái  
- (Phase 2) `user_progress`, `study_sessions` cho tracking tiến độ

---

### 📌 Roadmap ngắn
- Seed đủ bộ từ JLPT N5–N4 (~800–1500 từ).  
- Thêm **Quiz mode** (`/quiz`) với multiple‑choice.  
- Lưu **tiến độ học** theo user, spaced repetition.

