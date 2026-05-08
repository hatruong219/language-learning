# AI Writing Test Feature

## Overview

Tính năng luyện viết: người dùng nhận đề ngẫu nhiên, viết bài bằng tiếng Nhật, hệ thống gửi lên Groq để chấm điểm tự động.

**AI provider:** Groq API
- Primary model: `llama-3.3-70b-versatile`
- Fallback khi rate limit (HTTP 429): `llama-3.1-8b-instant`

---

## User Flow

1. Vào `/writing-test` → hệ thống fetch đề ngẫu nhiên từ `writing_prompts`
2. Người dùng viết bài tiếng Nhật vào textarea
3. Submit → `POST /api/writing-submissions` → lưu bài vào DB → gửi lên Groq chấm
4. Groq trả về JSON: điểm grammar / vocab / content, nhận xét, danh sách lỗi
5. Kết quả hiển thị ngay trên trang

---

## Database

### `writing_prompts`

| Column | Type | Mô tả |
|--------|------|-------|
| `id` | UUID PK | |
| `site_id` | UUID FK → sites | |
| `prompt_vi` | TEXT NOT NULL | Đề bài bằng tiếng Việt |
| `min_words` | INT default 30 | Số từ tối thiểu yêu cầu |
| `is_active` | BOOLEAN default true | |
| `created_at` | TIMESTAMPTZ | |

### `writing_submissions`

| Column | Type | Mô tả |
|--------|------|-------|
| `id` | UUID PK | |
| `site_id` | UUID FK → sites | |
| `prompt_id` | UUID FK → writing_prompts | |
| `session_id` | UUID nullable | Client-generated session |
| `response` | TEXT NOT NULL | Bài viết của người dùng |
| `score` | INT | Tổng điểm (0–100) |
| `score_grammar` | INT | Ngữ pháp (0–40) |
| `score_vocab` | INT | Từ vựng (0–30) |
| `score_content` | INT | Nội dung (0–30) |
| `feedback_vi` | TEXT | Nhận xét tổng quan tiếng Việt |
| `errors` | JSONB | Danh sách lỗi [{original, corrected, explanation_vi}] |
| `is_valid_lang` | BOOLEAN | Bài có viết đúng tiếng Nhật không |
| `graded_at` | TIMESTAMPTZ | |
| `created_at` | TIMESTAMPTZ | |

---

## API Endpoints

### `POST /api/writing-submissions`

Submit bài và chấm điểm ngay.

**Request body:**
```json
{
  "prompt_id": "uuid | 'fallback'",
  "prompt_vi": "Giới thiệu bản thân bằng tiếng Nhật.",
  "min_words": 50,
  "session_id": "uuid",
  "response": "わたしはグエンです..."
}
```

- Nếu `prompt_id` là UUID hợp lệ: fetch `prompt_vi`/`min_words` từ DB và lưu submission
- Nếu `prompt_id = 'fallback'` hoặc thiếu: dùng `prompt_vi`/`min_words` từ client, không lưu DB

**Response:**
```json
{
  "submission_id": "uuid | null",
  "is_valid_lang": true,
  "score": 77,
  "score_grammar": 30,
  "score_vocab": 22,
  "score_content": 25,
  "feedback_vi": "Bài viết khá tốt...",
  "errors": [
    {
      "original": "わたしはがくせいです",
      "corrected": "わたしはがくせいです。",
      "explanation_vi": "Cuối câu cần có dấu chấm 。"
    }
  ]
}
```

### `POST /api/writing-submissions/grade`

Re-grade một submission đã lưu.

**Request body:** `{ "submission_id": "uuid" }`

**Response:** giống trên (không có `submission_id`).

---

## Grading Logic (Groq)

Prompt gửi lên Groq yêu cầu trả về JSON thuần (không markdown):

| Tiêu chí | Điểm | Mô tả |
|----------|------|-------|
| `is_valid_lang` | — | false nếu không phải tiếng Nhật → tất cả điểm = 0 |
| `score_grammar` | 0–40 | Ngữ pháp, cấu trúc câu |
| `score_vocab` | 0–30 | Từ vựng phong phú, phù hợp |
| `score_content` | 0–30 | Nội dung liên quan đề bài |
| `score` | 0–100 | Tổng 3 tiêu chí |
| `errors` | — | Tối đa 5 lỗi quan trọng nhất |
| `feedback_vi` | — | Nhận xét 2–4 câu tiếng Việt |

**Rate limit handling:** HTTP 429 trên `llama-3.3-70b-versatile` → tự động retry ngay bằng `llama-3.1-8b-instant`.

---

## File liên quan

- `src/lib/groq.ts` — Groq API client, grading logic
- `src/app/api/writing-submissions/route.ts` — submit + grade
- `src/app/api/writing-submissions/grade/route.ts` — re-grade
- `src/app/writing-test/page.tsx` — UI trang luyện viết
- `src/components/writing/WritingTestClient.tsx` — Client component
