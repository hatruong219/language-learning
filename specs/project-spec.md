# Project Spec — Website Học Ngoại Ngữ (Language Learning)

## 1. Tên project
**language-learning** — domain: `nihongo.gnourt.dev` hoặc `lang.gnourt.dev`

## 2. Mục tiêu
Website cá nhân học tiếng Nhật (sau sẽ mở rộng ngôn ngữ khác):
- Quản lý từ vựng theo topic / deck
- Học qua flashcard ngẫu nhiên
- Text-to-Speech đọc từ
- Bảng chữ cái Hiragana / Katakana
- Luyện viết và nhận phản hồi từ AI

## 3. Công nghệ

| Phần | Công nghệ |
|------|-----------|
| Framework | Next.js 16 (TypeScript strict, App Router) |
| Database | Supabase (PostgreSQL) |
| UI | Tailwind CSS v4 + shadcn/ui |
| Animation | framer-motion (flashcard flip) |
| TTS | Web Speech API (browser native) |
| AI Grading | Groq API — llama-3.3-70b-versatile |
| Deploy | Vercel |

## 4. Liên kết hệ thống
- `site_id`: đăng ký 1 record trong bảng `sites` của web-mgmt-platform
- Supabase Auth: dùng chung (Phase 2)
- Database schema riêng: xem `database-schema.md`

## 5. Chức năng đã implement (Phase 1)

- [x] Danh sách từ vựng (filter deck / JLPT / search, pagination)
- [x] Chi tiết từ (furigana, TTS, câu ví dụ)
- [x] Bảng chữ cái Hiragana / Katakana
- [x] Flashcard (random, theo deck, chọn số lượng, lọc JLPT, phím tắt)
- [x] Luyện viết — AI chấm điểm grammar / vocab / content (Groq)
- [x] Deploy Vercel

## 6. Roadmap

- [ ] Seed đủ JLPT N5–N4 (~800–1500 từ)
- [ ] Quiz mode `/quiz`
- [ ] User progress tracking (cần Supabase Auth)
- [ ] Spaced repetition
- [ ] Multi-language support

## 7. Yêu cầu UI/UX
- Mobile-first, dark mode
- Font Noto Sans JP
- Animation mượt (framer-motion)

## 8. Bảo mật & phân quyền
- **Phase 1:** Tất cả màn học đều public, không cần đăng nhập
- **Phase 2:** User progress, custom decks → cần auth
- RLS Supabase bật cho các bảng user-specific
