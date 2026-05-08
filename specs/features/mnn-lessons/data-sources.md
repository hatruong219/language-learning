# みんなの日本語 — Nguồn dữ liệu & Workflow

## ⚠️ Quy tắc quan trọng

**KHÔNG generate nội dung từ training memory** — dễ nhầm thứ tự bài, nhầm từ giữa các bài.  
Bài học từ sai lầm: Bài 5 bị generate thành **いくらですか** (mua sắm) thay vì **行きます・来ます・帰ります** (di chuyển). いくらですか là Bài 13 trong MNN I.

**BẮT BUỘC: Fetch từ nguồn uy tín trước khi viết SQL.**

---

## Nguồn uy tín

| Nguồn | URL pattern | Dùng để lấy |
|-------|-------------|------------|
| **langoal.com** | `https://langoal.com/vocbs/lesson-{N}.html` | Từ vựng: kanji + furigana + romaji + English |
| **umenjapan.wordpress.com** | `https://umenjapan.wordpress.com/minna-no-nihongo-lesson-{N}-vocabulary-and-grammar/` | Grammar points + ví dụ |
| **hire39.com** | `https://hire39.com/minna-no-nihongo-basic-1` | 文型リスト bài 1–25 |
| **nihon5-bunka.net** | `https://nihon5-bunka.net/minnano-nihongo-lessonplans/` | Giáo án đầy đủ |
| **denisowski.org** | `http://denisowski.org/Japanese/MNN_1/MNN_1.html` | Full vocab list MNN I |

---

## Workflow generate bài mới

```
1. WebFetch → langoal.com/vocbs/lesson-{N}.html
   → lấy danh sách từ vựng (word, reading, meaning)

2. WebFetch → umenjapan.wordpress.com/.../lesson-{N}-vocabulary-and-grammar/
   → lấy grammar points + ví dụ

3. Cross-check hire39.com nếu cần thêm 文型

4. Viết SQL vào supabase/seed_mnn_lessons_{range}.sql
   (pattern DO $$ ... END $$; như file seed hiện tại)
```

---

## Bài đã seed

> Seed file: `supabase/seed_mnn_lessons_1_5.sql`

| Bài | Tiêu đề | Ngữ pháp chính | Từ vựng |
|-----|---------|----------------|---------|
| 1 | はじめまして | 〜は〜です / じゃありません / ですか / も | 17 từ |
| 2 | これはなんですか | これ/それ/あれ / なんですか / 〜の / だれの | 18 từ |
| 3 | あそこです | ここ/そこ/あそこ / どこですか / があります/います | 22 từ |
| 4 | なんじですか | 〜じ〜ふん / なんじですか / から〜まで | 18 từ |
| 5 | 行きます・来ます・帰ります | 〜へ / 〜で (phương tiện) / 〜と (cùng với) / いつ | 24 từ |

---

## Thứ tự bài đã xác nhận (Book I, nguồn: langoal.com + umenjapan)

| Bài | Chủ đề | Ghi chú |
|-----|--------|---------|
| 1 | はじめまして | Giới thiệu, nghề nghiệp |
| 2 | これはなんですか | Đồ vật, chỉ thị từ |
| 3 | あそこです | Địa điểm, tồn tại |
| 4 | なんじですか | Giờ giấc, thời gian |
| 5 | 行きます | Di chuyển, phương tiện |
| 6 | まいにち〜 | Sinh hoạt hàng ngày |
| 7 | 休みはなんにちですか | Ngày tháng, lịch |
| 8 | 〜をください | Yêu cầu, mua sắm |
| 9 | そのセーターは〜 | Màu sắc, mua sắm |
| 10 | まちはどこにありますか | Vị trí chi tiết |
| ... | ... | Cần fetch khi đến bài đó |
