# Database Schema — Language Learning

> Tất cả bảng đều có `site_id UUID REFERENCES sites(id)` để liên kết với web-mgmt-platform.
> Migration files lưu tại `supabase/migrations/` theo format `YYYYMMDDHHMMSS_description.sql`.

---

## ERD (Entity Relationship)

```
sites (web-mgmt-platform)
  └── decks (nhóm từ vựng / topic)
        └── vocabulary (từ vựng)
              └── vocabulary_examples (câu ví dụ)
              └── vocabulary_readings (cách đọc / furigana)

users (Supabase Auth)
  └── user_progress (tiến trình học từng từ)
  └── study_sessions (phiên học)
  └── custom_decks (deck riêng - Phase 2)
```

---

## Bảng chi tiết

### `decks` — Nhóm từ / Topic

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|-------|
| `id` | UUID | PK, default gen_random_uuid() | |
| `site_id` | UUID | FK → sites(id), NOT NULL | |
| `language_code` | VARCHAR(10) | NOT NULL, default 'ja' | 'ja', 'en', 'ko', ... |
| `name` | VARCHAR(255) | NOT NULL | Tên deck: "JLPT N5", "Màu sắc", ... |
| `description` | TEXT | | Mô tả deck |
| `slug` | VARCHAR(255) | UNIQUE(site_id, slug) | |
| `emoji` | VARCHAR(10) | | Icon deck: 🌸 |
| `cover_image_url` | TEXT | | Ảnh bìa |
| `is_public` | BOOLEAN | default true | |
| `order_index` | INT | default 0 | Thứ tự hiển thị |
| `metadata` | JSONB | default '{}' | Extra fields |
| `created_at` | TIMESTAMPTZ | default now() | |
| `updated_at` | TIMESTAMPTZ | default now() | trigger |

**RLS:** Public read. Admin write (SERVICE_ROLE hoặc admin user).

---

### `vocabulary` — Từ vựng

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|-------|
| `id` | UUID | PK | |
| `site_id` | UUID | FK → sites(id), NOT NULL | |
| `deck_id` | UUID | FK → decks(id), NOT NULL | |
| `language_code` | VARCHAR(10) | NOT NULL, default 'ja' | |
| `word` | VARCHAR(255) | NOT NULL | Từ gốc: 食べる, こんにちは |
| `reading` | VARCHAR(255) | | Furigana / phiên âm: たべる |
| `romanization` | VARCHAR(255) | | Romaji: taberu |
| `meaning_vi` | TEXT | NOT NULL | Nghĩa tiếng Việt |
| `meaning_en` | TEXT | | Nghĩa tiếng Anh |
| `part_of_speech` | VARCHAR(50) | | 動詞, 名詞, 形容詞, ... |
| `jlpt_level` | VARCHAR(5) | | N1, N2, N3, N4, N5 |
| `audio_url` | TEXT | | URL file audio (nếu dùng pre-recorded) |
| `image_url` | TEXT | | Ảnh minh hoạ |
| `tags` | TEXT[] | default '{}' | Tags: ['food', 'basic'] |
| `order_index` | INT | default 0 | |
| `is_active` | BOOLEAN | default true | |
| `metadata` | JSONB | default '{}' | |
| `created_at` | TIMESTAMPTZ | default now() | |
| `updated_at` | TIMESTAMPTZ | default now() | |

**RLS:** Public read. Admin write.

**Index:** `(deck_id)`, `(language_code)`, `(jlpt_level)`, full-text search trên `word + meaning_vi`

---

### `vocabulary_examples` — Câu ví dụ

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|-------|
| `id` | UUID | PK | |
| `vocabulary_id` | UUID | FK → vocabulary(id) ON DELETE CASCADE | |
| `sentence` | TEXT | NOT NULL | Câu ví dụ (tiếng Nhật) |
| `sentence_reading` | TEXT | | Furigana của câu |
| `translation_vi` | TEXT | | Dịch tiếng Việt |
| `translation_en` | TEXT | | Dịch tiếng Anh |
| `created_at` | TIMESTAMPTZ | default now() | |

---

### `alphabet_characters` — Bảng chữ cái

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|-------|
| `id` | UUID | PK | |
| `site_id` | UUID | FK → sites(id) | |
| `language_code` | VARCHAR(10) | NOT NULL, default 'ja' | |
| `script` | VARCHAR(20) | NOT NULL | 'hiragana', 'katakana', 'kanji' |
| `character` | VARCHAR(10) | NOT NULL | あ, ア, 山 |
| `romanization` | VARCHAR(20) | NOT NULL | a, ka, yama |
| `group_name` | VARCHAR(50) | | 'vowels', 'ka-row', 'ta-row' |
| `stroke_order_url` | TEXT | | Ảnh / GIF thứ tự nét |
| `order_index` | INT | | |
| `created_at` | TIMESTAMPTZ | default now() | |

**RLS:** Public read.

---

### `user_progress` — Tiến trình học (Phase 2 — cần auth)

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|-------|
| `id` | UUID | PK | |
| `user_id` | UUID | FK → auth.users(id) ON DELETE CASCADE | |
| `vocabulary_id` | UUID | FK → vocabulary(id) ON DELETE CASCADE | |
| `status` | VARCHAR(20) | default 'new' | 'new', 'learning', 'review', 'mastered' |
| `correct_count` | INT | default 0 | Số lần đúng |
| `wrong_count` | INT | default 0 | Số lần sai |
| `next_review_at` | TIMESTAMPTZ | | Lịch ôn tập (spaced repetition - Phase 3) |
| `last_studied_at` | TIMESTAMPTZ | | |
| `created_at` | TIMESTAMPTZ | default now() | |
| `updated_at` | TIMESTAMPTZ | default now() | |

**Unique:** `(user_id, vocabulary_id)`
**RLS:** User chỉ đọc/ghi progress của mình.

---

### `study_sessions` — Phiên học (Phase 2)

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|-------|
| `id` | UUID | PK | |
| `user_id` | UUID | FK → auth.users(id) | |
| `deck_id` | UUID | FK → decks(id) | |
| `mode` | VARCHAR(20) | NOT NULL | 'flashcard', 'quiz', 'browse' |
| `cards_studied` | INT | default 0 | |
| `cards_correct` | INT | default 0 | |
| `duration_seconds` | INT | | Thời gian học |
| `completed_at` | TIMESTAMPTZ | | |
| `created_at` | TIMESTAMPTZ | default now() | |

---

## Migration thứ tự

```sql
-- 1. decks
-- 2. vocabulary
-- 3. vocabulary_examples
-- 4. alphabet_characters
-- 5. user_progress (sau khi có auth)
-- 6. study_sessions (sau khi có user_progress)
```

---

## Seed data gợi ý (Phase 1)

- Deck "Hiragana cơ bản" — 46 ký tự
- Deck "Katakana cơ bản" — 46 ký tự
- Deck "JLPT N5 — Từ thông dụng" — ~100 từ đầu
- Deck "Chào hỏi & giao tiếp" — ~20 từ
- Deck "Số đếm & thời gian" — ~30 từ
