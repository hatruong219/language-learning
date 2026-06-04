# 日本語を学ぼう — Japanese Learning Platform

A full-stack Japanese language learning web app with vocabulary management, interactive flashcards, alphabet reference, AI-powered writing assessment, and text-to-speech — built with Next.js 16, Supabase, and Groq LLM.

![Next.js](https://img.shields.io/badge/Next.js-16-black?logo=next.js)
![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-v4-38BDF8?logo=tailwindcss)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)
![Groq](https://img.shields.io/badge/AI-Groq%20LLM-FF6B35)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-study.truongha.com-blue?logo=vercel)](https://study.truongha.com/)

---

## Features

| Feature | Description |
|---------|-------------|
| **Vocabulary Browser** | Browse, filter by deck / JLPT level / keyword, paginated list with furigana readings |
| **Word Detail** | Furigana, native TTS pronunciation, example sentences |
| **Flashcards** | Study by deck or random pool — flip animation, auto-play audio, keyboard shortcuts, JLPT filter, card count selector |
| **Deck Management** | Organized vocabulary decks with emoji, descriptions, and word counts |
| **Alphabet Reference** | Full Hiragana & Katakana chart — click any character to hear pronunciation |
| **AI Writing Test** | Receive a random Japanese writing prompt, submit your answer, get AI-graded feedback on grammar, vocabulary, and content |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 16 (App Router, React Server Components) |
| Language | TypeScript (strict mode) |
| Styling | Tailwind CSS v4 + shadcn/ui + framer-motion |
| Database | Supabase (PostgreSQL) |
| AI Grading | Groq API — `llama-3.3-70b-versatile` (fallback: `llama-3.1-8b-instant`) |
| TTS | Web Speech API (browser-native, zero cost) |
| Forms | react-hook-form + Zod validation |
| Deployment | Vercel |

---

## Routes

| Route | Description |
|-------|-------------|
| `/` | Home — hero section, site stats, featured decks, random word highlight |
| `/vocabulary` | Vocabulary list with deck / JLPT / search filters + pagination |
| `/vocabulary/[id]` | Word detail: furigana, TTS button, example sentences |
| `/decks` | All decks grid |
| `/decks/[slug]` | Words in deck + start flashcard button |
| `/flashcard` | Random flashcard session (all vocabulary) |
| `/flashcard/[slug]` | Flashcard session for a specific deck |
| `/alphabet` | Hiragana & Katakana reference with click-to-listen |
| `/writing-test` | AI writing assessment — prompt → submission → graded feedback |

---

## Project Structure

```
src/
├── app/                      ← App Router pages & API routes
├── components/               ← UI components (PascalCase.tsx)
├── lib/
│   ├── supabase/             ← client.ts (browser) · server.ts (RSC)
│   ├── tts.ts                ← Web Speech API wrapper
│   └── flashcard-utils.ts    ← Shuffle logic + state reducer
├── types/database.ts         ← Supabase table types
supabase/
└── migrations/               ← Ordered SQL migrations
```

**Database tables:** `sites`, `decks`, `vocabulary`, `vocabulary_examples`, `alphabet_characters`, `writing_prompts`, `writing_submissions`, `user_progress`, `study_sessions`

---

## Getting Started

**Prerequisites:** Node.js LTS, `pnpm`

```bash
pnpm install
cp .env.example .env.local
# Fill in the env vars below, then:
pnpm dev
```

App runs at `http://localhost:3000`.

### Environment Variables

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SITE_ID=        # UUID of your site row in the `sites` table

# Groq — AI writing grader
# Get your key at: https://console.groq.com/keys
GROQ_API_KEY=
```

---

## Roadmap

- [ ] Full JLPT N5–N4 vocabulary seed (~800–1500 words)
- [ ] Quiz mode `/quiz`
- [ ] User authentication + progress tracking
- [ ] Spaced repetition algorithm
- [ ] Multi-language support (Korean, Chinese)
