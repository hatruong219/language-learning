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
```

## Quy tắc code
- Không dùng `any`, strict TypeScript
- Server Components fetch qua `lib/supabase/server.ts`
- Client Components (`'use client'`) chỉ khi cần browser API hoặc interactive state
- Dùng `as unknown as Type` khi Supabase type inference không match
- File naming: pages → `page.tsx`, components → `PascalCase.tsx`, utils → `camelCase.ts`

## Màn hình đã implement (Phase 1)
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

## Database (Supabase)
Tables: `decks`, `vocabulary`, `vocabulary_examples`, `alphabet_characters`
Phase 2: `user_progress`, `study_sessions`
Tất cả đều có `site_id` FK → `sites(id)`
Migrations: `supabase/migrations/2026028000001..4_*.sql`

## Chạy local
```bash
pnpm install
cp .env.local.example .env.local  # điền env vars
pnpm dev
```

## Phase tiếp theo
- Seed data JLPT N5 (~800 từ)
- Quiz mode /quiz
- User progress tracking (cần auth)
- Spaced repetition
