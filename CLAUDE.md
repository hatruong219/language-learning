# CLAUDE.md — language-learning

Website học tiếng Nhật (và các ngôn ngữ khác sau này).
Stack: Next.js 16 (App Router) · TypeScript strict · Tailwind v4 · shadcn/ui · Supabase · framer-motion

## Cấu trúc chính
- `src/app/` — Pages (Server Components mặc định)
- `src/components/` — UI components (PascalCase.tsx)
- `src/lib/supabase/` — client.ts (browser) / server.ts (RSC)
- `src/lib/tts.ts` — Web Speech API wrapper
- `src/lib/flashcard-utils.ts` — Shuffle + reducer cho flashcard state
- `src/types/database.ts` — Supabase table types (manual, chưa gen)
- `supabase/migrations/` — SQL migrations theo thứ tự

## Env vars bắt buộc (.env.local)
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SITE_ID=  ← UUID của site trong bảng sites
GROQ_API_KEY=         ← Groq: https://console.groq.com/keys (chấm bài viết: llama-3.3-70b-versatile, fallback llama-3.1-8b-instant; ĐỒNG THỜI dùng cho Whisper ở /kotoba-app/api/stt)
```

## Quy tắc code
- Không dùng `any`, strict TypeScript
- Server Components fetch qua `lib/supabase/server.ts`
- Client Components (`'use client'`) chỉ khi cần browser API hoặc interactive state
- Dùng `as unknown as Type` khi Supabase type inference không match
- File naming: pages → `page.tsx`, components → `PascalCase.tsx`, utils → `camelCase.ts`

## Màn hình đã implement (Phase 1 + Phase 2)
| Route | Mô tả |
|-------|-------|
| `/` | Home: hero, stats, decks nổi bật, từ ngẫu nhiên |
| `/vocabulary` | List từ vựng, filter (deck/jlpt/search), pagination |
| `/vocabulary/[id]` | Chi tiết từ: furigana, TTS, câu ví dụ |
| `/decks` | List tất cả deck |
| `/decks/[slug]` | Từ trong deck + nút học flashcard |
| `/flashcard` | Flashcard random toàn bộ |
| `/flashcard/[slug]` | Flashcard theo deck |
| `/alphabet` | Bảng Hiragana + Katakana với popup TTS |
| `/writing-test` | Luyện viết: nhận đề ngẫu nhiên, nộp bài, AI chấm điểm |
| `/kotoba-app` | Trang hướng dẫn cài app Kotoba lên màn hình chính (`src/app/kotoba-app/page.tsx`) |
| `/kotoba-app/app/index.html` | Kotoba: Flutter web PWA, file tĩnh từ `public/kotoba-app/app` (gitignored, sinh bởi `pnpm build:kotoba` → `scripts/build-kotoba-web.sh`) |
| `/kotoba-app/api/stt` | POST WAV → `{text}`, nhận diện giọng nói bằng Groq Whisper. Chặn lạm dụng ở `src/lib/sttGuards.ts` (same-origin, rate limit 30 lượt/phút/IP) + kiểm WAV/kích thước trong route |
| `/kotoba-app/api/kotoba/[resource]` | GET proxy sang `admin.truongha.com/api/kotoba/`, allowlist `grammar` · `kanji` · `kanji-words`; không chuyển cookie của người dùng |

## Kotoba (Flutter web) — thư mục `kotoba/`
- `kotoba/` là project **Flutter/Dart**, không thuộc quy tắc TypeScript ở trên. Sửa xong chạy trong `kotoba/`: `flutter analyze` + `flutter test`. Chi tiết: `kotoba/README.md`.
- Flutter cố định **3.32.0** (`scripts/build-kotoba-web.sh` tự clone nếu máy không có). `vercel.json` `buildCommand` = `pnpm build:kotoba && pnpm build`, cộng thêm ~5 phút mỗi lần deploy.
- `pnpm build` local KHÔNG cần Flutter (`/kotoba-app/app/` chỉ có khi đã chạy `pnpm build:kotoba`). `pnpm dev` + `flutter run` xem `kotoba/README.md`.
- Thêm chuỗi UI hoặc kanji mới → chạy lại `python3 kotoba/tools/subset-fonts.py` (font con đóng gói), rồi `python3 kotoba/tools/check-font-coverage.py` (thoát 1 nếu thiếu glyph; test `font_coverage_test.dart` đọc `tools/font-coverage.txt`).
- `GROQ_API_KEY` giờ cũng trả phí cho STT, route công khai: đặt **hạn mức chi tiêu (spend cap)** trên tài khoản Groq, đó là chốt chặn thật (guard trong code chỉ chặn lạm dụng thô).

## Database (Supabase)
Tables: `decks`, `vocabulary`, `vocabulary_examples`, `alphabet_characters`
Phase 2: `user_progress`, `study_sessions`
Tất cả đều có `site_id` FK → `sites(id)`
Migrations: `supabase/migrations/2026028000001..4_*.sql`

## Chạy local
```bash
pnpm install
cp .env.example .env.local  # điền env vars
pnpm dev
```

## Phase tiếp theo
- Seed data JLPT N5 (~800 từ)
- Quiz mode /quiz
- User progress tracking (cần auth)
- Spaced repetition
