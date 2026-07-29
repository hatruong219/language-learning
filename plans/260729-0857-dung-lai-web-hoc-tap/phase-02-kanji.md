# Chặng 2 — Menu Kanji

**Rủi ro:** thấp · **Đụng vào cái đang chạy:** không · **Phụ thuộc:** chặng 1

Làm sớm vì nó là menu HOÀN TOÀN MỚI — không đụng gì đang chạy, mà cho anh nhìn
thấy style mới trước khi em sửa vào phần đang tốt.

## Dữ liệu đã sẵn sàng, không cần migration

```
jlpt_kanji_words   448 từ · từ · âm Hán-Việt · kana · nghĩa · level
jlpt_kanji         364 chữ · on/kun · số nét · mảnh cấu tạo · nghĩa
jlpt_kanji_parts   181 mảnh cấu tạo
```

RLS đã mở đọc công khai. API `/api/kotoba/kanji-words` đã chạy (dùng cho app),
nhưng web đọc thẳng Supabase như các trang khác, không cần qua API đó.

## Ba trang

**`/kanji`** — danh sách 448 từ, theo đúng thứ tự PDF

Mỗi dòng: từ · cách đọc · âm Hán-Việt · nghĩa. Từng chữ Hán trong từ bấm được.

Bộ lọc: **gom cấp từ dữ liệu**, không viết cứng `['N5','N4']`. Hiện tất cả là
N4 nên chỉ một mục — hôm nào database phân lại cấp là web tự có thêm nút.
Chỉ một cấp thì ẩn hẳn hàng lọc.

Tìm kiếm không cần bỏ dấu: gõ `gia dinh` ra `家族`.

**`/kanji/[char]`** — một chữ: mặt chữ, on/kun, Hán-Việt, số nét, mảnh cấu tạo,
và các từ chứa nó.

**`/kanji/practice`** — dùng bộ luyện tập chặng 1, nguồn `jlpt_kanji_words`.

## Bài học rút từ app, đừng lặp lại

**Không làm màn duyệt bộ thủ riêng.** App từng có, rồi bỏ: nó bày chữ đứng trơ
trong khi đề thi luôn hỏi kanji TRONG MỘT TỪ. Bộ thủ là công cụ tra cứu, đặt
trong trang chi tiết chữ là đủ.

**Không chia N5/N4 bằng suy đoán.** Đã thử ba cách, cả ba đều bịa. Hiện tất cả
là N4 — một giá trị thật thà, sửa tay trên database khi cần.

**Giữ nguyên chỗ PDF viết chữ ngoài phạm vi bằng kana** — `家ちん` (= 家賃),
`道ろ`, `ひ鳴`. Đó là quy ước dạy học, sửa lại là lệch với sách trên lớp.

## Xong khi nào

- [ ] 448 từ đúng thứ tự PDF, không sắp lại
- [ ] Bấm chữ trong từ mở đúng trang chữ đó
- [ ] Tìm được bằng chữ, kana, âm Hán-Việt, nghĩa không dấu
- [ ] Một cấp thì không hiện hàng lọc
- [ ] `葉` là chữ duy nhất chưa có trang chi tiết — đừng vẽ liên kết bấm vào rỗng
