# Technical Architecture — Language Learning

---

## Stack

| Layer | Tech | Lý do |
|-------|------|-------|
| Framework | Next.js 15 (App Router) | Auth, dashboard quản lý, interactive |
| Language | TypeScript (strict) | Nhất quán với hệ thống |
| Database | PostgreSQL via Supabase | Chung với web-mgmt-platform |
| Auth | Supabase Auth | Phase 2 |
| Styling | Tailwind CSS v4 + shadcn/ui | Nhất quán với hệ thống |
| Animation | framer-motion | Flashcard flip |
| TTS | Web Speech API | Free, browser native |
| Forms | react-hook-form + zod | Phase 2 (quản lý từ) |
| Deploy | Vercel | |

---

## Folder Structure

```
language-learning/
├── app/
│   ├── layout.tsx                    ← Root layout (font Noto Sans JP)
│   ├── page.tsx                      ← Home [S01]
│   ├── globals.css
│   ├── vocabulary/
│   │   ├── page.tsx                  ← Vocabulary list [S02]
│   │   └── [id]/
│   │       └── page.tsx              ← Vocabulary detail [S03]
│   ├── decks/
│   │   ├── page.tsx                  ← Deck list [S04]
│   │   └── [slug]/
│   │       └── page.tsx              ← Deck detail [S05]
│   ├── flashcard/
│   │   ├── page.tsx                  ← Flashcard all [S06]
│   │   └── [slug]/
│   │       └── page.tsx              ← Flashcard by deck [S06]
│   ├── alphabet/
│   │   ├── page.tsx                  ← Alphabet overview [S07]
│   │   ├── hiragana/
│   │   │   └── page.tsx
│   │   └── katakana/
│   │       └── page.tsx
│   └── quiz/
│       └── page.tsx                  ← Quiz [S08] (Phase 2)
│
├── components/
│   ├── ui/                           ← shadcn/ui primitives
│   ├── vocabulary/
│   │   ├── WordCard.tsx
│   │   ├── WordList.tsx
│   │   ├── WordDetail.tsx
│   │   └── VocabularyFilters.tsx
│   ├── flashcard/
│   │   ├── FlashCard.tsx             ← Card với flip animation
│   │   ├── FlashCardDeck.tsx         ← Controller (state machine)
│   │   ├── FlashCardProgress.tsx
│   │   └── StudyResult.tsx           ← Màn kết quả
│   ├── alphabet/
│   │   ├── CharacterCell.tsx
│   │   ├── CharacterGrid.tsx
│   │   └── CharacterDetail.tsx       ← Popup chi tiết
│   ├── deck/
│   │   └── DeckCard.tsx
│   ├── shared/
│   │   ├── TTSButton.tsx             ← Text-to-Speech button
│   │   ├── FuriganaText.tsx          ← Ruby annotation
│   │   ├── JLPTBadge.tsx
│   │   └── ProgressBar.tsx
│   └── layout/
│       ├── Header.tsx
│       ├── MobileNav.tsx
│       └── Footer.tsx
│
├── lib/
│   ├── supabase/
│   │   ├── client.ts                 ← Browser client
│   │   └── server.ts                 ← Server client (RSC)
│   ├── tts.ts                        ← Web Speech API wrapper
│   ├── flashcard-utils.ts            ← Shuffle, state machine logic
│   └── utils.ts                      ← cn(), formatters
│
├── types/
│   └── database.ts                   ← Generated Supabase types
│
├── supabase/
│   └── migrations/
│       ├── 20260228000001_create_decks.sql
│       ├── 20260228000002_create_vocabulary.sql
│       ├── 20260228000003_create_vocabulary_examples.sql
│       ├── 20260228000004_create_alphabet_characters.sql
│       └── 20260228000005_create_user_progress.sql
│
└── public/
    └── fonts/                        ← Noto Sans JP (hoặc dùng Google Fonts)
```

---

## Data Fetching Strategy

### Server Components (RSC) — Default
```ts
// app/vocabulary/page.tsx
import { createServerClient } from '@/lib/supabase/server'

export default async function VocabularyPage({ searchParams }) {
  const supabase = await createServerClient()
  const { data: words } = await supabase
    .from('vocabulary')
    .select('*, deck:decks(name, slug)')
    .eq('site_id', process.env.SITE_ID)
    .eq('is_active', true)
    .order('order_index')
    .range(0, 19)

  return <WordList words={words} />
}
```

### Client Components — Chỉ dùng cho:
1. **FlashCard** — cần local state (current card, flip state, progress)
2. **TTSButton** — cần browser API
3. **Filter/Search** — real-time filtering
4. **Quiz** — interactive state machine

---

## FlashCard State Machine

```ts
// Trạng thái của một phiên học
type StudyState = {
  cards: Vocabulary[]           // Danh sách đã shuffle
  currentIndex: number          // Card hiện tại
  isFlipped: boolean            // Đang xem mặt trước hay sau
  results: {
    correct: Vocabulary[]
    review: Vocabulary[]
    wrong: Vocabulary[]
  }
  phase: 'studying' | 'complete'
}

// Actions
type StudyAction =
  | { type: 'FLIP' }
  | { type: 'MARK'; result: 'correct' | 'review' | 'wrong' }
  | { type: 'NEXT' }
  | { type: 'RESTART' }
```

---

## Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=        # Server-side only
NEXT_PUBLIC_SITE_ID=              # UUID của site trong bảng sites
```

---

## Supabase RLS Policies

```sql
-- decks: public read
CREATE POLICY "Public read decks"
ON decks FOR SELECT USING (is_public = true);

-- vocabulary: public read
CREATE POLICY "Public read vocabulary"
ON vocabulary FOR SELECT USING (is_active = true);

-- alphabet_characters: public read
CREATE POLICY "Public read alphabet"
ON alphabet_characters FOR SELECT USING (true);

-- user_progress: user only
CREATE POLICY "User read own progress"
ON user_progress FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "User write own progress"
ON user_progress FOR ALL USING (auth.uid() = user_id);
```

---

## Performance Considerations

| Concern | Giải pháp |
|---------|-----------|
| Font tiếng Nhật nặng | next/font với subset JP, chỉ load ký tự cần thiết |
| Vocabulary list lớn | Pagination server-side (20/page), không load all |
| Flashcard shuffle | Client-side shuffle sau khi fetch, không cần API |
| TTS latency | Web Speech API sync — không cần fetch |
| Images | next/image với lazy loading, WebP |

---

## Implementation Phases

### Phase 1 — MVP (Public, no auth)
- [x] Setup Next.js 15 + Tailwind + shadcn
- [ ] Database migrations (decks, vocabulary, alphabet)
- [ ] Seed data (JLPT N5, Hiragana, Katakana)
- [ ] [S01] Home page
- [ ] [S02] Vocabulary list với filter
- [ ] [S03] Vocabulary detail
- [ ] [S04] Deck list
- [ ] [S05] Deck detail
- [ ] [S06] Flashcard study
- [ ] [S07] Alphabet chart
- [ ] TTS integration
- [ ] Mobile responsive + dark mode
- [ ] Deploy to Vercel

### Phase 2 — Auth & Progress
- [ ] Supabase Auth integration
- [ ] [S08] Quiz mode
- [ ] [S09] User progress tracking
- [ ] Spaced repetition algorithm
- [ ] [S10] Profile page với stats

### Phase 3 — Premium
- [ ] Custom deck creation
- [ ] Import/export vocab (CSV)
- [ ] Multi-language support (Korean, Chinese)
- [ ] Premium subscription (Stripe)
- [ ] Offline mode (PWA)

---

## Naming Conventions

- Pages → `page.tsx` (lowercase)
- Components → `PascalCase.tsx`
- Utilities → `camelCase.ts`
- Folders → `kebab-case`
- DB types → Generated từ Supabase CLI (`supabase gen types`)
- CSS classes → Tailwind utilities, không viết custom CSS trừ khi cần thiết
