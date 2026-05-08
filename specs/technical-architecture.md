# Technical Architecture — Language Learning

---

## Stack

| Layer | Tech | Ghi chú |
|-------|------|---------|
| Framework | Next.js 16 (App Router) | Server Components mặc định |
| Language | TypeScript strict | Không dùng `any` |
| Database | PostgreSQL via Supabase | Shared với web-mgmt-platform |
| Auth | Supabase Auth | Phase 2 |
| Styling | Tailwind CSS v4 + shadcn/ui | |
| Animation | framer-motion | Flashcard flip |
| TTS | Web Speech API | Browser native, free |
| AI Grading | Groq API | llama-3.3-70b-versatile / llama-3.1-8b-instant |
| Deploy | Vercel | |

---

## Folder Structure

```
language-learning/
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx                          ← Home [S01]
│   │   ├── globals.css
│   │   ├── vocabulary/
│   │   │   ├── page.tsx                      ← Vocabulary list [S02]
│   │   │   └── [id]/page.tsx                 ← Vocabulary detail [S03]
│   │   ├── decks/
│   │   │   ├── page.tsx                      ← Deck list [S04]
│   │   │   └── [slug]/page.tsx               ← Deck detail [S05]
│   │   ├── flashcard/
│   │   │   ├── page.tsx                      ← Flashcard all [S06]
│   │   │   └── [slug]/page.tsx               ← Flashcard by deck [S06]
│   │   ├── alphabet/
│   │   │   └── page.tsx                      ← Alphabet chart [S07]
│   │   ├── writing-test/
│   │   │   └── page.tsx                      ← Writing test [S08]
│   │   └── api/
│   │       ├── writing-submissions/
│   │       │   ├── route.ts                  ← POST submit + grade
│   │       │   └── grade/route.ts            ← POST re-grade
│   │       └── writing-prompts/
│   │           └── random/route.ts           ← GET random prompt
│   │
│   ├── components/
│   │   ├── ui/                               ← shadcn/ui primitives
│   │   ├── vocabulary/
│   │   ├── flashcard/
│   │   ├── alphabet/
│   │   ├── writing/
│   │   │   └── WritingTestClient.tsx         ← Writing test UI
│   │   ├── deck/
│   │   └── layout/
│   │       ├── Header.tsx
│   │       ├── MobileNav.tsx
│   │       └── Footer.tsx
│   │
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts                     ← Browser client
│   │   │   ├── server.ts                     ← RSC client
│   │   │   └── service.ts                    ← Service role client
│   │   ├── groq.ts                           ← Groq API, grading logic
│   │   ├── tts.ts                            ← Web Speech API wrapper
│   │   ├── flashcard-utils.ts                ← Shuffle, state machine
│   │   └── utils.ts                          ← cn(), formatters
│   │
│   └── types/
│       └── database.ts                       ← Supabase table types (manual)
│
├── supabase/
│   └── migrations/
│       ├── 20260228000001_create_decks.sql
│       ├── 20260228000002_create_vocabulary.sql
│       ├── 20260228000003_create_vocabulary_examples.sql
│       ├── 20260228000004_create_alphabet_characters.sql
│       └── 20260228000005_create_writing_tables.sql
│
└── public/
```

---

## Data Fetching Strategy

### Server Components (RSC) — Default
```ts
import { createServerClient } from '@/lib/supabase/server'

export default async function VocabularyPage({ searchParams }) {
  const supabase = await createServerClient()
  const { data: words } = await supabase
    .from('vocabulary')
    .select('*, deck:decks(name, slug)')
    .eq('site_id', process.env.NEXT_PUBLIC_SITE_ID)
    .eq('is_active', true)
    .order('order_index')
    .range(0, 19)

  return <WordList words={words} />
}
```

### Client Components — Chỉ dùng khi cần:
1. **FlashCard** — local state (current card, flip state, progress)
2. **TTSButton** — browser API
3. **Filter/Search** — real-time filtering
4. **WritingTestClient** — interactive form + AI grading result

---

## AI Grading Flow

```
Client → POST /api/writing-submissions
  → Save submission to DB (nếu có prompt_id hợp lệ)
  → gradeWritingWithGroq(prompt_vi, response, min_words)
      → Groq llama-3.3-70b-versatile
      → [429] fallback → llama-3.1-8b-instant
  → Update submission với score/feedback
  → Return GradingResult
```

---

## FlashCard State Machine

```ts
type StudyState = {
  cards: Vocabulary[]
  currentIndex: number
  isFlipped: boolean
  results: { correct: Vocabulary[]; review: Vocabulary[]; wrong: Vocabulary[] }
  phase: 'studying' | 'complete'
}

type StudyAction =
  | { type: 'FLIP' }
  | { type: 'MARK'; result: 'correct' | 'review' | 'wrong' }
  | { type: 'NEXT' }
  | { type: 'RESTART' }
```

---

## Environment Variables

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SITE_ID=    # UUID của site trong bảng sites

GROQ_API_KEY=           # https://console.groq.com/keys
                        # Primary: llama-3.3-70b-versatile
                        # Fallback: llama-3.1-8b-instant
```

---

## Supabase RLS Policies

```sql
-- Public read
CREATE POLICY "Public read decks" ON decks FOR SELECT USING (is_public = true);
CREATE POLICY "Public read vocabulary" ON vocabulary FOR SELECT USING (is_active = true);
CREATE POLICY "Public read alphabet" ON alphabet_characters FOR SELECT USING (true);
CREATE POLICY "Public read writing_prompts" ON writing_prompts FOR SELECT USING (is_active = true);

-- User progress (Phase 2 — cần auth)
CREATE POLICY "User read own progress" ON user_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "User write own progress" ON user_progress FOR ALL USING (auth.uid() = user_id);
```

---

## Performance Considerations

| Concern | Giải pháp |
|---------|-----------|
| Font tiếng Nhật nặng | next/font với subset JP |
| Vocabulary list lớn | Pagination server-side (20/page) |
| Flashcard shuffle | Client-side sau khi fetch |
| TTS latency | Web Speech API sync |
| AI grading latency | ~2–4s, hiển thị loading state |

---

## Implementation Phases

### Phase 1 — MVP (Done)
- [x] Setup Next.js + Tailwind + shadcn
- [x] Database migrations
- [x] Home, Vocabulary list/detail, Deck list/detail
- [x] Flashcard (random + by deck, JLPT filter, phím tắt)
- [x] Alphabet Hiragana/Katakana
- [x] Writing test với AI grading (Groq)
- [x] Deploy to Vercel

### Phase 2 — Auth & Progress
- [ ] Supabase Auth integration
- [ ] Quiz mode `/quiz`
- [ ] User progress tracking
- [ ] Spaced repetition
- [ ] Profile page với stats

### Phase 3 — Premium
- [ ] Custom deck creation
- [ ] Import/export vocab (CSV)
- [ ] Multi-language support
- [ ] Premium subscription (Stripe)
- [ ] Offline mode (PWA)

---

## Naming Conventions

- Pages → `page.tsx`
- Components → `PascalCase.tsx`
- Utilities → `camelCase.ts`
- Folders → `kebab-case`
- DB types → `src/types/database.ts` (manual)
