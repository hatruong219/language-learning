# Dựng lại web học tập

`study.truongha.com` · Next.js 16 · React 19 · Tailwind 4 · Supabase

## Menu: từ 6 xuống 5

| Hiện tại | Sau |
|---|---|
| Từ vựng · Chủ đề · Minano · Flashcard · Luyện viết · Bảng chữ | **Từ vựng · Minano · Kanji · Luyện viết · Bảng chữ** |

Flashcard gộp vào Từ vựng. Chủ đề bỏ. Kanji thêm mới.

## Nguồn dữ liệu — ba nguồn, KHÔNG gộp

```
Từ vựng   →  vocabulary          2617 từ, N5→N1, lọc theo cấp
Minano    →  mnn_vocabulary      theo bài 1–50
             mnn_grammar         252 mẫu
             mnn_sentences       1247 câu  ← sinh đề tự động
Kanji     →  jlpt_kanji_words    448 từ
             jlpt_kanji          364 chữ (bấm vào từ thì mở ra)
```

Từ điển chung phải lớn dần tới N1, giáo trình đóng khung ở 50 bài — hai việc
khác nhau nên hai bảng. Gộp lại là khoá trần từ vựng ở N5/N4.

## Bốn chặng

| # | Chặng | Rủi ro | Đụng vào cái đang chạy |
|---|-------|--------|------------------------|
| 1 | [Bộ luyện tập dùng chung](phase-01-bo-luyen-tap.md) | thấp | không |
| 2 | [Menu Kanji](phase-02-kanji.md) | thấp | không |
| 3 | [Minano thành bài hoàn chỉnh](phase-03-minano.md) | vừa | có |
| 4 | [Từ vựng gộp Flashcard, bỏ Chủ đề](phase-04-tu-vung.md) | cao | có |

Chặng 1 làm trước vì chặng 2, 3, 4 đều dùng nó. Làm sau thì viết ba lần.

Xếp chặng 4 cuối vì nó đụng vào phần anh nói "đang khá tốt" — sửa sau cùng,
khi đã quen tay với style mới.

## Ba thứ dùng lại được, không viết mới

**`kana-quiz-popup/src/answer-matcher.js`** — 72 dòng JavaScript, chính là bản
gốc mà bản Dart trong app port ra. Web dùng thẳng, không phải viết bản thứ ba.

**`src/lib/flashcard-utils.ts`** — đã có `shuffleArray` + reducer trạng thái.

**`src/components/alphabet/PracticeClient.tsx`** — khuôn màn luyện tập đã chạy.

## Phát hiện đáng chú ý

**Minano đã có tab và ngữ pháp rồi.** `LessonDetail.tsx` có sẵn
`Nội dung | Luyện tập | Kết quả`, đã hiện `VocabSection` và `GrammarSection`.

Cái thiếu là **bài tập**: nó đọc `mnn_exercises` — viết tay, chỉ có bài 1–5
(138 câu). Bài 6–50 mở tab Luyện tập ra là trống. App sinh đề từ
`mnn_sentences` nên phủ đủ 50 bài mà không phải soạn câu nào.

Nên chặng 3 là **thay nguồn đề**, không phải dựng tab mới.

## Đã chốt: web KHÔNG lưu tiến độ

Chỉ hiện kết quả từng phiên. Ngoại lệ duy nhất là **nhớ bộ lọc** trong
`localStorage` cho màn hình khỏi trống lúc quay lại — đó là trạng thái giao
diện, không phải tiến độ học.

Lý do: app đang có kế hoạch đăng nhập + đồng bộ riêng. Web nhảy vào lưu tiến độ
lúc này là đẻ ra một không gian id thứ tư phải hoà giải về sau.

## KHÔNG có migration nào

Cả bốn chặng chỉ đụng mã. `decks` và `vocabulary.deck_id` giữ nguyên, kể cả
ràng buộc NOT NULL — bỏ menu Chủ đề chỉ là bỏ điều hướng.
