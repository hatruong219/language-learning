# Chặng 3 — Minano thành bài hoàn chỉnh

**Rủi ro:** vừa · **Đụng vào cái đang chạy:** có · **Phụ thuộc:** chặng 1

## Đây là THAY NGUỒN ĐỀ, không phải dựng tab mới

`LessonDetail.tsx` đã có sẵn `Nội dung | Luyện tập | Kết quả`, đã hiện
`VocabSection` và `GrammarSection`. Đừng dựng lại.

Cái hỏng nằm ở nguồn bài tập:

```
hiện tại   mnn_exercises    viết tay · CHỈ có bài 1–5 (138 câu)
                            → bài 6–50 mở tab Luyện tập ra là TRỐNG
sau        mnn_sentences    1247 câu · đủ 50 bài · sinh đề tự động
```

## Ba dạng đề trong một bài

**Từ vựng của bài** — dùng bộ chặng 1, nguồn `mnn_vocabulary` lọc theo bài.
Đây là thứ anh nói *"thêm 1 tab để kiểm tra từ như app"*.

**Điền trợ từ** — khoét một trợ từ trong câu ví dụ, 4 phương án.

Luật nhận trợ từ: **kana đứng ngay sau một chữ Hán**. Không tách từ. Bỏ sót vài
câu thì không sao; khoét nhầm giữa một từ là đề mất đáp án đúng.

Hai chốt bắt buộc, app đã trả giá để tìm ra:
- `で` của です／でした／では là **hệ từ**, không phải trợ từ — không khoét
- `や` của 冷やす／増やす là đuôi động từ — không khoét

Nhiễu lấy đúng cặp hay lẫn: が↔は, に↔で, を↔が. Ngẫu nhiên thì quá dễ.

**Chọn nghĩa câu** — câu tiếng Nhật, 4 bản dịch. Nhiễu phải khác hẳn nội dung
nhưng gần về độ dài, và **không được chứa hoặc bị chứa trong đáp án** — hai câu
lồng nhau thì mất đáp án đúng duy nhất.

## Lọc rác của nguồn

Riki trộn số thứ tự bài tập và nhãn hội thoại vào cùng ô với câu:
`例2：このパソコンの…`, `男の人：重いでしょう？`. Đọc thì hiểu, nhưng khoét chỗ
trống vào là đề hỏng.

Bỏ câu chứa `例 ： : [ ] （ ） ( ) ＝ → ※ …`, hoặc dài quá 34 ký tự.

Còn khoảng **820/1247 câu sạch**, đủ dựng **282 đề trợ từ + 813 đề chọn nghĩa**.

## `mnn_exercises` xử lý sao

Giữ nguyên bảng, KHÔNG xoá. 138 câu viết tay của bài 1–5 chất lượng cao hơn đề
sinh tự động. Ghép: bài nào có đề viết tay thì dùng trước, thiếu bao nhiêu mới
sinh thêm.

## Xong khi nào

- [ ] Bài 6–50 mở tab Luyện tập ra CÓ đề, không còn trống
- [ ] Bài 1–5 vẫn dùng đề viết tay trước
- [ ] Lắp đáp án vào chỗ trống ra ĐÚNG câu gốc — kiểm trên cả 1247 câu
- [ ] Không câu nào khoét vào `で` của です
- [ ] Không đề nào chứa `例2：` hay nhãn hội thoại
- [ ] Bài không dựng nổi đề thì nói rõ vì sao

## Rủi ro

Luật khoét trợ từ là **suy đoán, không phải phân tích ngôn ngữ**. Test chứng
minh được "không khoét lệch", KHÔNG chứng minh được "chỗ khoét đúng là trợ từ".
App đã dò tay 30 mẫu và chặn hai ca biết trước. Web dùng lại đúng luật đó thì
thừa hưởng cả điểm mạnh lẫn giới hạn này.
