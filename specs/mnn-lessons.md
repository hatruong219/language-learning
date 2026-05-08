# Minna no Nihongo — Tính năng Bài học

## 1. Tổng quan

Tính năng học theo giáo trình **みんなの日本語 初級I/II** (Minna no Nihongo).  
Mỗi bài gồm 3 phần: **Nội dung** (từ vựng + ngữ pháp) → **Thực hành** (bài tập) → **Kết quả**.

Nav item: `みんなの` → `/lessons`

---

## 2. Routes

| Route | Mô tả |
|-------|-------|
| `/lessons` | Danh sách tất cả bài học |
| `/lessons/[lesson_number]` | Chi tiết bài (param = số bài, vd: `/lessons/5`) |

---

## 3. Database

> Migration: `supabase/migrations/20260508000001_mnn_tables.sql`

### `mnn_lessons`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK → sites | |
| lesson_number | smallint | Số bài (1, 2, 3...) |
| title_vi | text | Tiêu đề bài: はじめまして |
| situation_vi | text | Tình huống: "Tự giới thiệu bản thân" |
| order_index | smallint | Thứ tự hiển thị |
| created_at | timestamptz | |

### `mnn_vocabulary`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK | |
| lesson_id | uuid FK → mnn_lessons | |
| word | text | Từ tiếng Nhật: 行きます |
| reading | text | Cách đọc: いきます |
| romanization | text | Romaji: ikimasu |
| meaning_vi | text | Nghĩa: Đi (đến nơi nào đó) |
| part_of_speech | text | 動詞, 名詞, 助詞... |
| order_index | smallint | |

### `mnn_grammar`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK | |
| lesson_id | uuid FK → mnn_lessons | |
| pattern | text | Mẫu câu: 〜へ行きます/来ます/帰ります |
| explanation_vi | text | Giải thích bằng tiếng Việt |
| example_ja | text | Câu ví dụ tiếng Nhật |
| example_vi | text | Dịch câu ví dụ |
| order_index | smallint | |

### `mnn_exercises`
| Column | Type | Mô tả |
|--------|------|-------|
| id | uuid PK | |
| site_id | uuid FK | |
| lesson_id | uuid FK → mnn_lessons | |
| type | text | `fill_blank` hoặc `multiple_choice` |
| question | text | Câu hỏi (fill_blank dùng `___` làm chỗ trống) |
| options | jsonb | Chỉ dùng cho multiple_choice: `["A","B","C","D"]` |
| answer | text | Đáp án đúng |
| explanation_vi | text | Giải thích tại sao đúng |
| order_index | smallint | |

**RLS:** Public SELECT. Service role write.

---

## 4. Components

```
src/app/lessons/
├── page.tsx                        — Server: fetch all lessons
└── [lesson]/
    └── page.tsx                    — Server: fetch lesson + vocab + grammar + exercises

src/components/lessons/
├── LessonList.tsx                  — Grid card danh sách bài
├── LessonDetail.tsx                — Client: 3 tabs (Nội dung / Thực hành / Kết quả)
├── VocabSection.tsx                — Bảng từ vựng + nút TTS
├── GrammarSection.tsx              — Card từng điểm ngữ pháp
└── ExerciseSession.tsx             — Client: chạy bài tập, callback onComplete
```

### Tab flow
```
[Nội dung]     → xem từ vựng + ngữ pháp
[Thực hành]    → làm bài tập lần lượt → auto-switch sang Kết quả khi xong
[Kết quả]      → score % + danh sách câu sai + nút Luyện lại
```

### Exercise types
| Type | Mô tả | Chấm |
|------|-------|------|
| `fill_blank` | Điền từ vào chỗ `___` | Exact match (trim + lowercase) |
| `multiple_choice` | Chọn 1 trong 4 đáp án | So sánh với `answer` |

---

## 5. Seed data

> File: `supabase/seed_mnn_lessons_1_5.sql`  
> Dùng PL/pgSQL DO block để lấy UUID lesson qua subquery.

### Bài đã có (Book I)

| Bài | Tiêu đề | Ngữ pháp chính | Từ vựng | Trạng thái |
|-----|---------|----------------|---------|------------|
| 1 | はじめまして | 〜は〜です / じゃありません / ですか / も | 17 từ | ✅ seeded |
| 2 | これはなんですか | これ/それ/あれ / なんですか / 〜の / だれの | 18 từ | ✅ seeded |
| 3 | あそこです | ここ/そこ/あそこ / どこですか / があります/います | 22 từ | ✅ seeded |
| 4 | なんじですか | 〜じ〜ふん / なんじですか / から〜まで | 18 từ | ✅ seeded |
| 5 | 行きます・来ます・帰ります | 〜へ / 〜で (phương tiện) / 〜と (cùng với) / いつ | 24 từ | ✅ seeded |

**Bài tiếp theo cần seed:** Bài 6 trở đi.

---

## 6. Nguồn dữ liệu uy tín

> ⚠️ **KHÔNG generate từ training memory** — dễ nhầm thứ tự bài, nhầm từ giữa các bài.  
> **BẮT BUỘC fetch từ nguồn trước khi viết SQL.**

| Nguồn | URL pattern | Dùng để lấy |
|-------|-------------|------------|
| langoal.com | `https://langoal.com/vocbs/lesson-{N}.html` | Từ vựng (kanji + furigana + romaji + nghĩa) |
| umenjapan.wordpress.com | `https://umenjapan.wordpress.com/minna-no-nihongo-lesson-{N}-vocabulary-and-grammar/` | Grammar points + ví dụ |
| hire39.com | `https://hire39.com/minna-no-nihongo-basic-1` | 文型リスト bài 1–25 |
| nihon5-bunka.net | `https://nihon5-bunka.net/minnano-nihongo-lessonplans/` | Giáo án đầy đủ |
| denisowski.org | `http://denisowski.org/Japanese/MNN_1/MNN_1.html` | Full vocab list MNN I |

### Workflow generate bài mới
1. `WebFetch` → `langoal.com/vocbs/lesson-{N}.html` → lấy từ vựng
2. `WebFetch` → `umenjapan.wordpress.com/.../lesson-{N}-...` → lấy grammar
3. Cross-check với `hire39.com` nếu cần thêm 文型
4. Viết SQL vào `supabase/seed_mnn_lessons_{range}.sql`

---

## 7. Types (src/types/database.ts)

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

## 8. Supabase query pattern

```ts
// /app/lessons/[lesson]/page.tsx
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

## 9. Roadmap

- [x] Bài 1–5 Book I
- [ ] Bài 6–25 Book I (N5 level)
- [ ] Bài 26–50 Book I
- [ ] Book II (Bài 1–50, N4 level)
- [ ] Audio TTS tự động đọc từ khi hover
- [ ] Lưu tiến trình bài đã học (cần auth)
