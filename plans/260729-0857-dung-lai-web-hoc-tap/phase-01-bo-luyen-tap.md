# Chặng 1 — Bộ luyện tập dùng chung

**Rủi ro:** thấp · **Đụng vào cái đang chạy:** không

Làm trước tiên vì cả ba chặng sau đều dùng. Làm sau thì viết ba lần rồi ba bản
lệch nhau.

## Yêu cầu cốt lõi: KHÔNG biết nguồn dữ liệu

Bộ luyện tập nhận một danh sách phẳng, không quan tâm nó tới từ bảng nào:

```ts
type Item = {
  id: string        // 'v-<uuid>' | 'mnn-<uuid>' | 'kw3'
  prompt: string    // hiện trên đề
  answer: string    // đáp án đúng
  hint?: string     // nghĩa tiếng Việt, hiện sẵn
}
```

Nhờ vậy Từ vựng (`vocabulary`), Minano (`mnn_vocabulary`), Kanji
(`jlpt_kanji_words`) dùng chung một màn, một luật chấm, một cách đếm.

Tiền tố id nói rõ nguồn — cùng quy ước app đang dùng (`kw3` cho từ chữ Hán).

## Chấm đáp án: dùng lại, không viết mới

`kana-quiz-popup/src/answer-matcher.js` — 72 dòng, đã chạy thật trên app
desktop, và là bản gốc mà bản Dart trong app port ra. Chép sang
`src/lib/answer-matcher.ts`, đổi `module.exports` thành `export`, thêm kiểu.

**Không viết lại luật.** Ba bản cùng một luật là ba bản sẽ lệch nhau.

Luật đó xử lý sẵn: bỏ ký hiệu trang trí, `A / B` chấp nhận cả hai, `（B）` là
cách gọi khác, `[B]` là phần tùy chọn. KHÔNG quy đổi katakana ↔ hiragana.

## Bốn dạng đề

Lấy từ app, đã chứng minh là dùng được:

| Dạng | Đề | Đáp án |
|---|---|---|
| Việt → Nhật | nghĩa tiếng Việt | gõ kana |
| Nhật → Việt | từ tiếng Nhật | chọn 4 nghĩa |
| Đọc (漢字読み) | từ viết kanji | chọn 4 cách đọc |
| Viết (表記) | từ viết kana | chọn 4 dạng kanji |

Hai dạng cuối chỉ dựng được khi từ có dạng kanji — bộ dựng đề tự bỏ qua từ
không có, không báo lỗi.

**Nhiễu phải KHÓ.** Ưu tiên từ cùng chứa một chữ Hán với đáp án: hỏi 学生 thì
nhiễu 学校. Nhiễu ngẫu nhiên loại được bằng độ dài, quá dễ.

## Đếm bốn loại, không phải hai

`đúng · sai · bỏ qua · chưa làm` — bốn số cộng lại luôn bằng tổng. App từng
thiếu "chưa làm" và người dùng thấy con số không khớp.

## Xong khi nào

- [ ] Cùng một component chạy được với cả ba nguồn
- [ ] Luật chấm khớp bản gốc — test đối chiếu trên dữ liệu thật
- [ ] Bốn số luôn cộng đúng bằng tổng
- [ ] Thoát giữa chừng vẫn chốt được điểm
- [ ] Không dựng nổi đề thì nói rõ vì sao, không hiện màn trống

## Tiến độ: KHÔNG lưu gì

Đã chốt. Web chỉ hiện kết quả từng phiên rồi thôi — không ghi vào
`localStorage`, không ghi lên database, không cần đăng nhập.

Lý do: bên app đang có kế hoạch đăng nhập + đồng bộ riêng. Web nhảy vào lưu
tiến độ lúc này là đẻ ra một không gian id thứ tư phải hoà giải về sau, mà hoà
giải hai bản tiến độ lệch nhau là thứ khó nhất và dễ mất dữ liệu nhất.

**Ngoại lệ duy nhất: nhớ BỘ LỌC.** Xem [chặng 4](phase-04-tu-vung.md#nhớ-bộ-lọc)
— đó là trạng thái giao diện, không phải tiến độ học.
