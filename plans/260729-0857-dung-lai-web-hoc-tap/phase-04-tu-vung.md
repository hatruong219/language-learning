# Chặng 4 — Từ vựng gộp Flashcard, bỏ Chủ đề

**Rủi ro:** cao · **Đụng vào cái đang chạy:** có · **Phụ thuộc:** chặng 1

Làm CUỐI. Đây là phần anh nói *"đang khá tốt"* — sửa sau cùng, khi đã quen tay
với style mới ở chặng 2 và 3.

## Nguồn giữ nguyên `vocabulary` — 2617 từ, N5→N1

Không đổi sang `mnn_vocabulary`: giáo trình đóng khung ở 50 bài, lấy nó làm
nguồn là khoá trần cả trang ở N5/N4 vĩnh viễn.

## Ba chế độ trong một menu

```
/vocabulary              danh sách + bộ lọc      ← đang có, chỉ sửa cho đẹp
/vocabulary/flashcard    lật thẻ                 ← chuyển từ /flashcard
/vocabulary/practice     luyện tập               ← mới, dùng bộ chặng 1
```

Cả ba **ăn chung một bộ lọc**. Đang xem N3 thì bấm Flashcard là lật đúng thẻ
N3, bấm Luyện tập là kiểm đúng nhóm đó. Đây là điểm khác lớn nhất so với hiện
tại — và là lý do gộp.

## Nhớ bộ lọc

Lưu bộ lọc gần nhất vào `localStorage`, mở lại trang là khôi phục. Chỉ vậy —
**không lưu tiến độ học**, xem [chặng 1](phase-01-bo-luyen-tap.md#tiến-độ-không-lưu-gì).

Lưu cả bộ lọc lẫn ô tìm kiếm. Bộ lọc mà quên câu tìm thì mở lại thấy kết quả
không khớp bộ lọc đang hiện, khó hiểu hơn là không nhớ gì.

**Bẫy phải chặn:** bộ lọc cũ có thể ra RỖNG — cấp độ đó không còn từ nào, hoặc
dữ liệu đã đổi. Lúc đó màn hình trống trơn, đúng cái mà việc nhớ bộ lọc sinh ra
để tránh. Ra rỗng thì **tự bỏ bộ lọc và nói rõ**: *"Bộ lọc lần trước không còn
kết quả nào — đang hiện tất cả."*

Cùng một bộ lọc cho cả ba chế độ, nên nhớ một chỗ là cả ba cùng nhớ.

## Flashcard: viết lại cách chọn thẻ, không phải di chuyển file

Hiện `/flashcard/[slug]` duyệt **theo deck**:

```ts
.from('decks')                  // chọn chủ đề trước
backHref={`/decks/${deck.slug}`}
```

Bỏ menu Chủ đề thì cách chọn này mất chỗ dựa. Đổi sang **lấy từ bộ lọc đang
xem** — không còn `[slug]`, không còn `decks`.

Giữ lại `flashcard-utils.ts` (`shuffleArray` + reducer) — phần đó không đụng
tới deck.

## `decks` giữ NGUYÊN, không đụng gì

```sql
vocabulary.deck_id  UUID NOT NULL REFERENCES decks(id)
```

Bỏ menu Chủ đề = bỏ điều hướng + route `/decks`. Bảng `decks` và cột `deck_id`
**để nguyên**, kể cả ràng buộc NOT NULL.

**KHÔNG có migration nào trong chặng này.** Từ mới thêm qua trang quản trị vẫn
gán deck như hiện tại — hơi thừa, nhưng không cản gì, và đổi ràng buộc chỉ để
cho gọn là rủi ro không đáng. Khi nào thật sự vướng thì tính.

## Thứ tự làm, để không gãy giữa chừng

1. Thêm `/vocabulary/practice` — cộng thêm, chưa bỏ gì
2. Thêm `/vocabulary/flashcard` đọc theo bộ lọc — chạy song song bản cũ
3. Xác nhận bản mới đủ dùng, mới bỏ `/flashcard` và `/decks` khỏi menu
4. Chuyển hướng `/flashcard/*` và `/decks/*` sang trang mới — link cũ đã lưu
   hoặc đã chia sẻ không được chết

Cả bốn bước chỉ đụng mã, **không đụng database**.

## Xong khi nào

- [ ] Lọc N3 rồi bấm Flashcard → đúng thẻ N3, không phải toàn bộ
- [ ] Lọc rồi bấm Luyện tập → đúng nhóm đó
- [ ] `/flashcard` và `/decks` cũ chuyển hướng, không trả 404
- [ ] Danh sách 2617 từ vẫn cuộn mượt sau khi sửa giao diện
- [ ] Không còn chỗ nào trong giao diện nhắc tới "chủ đề"

## Rủi ro

**Đây là chặng duy nhất bỏ đi thứ đang chạy.** Nếu chỉ dừng ở bước 1–2 thì web
có cả cũ lẫn mới cùng lúc — hơi thừa nhưng không hỏng gì. Bước 3 trở đi mới là
điểm không quay lui được, nên chỉ làm khi anh đã dùng thử bản mới.
