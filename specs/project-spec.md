# Project Spec — Website Học Ngoại Ngữ (Language Learning)

## 1. Tên project
- **language-learning** (tên thư mục / domain gợi ý: `nihongo.gnourt.dev` hoặc `lang.gnourt.dev`)

## 2. Mục tiêu / Mô tả ngắn
Website cá nhân giúp học ngoại ngữ — ban đầu tập trung vào **tiếng Nhật**, sau sẽ mở rộng sang các ngôn ngữ khác.
- Quản lý từ vựng theo topic / deck
- Học qua flashcard ngẫu nhiên
- Có âm thanh đọc từ (Text-to-Speech)
- Bảng chữ cái tiếng Nhật (Hiragana / Katakana / Kanji cơ bản)

## 3. Công nghệ sử dụng
- **Frontend:** Next.js 15 (TypeScript, App Router)
  - Lý do chọn Next.js: có auth, dashboard quản lý từ, real-time (tương lai), tương tác phức tạp (flashcard, quiz)
- **Backend:** Supabase (dùng chung với hệ thống)
- **UI:** Tailwind CSS v4 + shadcn/ui
- **TTS (Text-to-Speech):** Web Speech API (browser native, free) — tương lai có thể dùng Google TTS / ElevenLabs
- **Khác:**
  - `react-hook-form` + `zod` — form validation
  - `framer-motion` — animation cho flashcard flip
  - `@supabase/ssr` — auth SSR

## 4. Liên kết với hệ thống quản lý tập trung
- **site_id:** Có — đăng ký 1 record trong bảng `sites` của web-mgmt-platform
- **Dùng chung bảng users:** Có — Supabase Auth
- **Các bảng dữ liệu riêng:** Xem file `database-schema.md`

## 5. Chức năng chính
Xem chi tiết tại `screens-features.md`

**Tóm tắt:**
- [ ] Danh sách từ vựng (có giải nghĩa, phiên âm, ví dụ)
- [ ] Bảng chữ cái Hiragana / Katakana
- [ ] Flashcard học (ngẫu nhiên, theo deck)
- [ ] Text-to-Speech đọc từ
- [ ] Quản lý deck / topic
- [ ] Thống kê học tập (basic)
- [ ] Quiz mode (trắc nghiệm)

## 6. Yêu cầu UI/UX
- Đơn giản, tối giản, hiện đại
- Mobile responsive (ưu tiên mobile-first — học trên điện thoại)
- Dark mode support
- Font hỗ trợ tiếng Nhật (Noto Sans JP)
- Animation mượt cho flashcard (flip effect)

## 7. Quy tắc bảo mật & phân quyền
- **Phase 1:** Tất cả màn học (vocabulary, flashcard, alphabet) đều **public** — không cần đăng nhập
- **Phase 2 (tương lai):** 
  - Free user: xem, học từ có sẵn
  - Premium user: thêm từ mới, tạo deck riêng, sync progress
- RLS Supabase: bật cho các bảng user-specific (progress, custom decks)

## 8. Ghi chú khác
- Bắt đầu với tiếng Nhật, schema thiết kế để sau có thể thêm `language_code` cho các ngôn ngữ khác
- TTS dùng Web Speech API trước (miễn phí), nếu không hỗ trợ câu phức tạp thì upgrade lên API trả phí
- Ưu tiên implement: vocabulary list → flashcard → alphabet chart → quiz
