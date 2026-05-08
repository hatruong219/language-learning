# みんなの日本語 — Feature Spec

## Tổng quan

Tính năng học theo giáo trình **みんなの日本語 初級I/II**.  
Mỗi bài gồm 3 phần: **Nội dung** (từ vựng + ngữ pháp) → **Thực hành** (bài tập) → **Kết quả**.

Nav item: `みんなの` → `/lessons`

---

## Routes

| Route | Mô tả |
|-------|-------|
| `/lessons` | Danh sách tất cả bài học |
| `/lessons/[lesson_number]` | Chi tiết bài (param = số bài, vd: `/lessons/5`) |

---

## Database

> Migration: `supabase/migrations/20260508000001_mnn_tables.sql`

### `mnn_lessons`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK → sites | |
| lesson_number | smallint | Số bài (1, 2, 3...) |
| title_vi | text | Tiêu đề bài: はじめまして |
| situation_vi | text | Tình huống: "Tự giới thiệu bản thân" |
| order_index | smallint | |
| created_at | timestamptz | |

**UNIQUE:** `(site_id, lesson_number)`

### `mnn_vocabulary`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK | |
| lesson_id | uuid FK → mnn_lessons CASCADE | |
| word | text | 行きます |
| reading | text | いきます |
| romanization | text | ikimasu |
| meaning_vi | text | Đi (đến nơi nào đó) |
| part_of_speech | text | 動詞, 名詞, 助詞... |
| order_index | smallint | |

### `mnn_grammar`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK | |
| lesson_id | uuid FK → mnn_lessons CASCADE | |
| pattern | text | 〜へ行きます/来ます/帰ります |
| explanation_vi | text | Giải thích bằng tiếng Việt |
| example_ja | text | Câu ví dụ tiếng Nhật |
| example_vi | text | Dịch câu ví dụ |
| order_index | smallint | |

### `mnn_exercises`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK | |
| lesson_id | uuid FK → mnn_lessons CASCADE | |
| type | text | `fill_blank` hoặc `multiple_choice` |
| question | text | Dùng `___` cho chỗ trống |
| options | jsonb | MC: `["A","B","C","D"]` |
| answer | text | Đáp án đúng |
| explanation_vi | text | Giải thích tại sao đúng |
| order_index | smallint | |

**RLS tất cả bảng:** Public SELECT. Service role write.

---

## Components

```
src/app/lessons/
├── page.tsx                   — Server: fetch all lessons
└── [lesson]/page.tsx          — Server: fetch lesson + vocab + grammar + exercises

src/components/lessons/
├── LessonList.tsx             — Grid card danh sách bài
├── LessonDetail.tsx           — Client: 3 tabs
├── VocabSection.tsx           — Bảng từ vựng + nút TTS
├── GrammarSection.tsx         — Card điểm ngữ pháp
└── ExerciseSession.tsx        — Client: chạy bài tập, callback onComplete
```

### Tab flow
```
Nội dung  →  xem từ vựng + ngữ pháp
Thực hành →  bài tập lần lượt  →  auto-switch sang Kết quả khi xong
Kết quả   →  score % + câu sai + nút Luyện lại
```

### Exercise types
| Type | Mô tả | Chấm |
|------|-------|------|
| `fill_blank` | Điền từ vào `___` | Exact match (trim + lowercase) |
| `multiple_choice` | Chọn 1 trong 4 | So sánh với `answer` |

---

## Types (src/types/database.ts)

```ts
export type MnnLesson     = Database['public']['Tables']['mnn_lessons']['Row']
export type MnnVocabulary = Database['public']['Tables']['mnn_vocabulary']['Row']
export type MnnGrammar    = Database['public']['Tables']['mnn_grammar']['Row']
export type MnnExercise   = Database['public']['Tables']['mnn_exercises']['Row']

export type MnnLessonFull = MnnLesson & {
  mnn_vocabulary: MnnVocabulary[]
  mnn_grammar: MnnGrammar[]
  mnn_exercises: MnnExercise[]
}
```

---

## Supabase query pattern

```ts
const { data } = await supabase
  .from('mnn_lessons')
  .select(`*, mnn_vocabulary(*), mnn_grammar(*), mnn_exercises(*)`)
  .eq('site_id', siteId)
  .eq('lesson_number', lessonNumber)
  .order('order_index', { referencedTable: 'mnn_vocabulary' })
  .order('order_index', { referencedTable: 'mnn_grammar' })
  .order('order_index', { referencedTable: 'mnn_exercises' })
  .single()
```

---

## Roadmap

- [x] Bài 1–5 Book I (seed: `supabase/seed_mnn_lessons_1_5.sql`)
- [ ] Bài 6–25 Book I (N5 level)
- [ ] Bài 26–50 Book I
- [ ] Book II Bài 1–50 (N4 level)
- [ ] Lưu tiến trình bài đã học (cần auth)
