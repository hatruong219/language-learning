# Kotoba (Flutter web)

App học từ vựng, kanji, ngữ pháp tiếng Nhật, chạy như PWA tại `/kotoba-app/app/` của site này.

## Nguồn gốc
Copy từ repo `hatruong219/kotoba` (máy local: `/home/gnourt/my-project/mnn-flashcard`). Repo đó giữ làm bản build iOS sau này. Hai bên sẽ **lệch nhau dần**: sửa cho bản web thì sửa ở đây, đừng kỳ vọng đồng bộ ngược.

## Chạy local
Cần Flutter 3.32.0. Chạy `pnpm dev` ở root (cổng 3000), rồi:

```bash
cd kotoba
flutter run -d chrome --dart-define=KOTOBA_API_BASE=http://localhost:3000/kotoba-app
```

`KOTOBA_API_BASE` mặc định `/kotoba-app` (cùng origin, không CORS). Đồng bộ gọi `$base/api/kotoba/...`, STT gọi `$base/api/stt`.

## Test
```bash
cd kotoba
flutter analyze
flutter test
```

## Build
Từ root: `pnpm build:kotoba` (`scripts/build-kotoba-web.sh`) → `flutter build web --base-href /kotoba-app/app/` rồi chép vào `public/kotoba-app/app` (gitignored). Vercel tự chạy trước `next build`.

## Công cụ (`tools/`, cần `pip install --user fonttools`)
- `make-app-icon.py`: sinh icon PWA/favicon từ `assets/app-icon-source.png`.
- `subset-fonts.py`: sinh font con Noto Sans / Noto Sans JP vào `assets/fonts/`. Chạy lại khi thêm chuỗi UI hoặc kanji mới (không chạy trên CI).
- `check-font-coverage.py` (`--write` để ghi lại `font-coverage.txt`): kiểm mọi ký tự UI có trong font; thiếu thì CanvasKit tải font từ Google lúc chạy.

## Lưu trữ
- Tiến độ, cài đặt, dữ liệu đồng bộ lưu trong IndexedDB của trình duyệt (DB `kotoba`, object store `kv`, ghi nguyên tử bằng transaction). Không lưu trên server.
- Cài đặt → Sao lưu: xuất/nhập JSON `{app: "mnn_flashcard", version: 1, words: {...}}`, cùng định dạng với app iOS. Nhập sẽ cất bản hiện tại vào khoá `progress.json.before-import` trước khi thay.
- Dữ liệu từ máy chủ chỉ tải khi người dùng bấm đồng bộ; chưa bấm thì dùng bản đóng gói trong `assets/`.

## Luyện nói (mic)
Ghi âm WAV (tối đa 8 giây) → `POST /kotoba-app/api/stt` → Groq Whisper trả `{text}`.
- Chỉ gửi âm thanh, **không gửi đáp án mong đợi** (tránh mớm cho Whisper).
- Silence gating: dừng khi im lặng 1,5 giây sau khi đã nghe tiếng; không vượt ngưỡng tiếng nói thì không gửi gì lên server.
- Cần quyền micro và kết nối mạng.

## Giới hạn đã biết
- Mở nhiều tab cùng lúc: tab ghi sau ghi đè tab trước, không merge.
- iOS: app ở màn hình chính có bộ nhớ riêng, tách khỏi Safari; xuất sao lưu ở Safari rồi nhập lại sau khi cài.
- iOS có thể xoá dữ liệu của web app lâu không mở; nên xuất sao lưu định kỳ.
