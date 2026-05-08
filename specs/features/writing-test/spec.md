# AI Writing Test — Feature Spec

## Tổng quan

Tính năng luyện viết: người dùng nhận đề ngẫu nhiên, viết bài bằng tiếng Nhật, hệ thống gửi lên Groq để chấm điểm tự động.

**AI provider:** Groq API
- Primary model: `llama-3.3-70b-versatile`
- Fallback khi rate limit (HTTP 429): `llama-3.1-8b-instant`
- Models đọc từ env: `GROQ_MODEL`, `GROQ_MODEL_FALLBACK`

---

## User Flow

1. Vào `/writing-test` → fetch đề ngẫu nhiên từ `writing_prompts`
2. Người dùng viết bài tiếng Nhật vào textarea
3. Submit → `POST /api/writing-submissions` → lưu DB → gửi Groq chấm
4. Groq trả JSON: điểm grammar/vocab/content, nhận xét, danh sách lỗi
5. Kết quả hiển thị ngay. Nút reload đề mới (filter theo JLPT level)

---

## Database

### `writing_prompts`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | UUID PK | |
| `site_id` | UUID FK → sites | |
| `title` | TEXT | Tiêu đề đề bài |
| `prompt_vi` | TEXT NOT NULL | Đề bài tiếng Việt |
| `prompt_ja` | TEXT | Gợi ý tiếng Nhật (optional) |
| `category` | TEXT | 'self', 'family', 'hobby', 'general' |
| `jlpt_level` | TEXT | N5, N4, N3, N2, N1 |
| `min_words` | INT default 30 | Số từ tối thiểu |
| `is_active` | BOOLEAN default true | |
| `order_index` | INT | |

### `writing_submissions`
| Column | Type | Mô tả |
|--------|------|-------|
| `id` | UUID PK | |
| `site_id` | UUID FK → sites | |
| `prompt_id` | UUID FK → writing_prompts | |
| `session_id` | UUID nullable | Client-generated |
| `response` | TEXT NOT NULL | Bài viết |
| `score` | INT | Tổng (0–100) |
| `score_grammar` | INT | Ngữ pháp (0–40) |
| `score_vocab` | INT | Từ vựng (0–30) |
| `score_content` | INT | Nội dung (0–30) |
| `feedback_vi` | TEXT | Nhận xét tiếng Việt |
| `errors` | JSONB | [{original, corrected, explanation_vi}] |
| `is_valid_lang` | BOOLEAN | Có phải tiếng Nhật không |
| `graded_at` | TIMESTAMPTZ | |

---

## API Endpoints

### `POST /api/writing-submissions`

Submit + chấm điểm trong 1 request.

```json
// Request
{
  "prompt_id": "uuid | 'fallback'",
  "prompt_vi": "Giới thiệu bản thân bằng tiếng Nhật.",
  "min_words": 50,
  "session_id": "uuid",
  "response": "わたしはグエンです..."
}

// Response
{
  "submission_id": "uuid | null",
  "is_valid_lang": true,
  "score": 77,
  "score_grammar": 30,
  "score_vocab": 22,
  "score_content": 25,
  "feedback_vi": "Bài viết khá tốt...",
  "errors": [
    { "original": "...", "corrected": "...", "explanation_vi": "..." }
  ]
}
```

> Nếu `prompt_id = 'fallback'`: dùng `prompt_vi`/`min_words` từ client, không lưu DB.

### `POST /api/writing-submissions/grade`
Re-grade submission đã lưu. Body: `{ "submission_id": "uuid" }`

### `GET /api/writing-prompts/random`
Lấy đề ngẫu nhiên.  
Params: `?exclude=<uuid>` (tránh lấy lại đề cũ), `?jlpt_level=N2,N3` (filter level).

---

## Grading Logic (Groq)

| Tiêu chí | Điểm | Mô tả |
|----------|------|-------|
| `is_valid_lang` | — | false → tất cả điểm = 0 |
| `score_grammar` | 0–40 | Ngữ pháp, cấu trúc câu |
| `score_vocab` | 0–30 | Từ vựng, độ phong phú |
| `score_content` | 0–30 | Nội dung liên quan đề bài |
| `score` | 0–100 | Tổng 3 tiêu chí |
| `errors` | — | Tối đa 5 lỗi quan trọng nhất |
| `feedback_vi` | — | Nhận xét 2–4 câu tiếng Việt |

Tiêu chuẩn chấm theo từng JLPT level (N5 dễ tính → N1 rất khắt khe).  
Rate limit 429 → tự động retry bằng fallback model ngay lập tức.

---

## Seed data

> File: `supabase/seed_writing_prompts.sql`  
> 150 đề: 30 đề × 5 cấp độ (N5/N4/N3/N2/N1)  
> min_words: N5=30, N4=50, N3=80, N2=120, N1=200

---

## Files liên quan

| File | Mô tả |
|------|-------|
| `src/lib/groq.ts` | Groq API client, grading logic, JLPT criteria |
| `src/app/api/writing-submissions/route.ts` | Submit + grade |
| `src/app/api/writing-submissions/grade/route.ts` | Re-grade |
| `src/app/api/writing-prompts/random/route.ts` | Lấy đề ngẫu nhiên |
| `src/app/writing-test/page.tsx` | Server page |
| `src/components/writing/WritingTestClient.tsx` | Client component |
